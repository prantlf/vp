import os { exists, home_dir, is_dir, is_link, join_path, join_path_single, ls }

struct Module {
	name    string
	version string
	path    string
	deps    []string
	direct  bool
}

fn list(names []string) ! {
	scope, _, vmod_dir, manifest := analyse_module(true)!
	mut mdir := join_path_single(vmod_dir, 'modules')
	mut dmdir := d.rwd(mdir)
	d.log('check modules at "%s"', dmdir)
	if !exists(mdir) {
		mdir = join_path(vmod_dir, 'src', 'modules')
		dmdir = d.rwd(mdir)
		d.log('check modules at "%s"', dmdir)
	}

	gmdir := get_global_mdir()
	mut listed := []Module{cap: names.len}
	if exists(mdir) {
		list_modules('', mdir, names, mut listed)!
		deps := get_missing_deps(manifest.dependencies, listed)
		if deps.len > 0 {
			list_modules('', gmdir, deps, mut listed)!
		}
	} else {
		if manifest.dependencies.len > 0 {
			for name in names {
				mut found := false
				for dep in manifest.dependencies {
					if dep == name {
						found = true
						break
					}
				}
				if !found {
					return error('"${name}" not found')
				}
			}
			deps := get_dep_names(manifest.dependencies)
			list_modules('', gmdir, deps, mut listed)!
		} else if names.len > 0 {
			return error('"${names[0]}" not found')
		}
	}
	expand_modules(gmdir, mut listed)!

	mut name := if scope.len > 0 { '${scope}.${manifest.name}' } else { manifest.name }
	if manifest.version.len > 0 {
		name += '@${manifest.version}'
	}
	print_modules(name, listed)!
}

fn list_global(names []string) ! {
	mdir := get_global_mdir()

	mut listed := []Module{cap: names.len}
	if exists(mdir) {
		list_modules('', mdir, names, mut listed)!
	} else if names.len > 0 {
		return error('"${names[0]}" not found')
	}
	expand_modules(mdir, mut listed)!

	print_modules('global', listed)!
}

fn list_modules(scope string, mdir string, names []string, mut listed []Module) ! {
	dmdir := d.rwd(mdir)
	d.log('list children of "%s"', dmdir)
	dirs := ls(mdir)!

	scopes_or_names := if names.len == 0 {
		names
	} else if scope.len > 0 {
		get_only_names(names, scope)
	} else {
		get_scopes_and_names(names)
	}

	for dir in dirs {
		sdir := join_path_single(mdir, dir)
		if is_module(dir) && (names.len == 0 || scopes_or_names.contains(dir)) {
			collect_module(scope, dir, sdir, names, mut listed)!
		} else {
			d.log('ignore "%s"', dir)
		}
	}

	if scope.len == 0 {
		for name in names {
			if !contains_module(listed, name) {
				return error('"${name}" not found')
			}
		}
	}
}

fn expand_modules(mdir string, mut listed []Module) ! {
	for mod in listed {
		if mod.deps.len > 0 {
			for dep in mod.deps {
				name := get_dep_name(dep)
				if !contains_module(listed, name) {
					probe_module(name, mdir, mut listed)!
				}
			}
		}
	}
}

fn probe_module(name string, dir string, mut listed []Module) ! {
	mdir := get_module_path(dir, name)
	if !is_dir(mdir) {
		return error('missing "${mdir}"')
	}
	vmod_name := join_path_single(mdir, 'v.mod')
	if !exists(vmod_name) {
		return error('missing "v.mod" in "${mdir}"')
	}
	add_module(name, mdir, vmod_name, mut listed, false)!
}

fn collect_module(scope string, name string, dir string, names []string, mut listed []Module) ! {
	vmod_name := join_path_single(dir, 'v.mod')
	if !exists(vmod_name) {
		ddir := d.rwd(dir)
		d.log('missing "v.mod" in "%s"', ddir)
		list_modules(name, dir, names, mut listed)!
		return
	}

	full_name := if scope.len > 0 { '${scope}.${name}' } else { name }
	add_module(full_name, dir, vmod_name, mut listed, true)!
}

fn add_module(name string, dir string, vmod_name string, mut listed []Module, direct bool) ! {
	manifest := read_manifest(vmod_name)!
	path := if is_link(dir) {
		resolve_link(dir)!
	} else {
		dir
	}
	listed << Module{name, manifest.version, path, manifest.dependencies, direct}
}

fn get_global_mdir() string {
	hdir := home_dir()
	mdir := join_path_single(hdir, '.vmodules')
	dmdir := d.rwd(mdir)
	d.log('global modules at "%s"', dmdir)
	return mdir
}

fn is_module(dir string) bool {
	return is_dir(dir) && !(dir.starts_with('.') || dir == 'cache' || dir == 'vlib')
}

fn get_module(listed []Module, name string) ?Module {
	for mod in listed {
		if mod.name == name {
			return mod
		}
	}
	return none
}

fn contains_module(listed []Module, name string) bool {
	for mod in listed {
		if mod.name == name {
			return true
		}
	}
	return false
}

fn get_scopes_and_names(names []string) []string {
	mut scopes := []string{len: names.len}
	for i, name in names {
		dot := name.index_u8(`.`)
		scopes[i] = if dot > 0 { name[..dot] } else { name }
	}
	return scopes
}

fn get_only_names(names []string, scope string) []string {
	mut only_names := []string{cap: names.len}
	for name in names {
		dot := name.index_u8(`.`)
		if scope.len > 0 {
			if dot > 0 && scope == name[..dot] {
				only_names << name[dot + 1..]
			}
		} else if dot < 0 {
			only_names << name
		}
	}
	return only_names
}

fn get_dep_names(deps []string) []string {
	mut names := []string{len: deps.len}
	for i, name in deps {
		names[i] = get_dep_name(name)
	}
	return names
}

fn get_dep_name(name string) string {
	at := name.index_u8(`@`)
	return if at > 0 { name[..at] } else { name }
}

fn get_missing_deps(deps []string, listed []Module) []string {
	mut names := []string{cap: deps.len}
	for dep in deps {
		at := dep.index_u8(`@`)
		name := if at > 0 { dep[..at] } else { dep }
		if !contains_module(listed, name) {
			names << name
		}
	}
	return names
}

fn get_module_path(dir string, name string) string {
	dot := name.index_u8(`.`)
	return if dot > 0 {
		join_path(dir, name[..dot], name[dot + 1..])
	} else {
		join_path_single(dir, name)
	}
}

fn print_modules(name string, listed []Module) ! {
	println(name)
	if listed.len > 0 {
		mut last := listed.len
		for last > 0 {
			last--
			if listed[last].direct {
				break
			}
		}
		for i, mod in listed {
			if !mod.direct {
				continue
			}
			prefix := if i < last { '├─ ' } else { '└─ ' }
			print_line(prefix, mod)
			if mod.deps.len > 0 {
				indent := if i < last { '│  ' } else { '   ' }
				print_deps(mod, listed, indent)!
			}
		}
	} else {
		println('└─ (empty)')
	}
}

fn print_deps(mod &Module, listed []Module, indent string) ! {
	for i, dep in mod.deps {
		name := get_dep_name(dep)
		depmod := get_module(listed, name) or { return error('module "${name}" not found') }
		prefix := if i < mod.deps.len - 1 { '├─ ' } else { '└─ ' }
		print_line('${indent}${prefix}', depmod)
	}
}

fn print_line(prefix string, mod &Module) {
	mut line := prefix
	line += mod.name
	if mod.version.len > 0 {
		line += '@${mod.version}'
	}
	line += ' "${mod.path}"'
	println(line)
}
