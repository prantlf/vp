module main

import os { getwd }

fn test_get_manifest() {
	cwd := getwd()
	dir, name, manifest := get_manifest()!
	assert dir == cwd
	assert name == '${cwd}${os.path_separator}v.mod'
	assert manifest.name == 'vp'
}
