import os { join_path_single }
import prantlf.osutil { find_file }
import v.vmod { Manifest, from_file }

fn get_manifest_version(vmod_dir string) !string {
	vmod_name := join_path_single(vmod_dir, 'v.mod')
	manifest := read_manifest(vmod_name)!
	return manifest.version
}

fn find_manifest() !(string, string) {
	return find_file('v.mod') or {
		error('v.mod not found')
	}
}

fn get_manifest() !(string, string, Manifest) {
	vmod_dir, vmod_name := find_manifest()!
	manifest := read_manifest(vmod_name)!
	return vmod_dir, vmod_name, manifest
}

fn read_manifest(vmod_file string) !Manifest {
	dvmod_file := d.rwd(vmod_file)
	d.log('reading manifest "%s"', dvmod_file)
	return from_file(vmod_file)!
}
