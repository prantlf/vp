module main

import os { chdir, getwd }

fn test_find_package_file() {
	cwd := getwd()
	vlang, node, rust, golang, mod_dir := find_package_file(Opts{})
	assert vlang == true
	assert node == false
	assert rust == false
	assert golang == false
	assert mod_dir == cwd
}

fn test_get_current_version_manifest() {
	ver := get_current_version('.')!
	assert ver != ''
}

fn test_get_current_version_package() {
	ver := get_current_version('src')!
	assert ver == '0.0.1'
}

fn test_get_current_version_cargo() {
	ver := get_current_version('scripts')!
	assert ver == '0.1.0'
}

fn test_get_name_manifest() {
	name := get_name(Opts{})!
	assert name == 'vp'
}

fn test_get_name_package() {
	chdir('src')!
	name := get_name(Opts{ vlang: false })!
	chdir('..')!
	assert name == 'package'
}

fn test_get_name_cargo() {
	chdir('scripts')!
	name := get_name(Opts{ vlang: false, node: false, golang: false })!
	chdir('..')!
	assert name == 'cargo'
}

fn test_get_name_gomod() {
	chdir('.github')!
	name := get_name(Opts{ vlang: false, node: false, rust: false })!
	chdir('..')!
	assert name == 'gomod'
}
