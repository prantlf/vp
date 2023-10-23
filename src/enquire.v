import os
import v.vmod
import prantlf.debug { new_debug }
import prantlf.pcre { NoMatch, pcre_compile }

const d = new_debug('vp')

const hint = ' - if you want to continue, specify the package name and force the operation'

fn get_link(args []string, forced_name string, force bool) !(string, string) {
	scope, name, module_dir := analyse_module(force)!
	mut full_name := if name.len > 0 {
		if scope == 'vlang' {
			name
		} else {
			'${scope}.${name}'
		}
	} else {
		''
	}
	d.log('inferred "%s" as the package name', full_name)

	if forced_name.len > 0 {
		if full_name.len > 0 && forced_name != full_name {
			if force {
				d.log('the entered package name "%s" differs from the inferred one "%s"',
					forced_name, full_name)
			} else {
				return error('the entered package name "${forced_name}" differs from the inferred one "${full_name}" - if you want to continue with the entered name, force the operation')
			}
		}
		full_name = forced_name
	}
	if full_name.len == 0 {
		return error('the package name cannot be inferred fron the git configuration - if you want to continue, enter one explicitly and force the operation')
	}

	link_path := os.join_path_single(os.vmodules_dir(), full_name.replace('.', os.path_separator))
	dlink_path := d.rwd(link_path)
	dmodule_dir := d.rwd(module_dir)
	d.log('link "%s" computed for the directory "%s"', dlink_path, dmodule_dir)
	return link_path, module_dir
}

fn find_manifest() !(string, string) {
	return find_file('v.mod')!
}

fn get_manifest() !(string, string, vmod.Manifest) {
	vmod_dir, vmod_name := find_manifest()!
	manifest := read_manifest(vmod_name)!
	return vmod_dir, vmod_name, manifest
}

fn read_manifest(vmod_file string) !vmod.Manifest {
	dvmod_file := d.rwd(vmod_file)
	d.log('reading manifest "%s"', dvmod_file)
	return vmod.from_file(vmod_file)!
}

fn analyse_module(force bool) !(string, string, string) {
	vmod_dir, _, manifest := get_manifest()!

	_, git_path := find_file('.git') or {
		if force {
			d.log_str('missing ".git" directory')
			return '', '', vmod_dir
		} else {
			return error('missing ".git"${hint}')
		}
	}
	mut url, found := get_repo_url(git_path)!
	if !found {
		if force {
			d.log_str('missing git repository url')
		} else {
			return error('url in ".git/config" not detected${hint}')
		}
	}

	if url.starts_with('git@') && url.ends_with('.git') {
		url = url[..url.len - 4]
	}
	re_name := pcre_compile(r'^.+github\.com[:/]([^/]+)/(.+)', 0) or { panic(err) }
	m := re_name.exec(url, 0) or {
		if err is NoMatch {
			if force {
				d.log_str('unsupported git repository url')
				return '', '', vmod_dir
			}
			return error('unsupported git url "${url}"${hint}')
		}
		return err
	}
	scope := m.group_text(url, 1) or { return unreachable() }
	name := m.group_text(url, 2) or { return unreachable() }

	// if name != manifest.name {
	// 	if force {
	// 		d.log('name from the manifest "%s" differs from the repository "%s"', manifest.name,
	// 			name)
	// 	} else {
	// 		return error('name from the manifest "${manifest.name}" differs from the repository "${name}"${hint}')
	// 	}
	// }
	if name != manifest.name {
		d.log('name from the manifest "%s" differs from the repository "%s"', manifest.name,
			name)
	}
	dvmod_dir := d.rwd(vmod_dir)
	d.log('module "%s.%s" found in "%s"', scope, manifest.name, dvmod_dir)
	return scope, manifest.name, vmod_dir
}

fn get_repo_url(path string) !(string, bool) {
	file := os.join_path_single(path, 'config')
	dfile := d.rwd(file)
	d.log('reading file "%s"', dfile)
	lines := os.read_lines(file)!

	mut re_url := pcre_compile(r'\s*url\s*=\s*(.+)$', 0) or { panic(err) }
	for line in lines {
		d.log('looking for url in "%s"', line)
		if m := re_url.exec(line, 0) {
			url := m.group_text(line, 1) or { return unreachable() }
			d.log('url "%s" found', url)
			return url, true
		}
	}

	d.log_str('no url found')
	return '', false
}

fn find_file(name string) !(string, string) {
	mut dir := os.getwd()
	for i := 0; i < 10; i++ {
		mut file := os.join_path_single(dir, name)
		mut ddir := d.rwd(dir)
		d.log('checking if "%s" exists in "%s"', name, ddir)
		if os.exists(file) {
			dir = os.real_path(dir)
			ddir = d.rwd(dir)
			d.log('"%s" found in "%s"', name, ddir)
			file = os.join_path_single(dir, name)
			return dir, file
		}
		dir = os.join_path_single(dir, '..')
	}
	return error('"${name}" not found')
}

fn unreachable() IError {
	panic('unreachable code')
}
