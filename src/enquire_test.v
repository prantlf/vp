module main

import os { chdir, getwd }

fn test_find_file_curdir() {
	cwd := getwd()
	dir, name := find_file('v.mod')!
	assert dir == cwd
	assert name == '${cwd}${os.path_separator}v.mod'
}

fn test_find_file_subdir() {
	cwd := getwd()
	chdir('src')!
	dir, name := find_file('v.mod')!
	chdir('..')!
	assert dir == cwd
	assert name == '${cwd}${os.path_separator}v.mod'
}

fn test_find_file_miss() {
	find_file('package.json') or { return }
	assert false
}

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

fn test_get_repo_url() {
	url, found := get_repo_url('.git')!
	assert url == 'git@github.com:prantlf/vp.git' || url == 'https://github.com/prantlf/vp'
	assert found == true
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
