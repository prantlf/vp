import os { create, join_path_single, read_file }
import semver { Increment }
import strings { new_builder }
import prantlf.debug { rwd }
import prantlf.github { find_git, get_repo_path }
import prantlf.osutil { ExecuteOpts, execute, execute_opt }
import prantlf.pcre { NoMatch, NoReplace, RegEx, pcre_compile }
import prantlf.semvut { next_prerelease, next_release }
import prantlf.strutil { last_line_not_empty, until_last_nth_line_not_empty }

const re_verline = pcre_compile(r'^version ((?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)(?:-[.0-9A-Za-z-]+)?)',
	0)!

fn create_version(version string, commit bool, tag bool, opts &Opts) !(string, string) {
	vlang, node, rust, vmod_dir := find_manifest_or_package_or_cargo(opts)
	if vmod_dir.len == 0 && (!opts.changes || opts.bump) {
		return error('neither v.mod nor package.json nor Cargo.toml was found')
	}

	mode := if opts.dry_run {
		'd'
	} else {
		''
	}
	mut ver := ''
	mut log := ''
	if opts.changes {
		mut extra_args := mode
		if opts.tag_prefix != 'v' {
			extra_args += ' -t "${opts.tag_prefix}"'
		}
		if opts.pre_release {
			extra_args += ' --pre-release'
		}
		if opts.pre_id != 'v' {
			extra_args += ' --pre-id "${opts.pre_id}"'
		}
		if opts.nc_args.len > 0 {
			extra_args += ' ${opts.nc_args}'
		}
		out := execute_opt('newchanges -Nuv${extra_args}', ExecuteOpts{
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
			m.group_text(line, 1) or { panic(err) }
		} else {
			return error('unexpected output of newchanges: "${line}"')
		}
	} else {
		ver = get_next_version(version, vmod_dir, opts.pre_id, opts.bump_major_0)!
	}

	mut re_vertxt := unsafe { &RegEx(nil) }
	mut re_vernum := unsafe { &RegEx(nil) }
	if opts.bump || opts.bump_files.len > 0 {
		re_vertxt = pcre_compile(opts.version_detect, pcre.opt_caseless)!
		re_vernum = pcre_compile(opts.version_replace, 0)!
	}
	if opts.bump {
		if vlang {
			vmod_file := join_path_single(vmod_dir, 'v.mod')
			update_version(vmod_file, re_vertxt, re_vernum, ver, true, opts)!
		}
		if node {
			set_package_version(ver, vmod_dir, opts)!
		}
		if rust {
			set_cargo_version(ver, vmod_dir, opts)!
		}
	}
	for bump_file in opts.bump_files {
		update_version(bump_file, re_vertxt, re_vernum, ver, true, opts)!
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

	tagver := '${opts.tag_prefix}${ver}'
	if commit {
		if tag {
			out := execute_opt('git tag -l "${tagver}"', ExecuteOpts{
				trim_trailing_whitespace: true
			})!
			d.log_str(out)
			if out.len > 0 {
				msg := 'tag ${tagver} already exists'
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

		git_path := find_git()!
		repo_path := get_repo_path(git_path)!
		commit_skip_ci := if opts.commit_skip_ci && is_github(repo_path) {
			' [skip ci]'
		} else {
			''
		}
		no_verify := if opts.verify {
			''
		} else {
			' --no-verify'
		}
		mut out := execute('git commit -am${no_verify} "${ver}${commit_skip_ci}"')!
		d.log_str(out)
		eprintln('')

		if tag {
			tag_skip_ci := if opts.tag_skip_ci && is_github(repo_path) {
				' [skip ci]'
			} else {
				''
			}
			out = execute('git tag -a "${tagver}" -m "${ver}${tag_skip_ci}"')!
			d.log_str(out)

			println('prepared version ${ver} for pushing')
		} else {
			println('prepared version ${ver} for tagging')
		}
	} else {
		println('prepared version ${ver} for committing${mode}')
	}
}

fn get_next_version(new_ver string, vmod_dir string, pre_id string, bump_major_0 bool) !string {
	if new_ver.len == 0 {
		return error('updating the changelog was disabled, specify the new version on the command line')
	}

	ver := get_current_version(vmod_dir)!
	return if new_ver == 'pre' {
		if ver.len == 0 {
			return error('package manifest contains no version')
		}
		orig_ver := semver.from(ver)!
		next_prerelease(orig_ver, pre_id).str()
	} else if mut increment := get_increment(new_ver) {
		if ver.len == 0 {
			return error('package manifest contains no version')
		}
		orig_ver := semver.from(ver)!
		if increment == Increment.major && orig_ver.major == 0 && !bump_major_0 {
			increment = Increment.minor
		}
		next_release(orig_ver, increment).str()
	} else {
		semver.from(new_ver)!
		if ver == new_ver {
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

fn update_version(file string, re_vertxt &RegEx, re_vernum &RegEx, ver string, required bool, opts &Opts) ! {
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
				if opts.failure {
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

	if opts.verbose {
		mode := if opts.dry_run {
			' (dry-run)'
		} else {
			''
		}
		println('updated version in "${rwd(file)}"${mode}')
	}

	if !opts.dry_run {
		d.log('writing file "%s"', dfile)
		mut f := create(file)!
		defer {
			f.close()
		}
		data := unsafe { builder.reuse_as_plain_u8_array() }
		f.write(data)!
	}
}
