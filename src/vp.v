import prantlf.cli { Cli, Env, run }

const version = '0.13.0'

const usage = 'Helps with development, installation and maintenance of VPM, NPM and Cargo packages.

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

Options and parameters for list:
  -g|--global   inspect contents of ~./vmodules (default is ./[src/]modules)
  [<pkg names>] names of the package to print its version

Parameters for link and unlink:
  [<pkg name>]  name of the package if guessing is not reliable

Options for link and unlink:
  -f|--force    proceed even if the guessed package name was not reliable

Parameters for version and publish:
  [<version>]   version if the changelog update is disabled (also major,
                minor, patch or pre to bump the current version)

Options for version, publish and release:
  --no-changes        do not update the changelog
  --no-bump           do not bump the version in the package manifest
  --no-vlang          do not version and publish using v and v.mod
  --no-node           do not version and publish using npm and package.json
  --no-rust           do not version and publish using rust and Cargo.toml
  --no-commit         do not commit the changes during publishing
  --no-commit-skip-ci do not add [skip ci] to the commit with the changes
  --no-tag            do not tag the commit during publishing
  --no-tag-skip-ci    do not add [skip ci] to the commit with the tag
  --no-push           do not push the commit and tag during publishing
  --no-release        do not create a new github release
  --no-archives       do not upload platform archives automatically as assets
  --no-failure        do not fail in case of no version change or release
  --nc-args <args>    extra arguments for newchanges, enclosed in quotes
  --pre-release       bump the existing pre-release number
  --pre-id <id>       first pre-release identifier (default: "next")
  -0|--bump-major-0   bump the major version also if it is 0
  -t|--tag-prefix <prefix> expect git tags prefixed (default: "v")
  -a|--assets <file>  files to upload as extra assets to the github release
  -b|--bump-files <file> extra files in which to bump the version
  -y|--yes            answer the push and reelase confirmations with "yes"
  -d|--dry-run        only print what would be done without doing it
  -v|--verbose        print the new changes on the console too

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
	vlang           bool = true
	node            bool = true
	rust            bool = true
	commit          ?bool
	commit_skip_ci  bool = true
	tag             ?bool
	tag_skip_ci     bool = true
	push            bool = true
	release         bool = true
	archives        bool = true
	failure         bool = true
	nc_args         string   @[json: 'nc-args']
	bump_major_0    bool     @[json: 'bump-major-0']
	pre_release     bool     @[json: 'pre-release']
	pre_id          string     = 'next'   @[json: 'pre-id']
	tag_prefix      string = 'v'   @[json: 'tag-prefix']
	assets          []string
	bump_files      []string @[json: 'bump-files'; split]
	yes             bool
	dry_run         bool     @[json: 'dry-run']
	verbose         bool
	version_detect  string  = r'version'   @[json: 'version-detect']
	version_replace string = r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-[.0-9A-Za-z-]+)?'   @[json: 'version-replace']
	gh_token        string   @[json: 'gh-token']
	npm_token       string   @[json: 'npm-token']
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
