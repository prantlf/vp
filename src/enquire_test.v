module main

import v.vmod

fn test_get_manifest() {
	dir, name, manifest := get_manifest()!
	assert dir == '.'
	assert name == 'v.mod'
	assert manifest is vmod.Manifest
}
