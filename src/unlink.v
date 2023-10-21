import os
import prantlf.debug { rwd }

fn unlink(link_path string, module_dir string, force bool) ! {
	dlink_path := d.rwd(link_path)
	d.log('checking existence of "%s"', dlink_path)
	if os.exists(link_path) {
		d.log('checking if "%s" is a link', dlink_path)
		if os.is_link(link_path) {
			target_path := resolve_link(link_path)!
			if module_dir != target_path {
				if force {
					dtarget_path := d.rwd(target_path)
					dmodule_dir := d.rwd(module_dir)
					d.log('the link target "%s" is not point this module directory "%s"',
						dtarget_path, dmodule_dir)
				} else {
					return error('the link "${rwd(link_path)}" does not point to this module directory - if you want to remove it, force the operation')
				}
			}

			println('removing the link "${rwd(link_path)}"')
			os.rm(link_path)!
		} else {
			d.log('checking if "%s" is a directory', dlink_path)
			if os.is_dir(link_path) {
				return error('the path "${rwd(link_path)}" does not belong to a directory')
			} else {
				return error('the path "${rwd(link_path)}" does not belong to a link')
			}
		}
	} else {
		println('the link "${rwd(link_path)}" does not exist')
	}
}
