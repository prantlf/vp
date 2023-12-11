import prantlf.cli { Cli, Env, run }

const version = '0.3.0'

const usage = 'Helps with development, installation and maintenance of VPM packages.

Usage: vp [options] <command> [parameters]

Commands:
  init          generate a config file with defaults
  ls|list       list modules installed in ~/.vmodules or ./modules
  link          link the current module to the global ~./vmodules directory
  unlink        remove the current module link from the global ~./vmodules
  version       prepare the current module for publishing a new version
                (update changelog, bump version, commit and tag the change)
  publish       publish a new version prepared earlier by `vp version`
                (push the change and tag, create a github release)
  release       perform both `vp version` and `vp publish`

Parameters for list:
  -g|--global   inspect contents of ~./vmodules (default is ./[src/]modules)
  [<pkg names>] names of the package to print its version

Parameters for link and unlink:
  [<pkg name>]  name of the package if guessing is not reliable

Options for link and unlink:
  -f|--force    proceed even if the guessed package name was not reliable

Parameters for version and publish:
  [<version>]   version if the changelog update is disabled
                (also major, minor or patch for bumping the existing version)

Options for version, publish and release:
  -c|--config <name> file name or path of the config file
  --no-changes       do not update the changelog
  --no-bump          do not bumpt the version in the package manifest
  --no-commit        do not commit the changes during publishing
  --no-tag           do not tag the commit during publishing
  --no-push          do not push the commit and tag during publishing
  --no-release       do not create a new github release
  --no-archives      do not upload platform archives automatically as assets
  --no-failure       do not fail in case of no version change or release
  -a|--assets <file> files to upload as extra assets to the github release
  -b|--bump-files <file> extra files in which to bump the version
  -y|--yes           answer the push and reelase confirmations with "yes"
  -d|--dry-run       only print what would be done without doing it
  -v|--verbose       print the new changes on the console too

Common options:
  -c|--config <name>  file name of path of the config file
  -V|--version        print the version of the executable and exits
  -h|--help           print the usage information and exits

Examples:
  $ vp link prantlf.cargs -f
  $ vp unlink
  $ vp publish -v'

struct Opts {
	global          bool
	force           bool
	changes         bool = true
	bump            bool = true
	commit          ?bool
	tag             ?bool
	push            bool = true
	release         bool = true
	archives        bool = true
	failure         bool = true
	assets          []string
	bump_files      []string @[json: 'bump-files'; split]
	yes             bool
	dry_run         bool     @[json: 'dry-run']
	verbose         bool
	version_detect  string  = r'version'   @[json: 'version-detect']
	version_replace string = r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)'   @[json: 'version-replace']
	gh_token        string   @[json: 'gh-token']
}

fn main() {
	run(Cli{
		usage: usage
		version: version
		options_anywhere: true
		cfg_opt: 'c'
		cfg_gen_arg: 'init'
		cfg_file: '.vp'
		env: Env.both
	}, body)
}

fn body(mut opts Opts, args []string) ! {
	if args.len == 0 {
		return error('Command is missing.')
	}

	command := args[0]
	first_arg := if args.len > 1 {
		args[1]
	} else {
		''
	}
	rest_args := if args.len > 1 {
		args[1..]
	} else {
		[]string{}
	}

	match command {
		'ls', 'list' {
			if opts.global {
				list_global(rest_args)!
			} else {
				list(rest_args)!
			}
		}
		'link' {
			link_path, module_dir := get_link(first_arg, opts.force)!
			link(link_path, module_dir, opts.force)!
		}
		'unlink' {
			link_path, module_dir := get_link(first_arg, opts.force)!
			unlink(link_path, module_dir, opts.force)!
		}
		'version' {
			commit := opts.commit or { true }
			tag := opts.tag or { true }
			create_version(first_arg, commit, tag, &opts)!
		}
		'publish' {
			commit := opts.commit or { false }
			tag := opts.tag or { false }
			publish(commit, tag, &opts)!
		}
		'release' {
			commit := opts.commit or { true }
			tag := opts.tag or { true }
			version_and_publish(first_arg, commit, tag, &opts)!
		}
		else {
			return error('Command "${command}" is invalid.')
		}
	}
}
