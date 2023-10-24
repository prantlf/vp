fn version_and_publish(version string, commit bool, tag bool, opts &Opts) ! {
	ver, log := create_version(version, commit, tag, opts)!
	if ver.len > 0 {
		do_publish(ver, log, opts)!
	}
}
