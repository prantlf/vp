import os { exists, join_path_single, vmodules_dir }
import toml { parse_file }
import v.vmod
import prantlf.debug { new_debug }
import prantlf.github { find_git, get_repo_path, get_repo_url }

const d = new_debug('vp')

const hint = ' - if you want to continue, specify the package name and force the operation'

fn get_link(forced_name string, force bool) !(string, string) {
	scope, name, module_dir, _ := analyse_module(force)!
	mut full_name := if name != '' {
		if scope == 'vlang' {
			name
		} else {
			'${scope}.${name}'
		}
	} else {
		''
	}
	d.log('inferred "%s" as the package name', full_name)

	if forced_name != '' {
		if full_name != '' && forced_name != full_name {
			if force {
				d.log('the entered package name "%s" differs from the inferred one "%s"',
					forced_name, full_name)
			} else {
				return error('the entered package name "${forced_name}" differs from the inferred one "${full_name}" - if you want to continue with the entered name, force the operation')
			}
		}
		full_name = forced_name
	}
	if full_name == '' {
		return error('the package name cannot be inferred from the git configuration - if you want to continue, enter one explicitly and force the operation')
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

fn find_package_file(opts &Opts) (bool, bool, bool, bool, string) {
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

	cdir := if opts.rust {
		if vdir.len != 0 {
			cargo_file := join_path_single(vdir, 'Cargo.toml')
			if exists(cargo_file) {
				vdir
			} else {
				''
			}
		} else {
			n, _ := find_cargo() or { '', '' }
			n
		}
	} else {
		''
	}

	gdir := if opts.golang {
		if vdir.len != 0 {
			gomod_file := join_path_single(vdir, 'go.mod')
			if exists(gomod_file) {
				vdir
			} else {
				''
			}
		} else {
			n, _ := find_gomod() or { '', '' }
			n
		}
	} else {
		''
	}

	return if vdir.len != 0 {
		true, ndir.len != 0, cdir.len != 0, gdir.len != 0, vdir
	} else if ndir.len != 0 {
		false, true, cdir.len != 0, gdir.len != 0, ndir
	} else if cdir.len != 0 {
		false, false, true, gdir.len != 0, cdir
	} else if gdir.len != 0 {
		false, false, false, true, gdir
	} else {
		false, false, false, false, ''
	}
}

fn get_current_version(vmod_dir string) !string {
	vmod_file := join_path_single(vmod_dir, 'v.mod')
	if exists(vmod_file) {
		manifest := read_manifest(vmod_file)!
		return manifest.version
	}

	pkg_file := join_path_single(vmod_dir, 'package.json')
	if exists(pkg_file) {
		pkg := read_json(pkg_file)!
		return if ver := pkg.object()!['version'] {
			ver.string()!
		} else {
			''
		}
	}

	cargo_file := join_path_single(vmod_dir, 'Cargo.toml')
	if exists(cargo_file) {
		cargo := parse_file(cargo_file)!
		return cargo.value('package.version').string()
	}

	gomod_file := join_path_single(vmod_dir, 'go.mod')
	if exists(gomod_file) {
		// TODO: Find the version of a go module.
		return ''
	}

	return error('neither v.mod nor package.json nor Cargo.toml nor go.mod was found')
}

fn get_name(opts &Opts) !string {
	vlang, node, rust, _, vmod_dir := find_package_file(opts)
	if vmod_dir == '' {
		return error('neither v.mod nor package.json nor Cargo.toml nor go.mod was found')
	}

	if vlang {
		vmod_file := join_path_single(vmod_dir, 'v.mod')
		manifest := read_manifest(vmod_file)!
		return manifest.name
	}

	if node {
		pkg_file := join_path_single(vmod_dir, 'package.json')
		pkg := read_json(pkg_file)!
		return if name := pkg.object()!['name'] {
			name.string()!
		} else {
			''
		}
	}

	if rust {
		cargo_file := join_path_single(vmod_dir, 'Cargo.toml')
		cargo := parse_file(cargo_file)!
		return cargo.value('package.name').string()
	}

	gomod_file := join_path_single(vmod_dir, 'go.mod')
	return read_gomod_name(gomod_file)!
}

fn find_git_repo() !string {
	git_path := find_git()!
	return get_repo_path(git_path)!
}

fn find_git_url() !string {
	git_path := find_git()!
	return get_repo_url(git_path)!
}
