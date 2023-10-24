module main

import semver { Increment }

fn test_get_version_empty() {
	get_version('', 'v.mod') or {
		assert err.msg() == 'updating the changelog was disabled, specify the new version on the command line'
		return
	}
	assert false
}

fn test_get_version_invalid() {
	get_version('dummy', 'v.mod') or {
		assert err.msg() == 'Invalid version format for input "dummy"'
		return
	}
	assert false
}

fn test_get_version_actual() {
	assert get_version('1.0.0', 'v.mod')! == '1.0.0'
}

fn test_get_version_patch() {
	ver := semver.from(version)!.increment(Increment.patch).str()
	assert get_version('patch', 'v.mod')! == ver
}

fn test_get_version_minor() {
	ver := semver.from(version)!.increment(Increment.minor).str()
	assert get_version('minor', 'v.mod')! == ver
}

fn test_get_version_major() {
	ver := semver.from(version)!.increment(Increment.major).str()
	assert get_version('major', 'v.mod')! == ver
}

fn test_update_version_exists() {
	update_version('v.mod', '1.0.0', true, true, true, false)!
}

fn test_update_version_exists_but_same() {
	update_version('v.mod', '0.0.1', true, true, true, false)!
}

fn test_update_version_same() {
	update_version('v.mod', version, true, true, true, false) or {
		assert err.msg() == 'version ${version} already exists in "v.mod"'
		return
	}
	assert false
}

fn test_update_version_other_file() {
	update_version('src/vp.v', '1.0.0', true, true, true, false)!
}

fn test_update_version_not_exist() {
	update_version('Makefile', '1.0.0', true, true, true, false) or {
		assert err.msg() == 'version not found in "Makefile"'
		return
	}
	assert false
}

fn test_update_version_not_exist_but_not_required() {
	update_version('Makefile', '0.0.1', true, false, true, false)!
}
