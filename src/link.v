import os { exists, is_dir, is_link, rm, rmdir_all, symlink }
import prantlf.debug { rwd }

fn link(link_path string, module_dir string, force bool) ! {
	dlink_path := d.rwd(link_path)
	d.log('checking existence of "%s"', dlink_path)
	if exists(link_path) {
		d.log('checking if "%s" is a link', dlink_path)
		if is_link(link_path) {
			target_path := resolve_link(link_path)!
			if module_dir == target_path {
				println('the link "${rwd(link_path)}" already points to this module directory')
				return
			}

			if !force {
				return error('a link "${rwd(link_path)}" already points to "${rwd(target_path)}" - if you want to replace it, force the operation')
			}
			println('removing the link "${rwd(link_path)}"')
			rm(link_path)!
		} else if is_dir(link_path) {
			println('removing the directory "${rwd(link_path)}"')
			rmdir_all(link_path)!
		}
	}

	println('creating the link "${rwd(link_path)}"')
	symlink(module_dir, link_path)!
}
