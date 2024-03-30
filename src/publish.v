import os { ls, read_file }
import prantlf.github { create_release, find_git, get_gh_token, get_release, get_repo_path, upload_asset }
import prantlf.json { parse }
import prantlf.osutil { ExecuteOpts, execute, execute_opt }
import prantlf.strutil { last_line_not_empty, until_one_but_last_line_not_empty }

fn publish(commit bool, tag bool, opts &Opts) ! {
	ver, log := if opts.release {
		get_last_version(opts)!
	} else {
		_, _, _, vmod_dir := find_manifest_or_package_or_cargo(opts)
		if vmod_dir.len == 0 {
			return error('neither v.mod nor package.json nor Carego.toml was found')
		}
		get_current_version(vmod_dir)!, ''
	}
	if ver.len > 0 {
		if commit {
			do_commit(ver, commit, tag, opts)!
		}
		do_publish(ver, log, opts)!
	}
}

fn get_last_version(opts &Opts) !(string, string) {
	out := execute_opt('newchanges -iv -t "${opts.tag_prefix}" ${opts.nc_args}', ExecuteOpts{
		trim_trailing_whitespace: true
	})!
	log := until_one_but_last_line_not_empty(out)
	line := last_line_not_empty(out)
	if opts.verbose {
		println(out)
	} else {
		println(line)
	}
	if line.starts_with('no ') {
		msg := 'version not found'
		if opts.failure {
			return error(msg)
		}
		println(msg)
		return '', ''
	}
	ver := if m := re_verline.exec(line, 0) {
		m.group_text(line, 1) or { panic(err) }
	} else {
		return error('unexpected output of newchanges: "${line}"')
	}

	return ver, log
}

fn do_publish(ver string, log string, opts &Opts) ! {
	if opts.node {
		publish_package(ver, opts)!
	}

	repo_path, gh_token := if opts.release {
		path := find_git()!
		repo := get_repo_path(path)!
		token := if opts.gh_token.len > 0 {
			opts.gh_token
		} else {
			get_gh_token()!
		}
		if was_released(repo, token, ver, opts.tag_prefix)! {
			msg := 'version ${ver} has been already released'
			if opts.failure {
				return error(msg)
			}
			println(msg)
			return
		}
		repo, token
	} else {
		'', ''
	}

	mode := if opts.dry_run {
		' (dry-run)'
	} else {
		''
	}

	if opts.push && (opts.yes || confirm('push version ${ver}${mode}')!) {
		if !opts.dry_run {
			no_verify := if opts.verify {
				''
			} else {
				' --no-verify'
			}
			out := execute('git push --atomic${no_verify} origin HEAD "${opts.tag_prefix}${ver}"')!
			d.log_str(out)
			eprintln('')
		}
		println('pushed version ${ver}${mode}')
	}

	if opts.release {
		archives := collect_assets(opts)!
		mut suffix := if archives.len > 0 {
			' with ${archives.join(', ')}'
		} else {
			''
		}
		if opts.yes || confirm('release version ${ver}${suffix}${mode}')! {
			if !opts.dry_run {
				post_release(repo_path, gh_token, ver, opts.tag_prefix, log, archives)!
			}
			if !opts.yes {
				suffix = ''
			}
			println('released version ${ver}${suffix}${mode}')
		}
	}
}

fn was_released(repo string, token string, ver string, tag_prefix string) !bool {
	return get_release(repo, token, '${tag_prefix}${ver}')!.len > 0
}

fn post_release(repo string, token string, ver string, tag_prefix string, log string, assets []string) ! {
	body := create_release(repo, token, '${tag_prefix}${ver}', ver, log)!
	params := parse(body)!.object()!
	id := params['id']!.int()!
	for asset in assets {
		data := read_file(asset)!
		upload_asset(repo, token, id, asset, data, 'application/zip')!
	}
}

fn collect_assets(opts &Opts) ![]string {
	mut archives := if opts.archives {
		name := get_name(opts)!
		prefix := '${name}-'
		d.log_str('listing files in the current directory')
		files := ls('.')!
		filtered := files.filter((it.ends_with('-arm64.zip') || it.ends_with('-x64.zip'))
			&& it.starts_with(prefix))
		d.log('filtered %d archives from %d files', filtered.len, files.len)
		filtered
	} else {
		[]string{cap: opts.assets.len}
	}
	archives << opts.assets
	return archives
}
