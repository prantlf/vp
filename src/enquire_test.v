module main

import os { chdir, getwd }

fn test_find_manifest_or_package_or_cargo() {
	cwd := getwd()
	vlang, node, rust, mod_dir := find_manifest_or_package_or_cargo(Opts{})
	assert vlang == true
	assert node == false
	assert rust == false
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
	name := get_name(Opts{ vlang: false, node: false })!
	chdir('..')!
	assert name == 'cargo'
}
