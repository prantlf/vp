module main

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
	assert get_version('patch', 'v.mod')! == '0.0.2'
}

fn test_get_version_minor() {
	assert get_version('minor', 'v.mod')! == '0.1.0'
}

fn test_get_version_major() {
	assert get_version('major', 'v.mod')! == '1.0.0'
}

fn test_update_version_exists() {
	update_version('v.mod', '1.0.0', true, true)!
}

fn test_update_version_exists_but_same() {
	update_version('v.mod', '0.0.1', true, true)!
}

fn test_update_version_same() {
	update_version('v.mod', '0.0.1', true, true) or {
		assert err.msg() == 'version already exists in "v.mod"'
		return
	}
	assert false
}

fn test_update_version_not_exist() {
	update_version('Makefile', '1.0.0', true, true) or {
		assert err.msg() == 'version not found in "Makefile"'
		return
	}
	assert false
}

fn test_update_version_not_exist_but_not_required() {
	update_version('Makefile', '0.0.1', false, true)!
}
