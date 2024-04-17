import os { exists, join_path_single, read_lines, write_file }
import toml { parse_file }
import prantlf.debug { rwd }
import prantlf.osutil { find_file }

fn set_cargo_version(ver string, pkg_dir string, opts &Opts) ! {
	cargo_file := join_path_single(pkg_dir, 'Cargo.toml')
	if !exists(cargo_file) {
		return
	}
	mut cargo_version := false

	mut cargo_lines := read_lines_from_file(cargo_file)!
	lck_file := join_path_single(pkg_dir, 'Cargo.lock')
	lck_is := exists(lck_file)
	mut lck_lines := []string{}
	mut lck_version := false
	if lck_is {
		lck_lines = read_lines_from_file(lck_file)!
	}

	d.log('setting cargo version to "%s"', version)
	for i := 0; i < cargo_lines.len; i++ {
		if cargo_lines[i].starts_with('version = "') {
			cargo_lines[i] = 'version = "${ver}"'
			cargo_version = true
			break
		}
	}
	if lck_is {
		cargo := parse_file(cargo_file)!
		name := cargo.value('package.name').string()
		name_line := 'name = "${name}"'
		mut this_package := false
		for i := 0; i < lck_lines.len; i++ {
			line := lck_lines[i]
			if this_package {
				if line.starts_with('name = "') {
					this_package = false
				} else if line.starts_with('version = "') {
					lck_lines[i] = 'version = "${ver}"'
					lck_version = true
					break
				}
			} else if line == name_line {
				this_package = true
			}
		}
	}

	if !cargo_version {
		return error('version not found in Cargo.toml')
	}
	if lck_is && !lck_version {
		return error('version not found in Cargo.lock')
	}

	if !opts.dry_run {
		write_lines_to_file(cargo_file, cargo_lines)!
		if lck_is {
			write_lines_to_file(lck_file, lck_lines)!
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
		println('updated version in "${rwd(cargo_file)}"${mode}')
	}
}

fn find_cargo() !(string, string) {
	return find_file('Cargo.toml') or { error('Cargo.toml not found') }
}

fn read_lines_from_file(file string) ![]string {
	dfile := d.rwd(file)
	d.log('reading file "%s"', dfile)
	lines := read_lines(file)!
	return lines
}

fn write_lines_to_file(file string, lines []string) ! {
	dfile := d.rwd(file)
	d.log('writing file "%s"', dfile)
	text := lines.join('\n')
	write_file(file, text)!
}
