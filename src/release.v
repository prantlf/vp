fn version_and_publish(version string, assets []string, changes bool, bump bool, commit bool, tag bool, push bool, release bool, upload bool, failure bool, yes bool, dry bool, verbose bool) ! {
	ver, log := create_version(version, changes, bump, commit, tag, failure, dry, verbose)!
	if ver.len > 0 {
		do_publish(ver, assets, log, push, release, upload, failure, yes, dry, verbose)!
	}
}
