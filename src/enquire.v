import os { exists, join_path_single, vmodules_dir }
import v.vmod
import prantlf.debug { new_debug }
import prantlf.github { find_git, get_repo_path }

const d = new_debug('vp')

const hint = ' - if you want to continue, specify the package name and force the operation'

fn get_link(forced_name string, force bool) !(string, string) {
	scope, name, module_dir, _ := analyse_module(force)!
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

	link_path := join_path_single(vmodules_dir(), full_name.replace('.', os.path_separator))
	dlink_path := d.rwd(link_path)
	dmodule_dir := d.rwd(module_dir)
	d.log('link "%s" computed for the directory "%s"', dlink_path, dmodule_dir)
	return link_path, module_dir
}

fn analyse_module(force bool) !(string, string, string, vmod.Manifest) {
	vmod_dir, _, manifest := get_manifest()!

	git_path := find_git() or {
		if force {
			d.log_str(err.msg())
			return '', '', vmod_dir, manifest
		} else {
			return err
		}
	}
	mut repo_path := get_repo_path(git_path) or {
		if force {
			d.log_str(err.msg())
			return '', '', vmod_dir, manifest
		} else {
			return err
		}
	}

	split_path := repo_path.split('/')
	scope := split_path[0]
	name := split_path[1]

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
	return scope, manifest.name, vmod_dir, manifest
}

fn find_manifest_or_package(opts &Opts) (bool, bool, string) {
	vdir := if opts.vlang {
		v, _ := find_manifest() or { '', '' }
		v
	} else {
		''
	}
	ndir := if opts.node {
		if vdir.len != 0 {
			pkg_file := join_path_single(vdir, 'package.json')
			if exists(pkg_file) {
				vdir
			} else {
				''
			}
		} else {
			n, _ := find_package() or { '', '' }
			n
		}
	} else {
		''
	}
	return if vdir.len != 0 {
		true, ndir.len != 0, vdir
	} else if ndir.len != 0 {
		false, true, ndir
	} else {
		false, false, ''
	}
}

fn get_current_version(vmod_dir string) !string {
	vmod_file := join_path_single(vmod_dir, 'v.mod')
	return if exists(vmod_file) {
		manifest := read_manifest(vmod_file)!
		manifest.version
	} else {
		pkg_file := join_path_single(vmod_dir, 'package.json')
		if exists(pkg_file) {
			pkg := read_json(pkg_file)!
			if ver := pkg.object()!['version'] {
				ver.string()!
			} else {
				''
			}
		} else {
			error('neither v.mod nor package.json was found')
		}
	}
}

fn get_name(opts &Opts) !string {
	vlang, _, vmod_dir := find_manifest_or_package(opts)
	if vmod_dir.len == 0 {
		return error('neither v.mod nor package.json was found')
	}

	return if vlang {
		vmod_file := join_path_single(vmod_dir, 'v.mod')
		manifest := read_manifest(vmod_file)!
		manifest.name
	} else {
		pkg_file := join_path_single(vmod_dir, 'package.json')
		pkg := read_json(pkg_file)!
		if name := pkg.object()!['name'] {
			name.string()!
		} else {
			''
		}
	}
}
