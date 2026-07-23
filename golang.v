import os { read_lines }
import prantlf.osutil { find_file }

fn find_gomod() !(string, string) {
	return find_file('go.mod') or { error('go.mod not found') }
}

fn read_gomod_name(file string) !string {
	dfile := d.rwd(file)
	d.log('reading file "%s"', dfile)
	lines := read_lines(file)!
	if lines.len > 0 {
		line := lines[0]
		last_slash := line.last_index_u8(`/`)
		if last_slash > 0 {
			return line[last_slash + 1..]
		}
	}
	return ''
}
