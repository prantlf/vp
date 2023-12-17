module main

import os { chdir, getwd }

fn test_find_manifest_or_package() {
	cwd := getwd()
	vlang, node, mod_dir := find_manifest_or_package(Opts{})
	assert vlang == true
	assert node == false
	assert mod_dir == cwd
}

fn test_get_current_version_manifest() {
	ver := get_current_version('.')!
	assert ver.len > 0
}

fn test_get_current_version_package() {
	ver := get_current_version('src')!
	assert ver == '0.0.1'
}

fn test_get_name_manifest() {
	name := get_name(Opts{})!
	assert name == 'vp'
}

fn test_get_name_package() {
	chdir('src')!
	name := get_name(Opts{ vlang: false })!
	chdir('..')!
	assert name == 'dummy'
}
