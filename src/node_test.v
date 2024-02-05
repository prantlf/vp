module main

import os { chdir, getwd, join_path_single }

fn test_find_package() {
	chdir('src')!
	cwd := getwd()
	dir, name := find_package()!
	chdir('..')!
	assert dir == cwd
	assert name == '${cwd}${os.path_separator}package.json'
}

fn test_read_json() {
	pkg_file := join_path_single('src', 'package.json')
	any := read_json(pkg_file)!
	assert any.get('name')!.string()! == 'package'
}
