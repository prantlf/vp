module main

import semver { Increment }
import prantlf.pcre { pcre_compile }

const test_opts = Opts{
	dry_run: true
}
const test_re_vertxt = pcre_compile('version', pcre.opt_caseless) or { panic('re_vertxt') }
const test_re_vernum = pcre_compile(r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)', 0) or {
	panic('re_vernum')
}

fn test_get_next_version_empty() {
	get_next_version('', '.') or {
		assert err.msg() == 'updating the changelog was disabled, specify the new version on the command line'
		return
	}
	assert false
}

fn test_get_next_version_invalid() {
	get_next_version('dummy', '.') or {
		assert err.msg() == 'Invalid version format for input "dummy"'
		return
	}
	assert false
}

fn test_get_next_version_actual() {
	assert get_next_version('1.0.0', '.')! == '1.0.0'
}

fn test_get_next_version_patch() {
	ver := semver.from(version)!.increment(Increment.patch).str()
	assert get_next_version('patch', '.')! == ver
}

fn test_get_next_version_minor() {
	ver := semver.from(version)!.increment(Increment.minor).str()
	assert get_next_version('minor', '.')! == ver
}

fn test_get_next_version_major() {
	ver := semver.from(version)!.increment(Increment.major).str()
	assert get_next_version('major', '.')! == ver
}

fn test_update_version_exists() {
	update_version('v.mod', test_re_vertxt, test_re_vernum, '1.0.0', true, &test_opts)!
}

fn test_update_version_exists_but_same() {
	update_version('v.mod', test_re_vertxt, test_re_vernum, '0.0.1', true, &test_opts)!
}

fn test_update_version_same() {
	update_version('v.mod', test_re_vertxt, test_re_vernum, version, true, &test_opts) or {
		assert err.msg() == 'version ${version} already exists in "v.mod"'
		return
	}
	assert false
}

fn test_update_version_other_file() {
	update_version('src/vp.v', test_re_vertxt, test_re_vernum, '1.0.0', true, &test_opts)!
}

fn test_update_version_not_exist() {
	update_version('Makefile', test_re_vertxt, test_re_vernum, '1.0.0', true, &test_opts) or {
		assert err.msg() == 'version not found in "Makefile"'
		return
	}
	assert false
}

fn test_update_version_not_exist_but_not_required() {
	update_version('Makefile', test_re_vertxt, test_re_vernum, '0.0.1', false, &test_opts)!
}
