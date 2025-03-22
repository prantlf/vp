fn version_and_publish(version string, commit bool, tag bool, opts &Opts) ! {
	ver, log := create_version(version, commit, tag, opts)!
	if ver != '' {
		do_publish(ver, log, opts)!
	}
}
