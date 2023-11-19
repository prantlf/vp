import os { last_error }
import prantlf.debug { rwd }

fn C.readlink(pathname &char, buf &char, bufsiz usize) int

fn resolve_link(path string) !string {
	dpath := d.rwd(path)
	d.log('resolving the link "%s"', dpath)
	mut result := [os.max_path_len + 1]u8{}
	len := C.readlink(path.str, &result[0], os.max_path_len)
	if len < 0 {
		return error('resolving the link "${rwd(path)}" failed: ${last_error()}')
	}
	full_path := unsafe { (&result[0]).vstring_with_len(len).clone() }
	dfull_path := d.rwd(full_path)
	d.log('resolved to "%s"', dfull_path)
	return full_path
}
