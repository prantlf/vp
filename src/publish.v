import os { ls, read_file }
import prantlf.github {
	create_release,
	cut_repo_path,
	find_git,
	get_gh_token,
	get_release,
	get_repo_url,
	is_github,
	is_gitlab,
	upload_asset,
}
import prantlf.json { parse }
import prantlf.osutil { ExecuteOpts, execute, execute_opt }
import prantlf.strutil { last_line_not_empty, until_one_but_last_line_not_empty }

fn publish(commit bool, tag bool, opts &Opts) ! {
	ver, log := if opts.release {
		get_last_version(opts)!
	} else {
		_, _, _, _, vmod_dir := find_package_file(opts)
		if vmod_dir == '' {
			return error('neither v.mod nor package.json nor Carego.toml nor go.mod was found')
		}
		get_current_version(vmod_dir)!, ''
	}
	if ver != '' {
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

	mut repo_path, mut repo_url, gh_token := if opts.release {
		git_path := find_git()!
		git_url := get_repo_url(git_path)!
		repo := cut_repo_path(git_url)!
		if is_github(git_url) {
			token := if opts.gh_token != '' {
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
			repo, git_url, token
		} else {
			repo, git_url, ''
		}
	} else {
		'', '', ''
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
			push_skip_ci := if opts.push_skip_ci {
				if repo_url == '' {
					repo_url = find_git_url()!
				}
				if is_gitlab(repo_url) {
					' -o ci.skip'
				} else {
					''
				}
			} else {
				''
			}
			out := execute('git push --atomic${no_verify}${push_skip_ci} origin HEAD "${opts.tag_prefix}${ver}"')!
			d.log_str(out)
			eprintln('')
		}
		println('pushed version ${ver}${mode}')
	}

	if opts.release {
		if repo_url == '' {
			repo_url = find_git_url()!
		}
		if is_github(repo_url) {
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
}

fn was_released(repo string, token string, ver string, tag_prefix string) !bool {
	return get_release(repo, token, '${tag_prefix}${ver}')! != ''
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
		mut filtered := files.filter((it.ends_with('-arm64.zip') || it.ends_with('-riscv64.zip')
			|| it.ends_with('-x64.zip')) && it.starts_with(prefix))
		d.log('filtered %d archives from %d files', filtered.len, files.len)
		filtered
	} else {
		mut filtered := []string{cap: opts.assets.len}
		filtered
	}
	archives << opts.assets
	return archives
}
