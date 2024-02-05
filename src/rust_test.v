module main

import os { chdir, getwd, join_path_single }
import toml { parse_file }

fn test_find_cargo() {
	chdir('scripts')!
	cwd := getwd()
	dir, name := find_cargo()!
	chdir('..')!
	assert dir == cwd
	assert name == '${cwd}${os.path_separator}Cargo.toml'
}

fn test_read_cargo() {
	cargo_file := join_path_single('scripts', 'Cargo.toml')
	cargo := parse_file(cargo_file)!
	name := cargo.value('package.name').string()
	assert name == 'cargo'
}
