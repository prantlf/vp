import os { exists, join_path_single, read_file, write_file }
import prantlf.debug { rwd }
import prantlf.jany { Any, any_null }
import prantlf.json { ParseOpts, StringifyOpts, parse, stringify }
import prantlf.osutil { execute }

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
		text := stringify(pkg, StringifyOpts{ pretty: true })
		write_file(pkg_file, text)!

		if lck_is {
			dlck_file := d.rwd(lck_file)
			d.log('writing file "%s"', dlck_file)
			text2 := stringify(lck, StringifyOpts{ pretty: true })
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
	_, pkg_file := find_package() or { return }
	pkg := read_json(pkg_file)!
	pkg_ver := pkg.object()!['version'] or {
		return error('no version in package.json has been found')
	}
	if pkg_ver.string()! == ver {
		msg := 'version ${ver} has been already published'
		if opts.failure {
			return error(msg)
		}
		println(msg)
		return
	}

	mode := if opts.dry_run {
		' (dry-run)'
	} else {
		''
	}

	if opts.push && (opts.yes || confirm('publish version ${ver}${mode}')!) {
		if !opts.dry_run {
			extra_args := if opts.verbose { ' -v' } else { '' }
			out := execute('npm publish --access public${extra_args}')!
			d.log_str(out)
			eprintln('')
		}
		println('published version ${ver}${mode}')
	}
}

fn find_package() !(string, string) {
	return find_file('package.json')!
}

fn read_json(file string) !Any {
	dfile := d.rwd(file)
	d.log('reading file "%s"', dfile)
	text := read_file(file)!
	return parse(text, ParseOpts{})!
}
