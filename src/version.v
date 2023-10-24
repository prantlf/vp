import os { create, read_file }
import semver { Increment }
import strings { new_builder }
import prantlf.debug { rwd }
import prantlf.osutil { ExecuteOpts, execute, execute_opt }
import prantlf.pcre { NoMatch, NoReplace, pcre_compile }
import prantlf.strutil { last_line_not_empty, until_last_nth_line_not_empty }

const (
	re_vertxt  = pcre_compile('version', pcre.opt_caseless)!
	re_verline = pcre_compile(r'^version ((?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*))',
		0)!
	re_vernum  = pcre_compile(r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)', 0)!
)

fn create_version(version string, commit bool, tag bool, opts &Opts) !(string, string) {
	vmod_file := if !opts.changes || opts.bump {
		_, file := find_manifest()!
		file
	} else {
		''
	}

	mode := if opts.dry_run {
		'd'
	} else {
		''
	}
	mut ver := ''
	mut log := ''
	if opts.changes {
		out := execute_opt('newchanges -Nuv${mode}', ExecuteOpts{
			trim_trailing_whitespace: true
		})!
		log = until_last_nth_line_not_empty(out, 2)
		line := last_line_not_empty(out)
		if opts.verbose {
			println(out)
		} else {
			println(line)
		}
		if line.starts_with('no ') {
			msg := 'version not upgraded'
			if opts.failure {
				return error(msg)
			}
			println(msg)
			return '', ''
		}
		ver = if m := re_verline.exec(line, 0) {
			m.group_text(line, 1) or { return unreachable() }
		} else {
			return error('unexpected output of newchanges: "${line}"')
		}
	} else {
		ver = get_version(version, vmod_file)!
	}

	if opts.bump {
		update_version(vmod_file, ver, opts.failure, true, opts.dry_run, opts.verbose)!
	}
	for bump_file in opts.bump_files {
		update_version(bump_file, ver, opts.failure, true, opts.dry_run, opts.verbose)!
	}

	do_commit(ver, commit, tag, opts)!

	return ver, log
}

fn do_commit(ver string, commit bool, tag bool, opts &Opts) ! {
	mode := if opts.dry_run {
		' (dry-run)'
	} else {
		''
	}

	if commit {
		if tag {
			out := execute_opt('git tag -l "v${ver}"', ExecuteOpts{
				trim_trailing_whitespace: true
			})!
			d.log_str(out)
			if out.len > 0 {
				msg := 'tag v${ver} already exists'
				if opts.failure {
					return error(msg)
				}
				println(msg)
				return
			}
		}

		if opts.dry_run {
			println('prepared version ${ver} for committing${mode}')
			return
		}

		mut out := execute('git commit -am "${ver} [skip ci]"')!
		d.log_str(out)
		eprintln('')

		if tag {
			out = execute('git tag -a "v${ver}" -m "${ver}"')!
			d.log_str(out)

			println('prepared version ${ver} for pushing')
		} else {
			println('prepared version ${ver} for tagging')
		}
	} else {
		println('prepared version ${ver} for committing${mode}')
	}
}

fn get_version(new_ver string, vmod_name string) !string {
	if new_ver.len == 0 {
		return error('updating the changelog was disabled, specify the new version on the command line')
	}

	return if increment := get_increment(new_ver) {
		manifest := read_manifest(vmod_name)!
		if manifest.version.len == 0 {
			return error('package manifest contains no version')
		}
		orig_ver := semver.from(manifest.version)!
		orig_ver.increment(increment).str()
	} else {
		semver.from(new_ver)!
		manifest := read_manifest(vmod_name)!
		if manifest.version == new_ver {
			return error('${new_ver} is the current version')
		}
		new_ver
	}
}

fn get_increment(version string) ?Increment {
	return match version {
		'major' {
			Increment.major
		}
		'minor' {
			Increment.minor
		}
		'patch' {
			Increment.patch
		}
		else {
			none
		}
	}
}

fn update_version(file string, ver string, failure bool, required bool, dry bool, verbose bool) ! {
	dfile := d.rwd(file)
	d.log('reading file "%s"', dfile)
	contents := read_file(file)!
	lines := contents.split_into_lines()
	mut builder := new_builder(contents.len)
	mut found := false
	mut updated := false

	for line in lines {
		mut updated_line := line
		if !updated && re_vertxt.contains(line, 0)! {
			if new_line := re_vernum.replace(line, ver, 0) {
				if d.is_enabled() {
					d.log_str('version detected: "${line}"')
					d.log_str('version updated:  "${new_line}"')
				}
				updated_line = new_line
				updated = true
			} else {
				if !(err is NoMatch || err is NoReplace) {
					return err
				}
			}
			found = true
		}
		builder.writeln(updated_line)
	}

	if !updated {
		if required {
			rfile := rwd(file)
			if found {
				msg := 'version ${ver} already exists in "${rfile}"'
				if failure {
					return error(msg)
				}
				println(msg)
				return
			}
			return error('version not found in "${rfile}"')
		}
		d.log_str('skipping a file without a version number detected')
		return
	}

	if verbose {
		mode := if dry {
			' (dry-run)'
		} else {
			''
		}
		println('updated version in "${rwd(file)}"${mode}')
	}

	if !dry {
		d.log('writing file "%s"', dfile)
		mut f := create(file)!
		defer {
			f.close()
		}
		data := unsafe { builder.reuse_as_plain_u8_array() }
		f.write(data)!
	}
}
