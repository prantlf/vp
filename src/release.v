fn version_and_publish(version string, assets []string, changes bool, bump bool, commit bool, tag bool, push bool, release bool, upload bool, failure bool, yes bool, verbose bool) ! {
	ver, log := create_version(version, changes, bump, commit, tag, failure, verbose)!
	if ver.len > 0 {
		do_publish(ver, assets, log, false, false, push, release, upload, failure, yes,
			verbose)!
	}
}
