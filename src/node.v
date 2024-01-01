import os { create, exists, getenv_opt, home_dir, join_path_single, read_file, read_lines, write_file }
import prantlf.debug { rwd }
import prantlf.jany { Any, any_null }
import prantlf.json { StringifyOpts, parse, stringify_opt }
import prantlf.osutil { execute, find_file }

fn set_package_version(ver string, pkg_dir string, opts &Opts) ! {
	pkg_file := join_path_single(pkg_dir, 'package.json')
	if !exists(pkg_file) {
		return
	}

	d.log('setting package version to "%s"', version)
	pkg := read_json(pkg_file)!
	pkg.object()!['version'] = ver

	lck_file := join_path_single(pkg_dir, 'package-lock.json')
	lck_is := exists(lck_file)
	mut lck := any_null()
	if lck_is {
		lck = read_json(lck_file)!
		lck.object()!['version'] = ver
		lck.set('packages."".version', Any(ver))!
	}

	if !opts.dry_run {
		dpkg_file := d.rwd(pkg_file)
		d.log('writing file "%s"', dpkg_file)
		text := stringify_opt(pkg, &StringifyOpts{ pretty: true })
		write_file(pkg_file, text)!

		if lck_is {
			dlck_file := d.rwd(lck_file)
			d.log('writing file "%s"', dlck_file)
			text2 := stringify_opt(lck, &StringifyOpts{ pretty: true })
			write_file(lck_file, text2)!
		}
	}

	if opts.verbose {
		mut mode := if opts.dry_run {
			' (dry-run)'
		} else {
			''
		}
		if lck_is {
			mode = ' and "${rwd(lck_file)}"${mode}'
		}
		println('updated version in "${rwd(pkg_file)}"${mode}')
	}
}

fn publish_package(ver string, opts &Opts) ! {
	_, _ := find_package() or { return }

	was_authenticated, glob_npmrc, npmrc := authenticate(opts)!
	defer {
		if was_authenticated {
			set_auth_token(glob_npmrc, npmrc, '') or { eprintln(err.msg()) }
		}
	}

	mode := if opts.dry_run {
		' (dry-run)'
	} else {
		''
	}

	if opts.yes || confirm('publish version ${ver}${mode}')! {
		mut extra_args := if opts.verbose { ' --verbose' } else { ' --quiet' }
		if opts.dry_run {
			extra_args += ' --dry-run'
		}
		out := execute('npm publish --access public${extra_args}')!
		println(out)
	}
}

fn authenticate(opts &Opts) !(bool, string, []string) {
	mut is_authenticated := false
	mut npmrc := []string{}
	glob_npmrc := join_path_single(home_dir(), '.npmrc')
	if exists(glob_npmrc) {
		npmrc = read_npmrc(glob_npmrc)!
		is_authenticated = has_auth_token(npmrc)!
	}
	if !is_authenticated {
		pkg_dir, _ := find_package()!
		loc_npmrc := join_path_single(pkg_dir, '.npmrc')
		if exists(loc_npmrc) {
			npmrc2 := read_npmrc(loc_npmrc)!
			is_authenticated = has_auth_token(npmrc2)!
		}
	}

	if is_authenticated {
		return false, '', []string{}
	}

	token := if opts.npm_token.len > 0 {
		opts.npm_token
	} else {
		get_npm_token()!
	}
	set_auth_token(glob_npmrc, npmrc, token)!

	return true, glob_npmrc, npmrc
}

fn read_npmrc(file string) ![]string {
	d.log('reading "%s"', file)
	return read_lines(file)!
}

fn has_auth_token(npmrc []string) !bool {
	for line in npmrc {
		if line.contains('//registry.npmjs.org/:_authToken') {
			d.log_str('is authenticated')
			return true
		}
		d.log('ignoring line "%s"', line)
	}
	d.log_str('is not authenticated')
	return false
}

fn set_auth_token(file string, lines []string, token string) ! {
	d.log('creating "%s"', file)
	mut out := create(file)!
	defer {
		out.close()
	}

	d.log_str('writing new contents')
	for line in lines {
		out.writeln(line)!
	}
	if token.len > 0 {
		out.write_string('//registry.npmjs.org/:_authToken=')!
		out.writeln(token)!
	}

	out.close()
	d.log_str('file written')
}

fn find_package() !(string, string) {
	return find_file('package.json') or { error('package.json not found') }
}

fn read_json(file string) !Any {
	dfile := d.rwd(file)
	d.log('reading file "%s"', dfile)
	text := read_file(file)!
	return parse(text)!
}

fn get_npm_token() !string {
	return getenv_opt('NODE_AUTH_TOKEN') or {
		getenv_opt('NPM_TOKEN') or { return error('neither NODE_AUTH_TOKEN nor NPM_TOKEN found') }
	}
}
