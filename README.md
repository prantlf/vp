# V Package Manager

Helps with development, installation and maintenance of VPM packages.

## Synopsis

    # link the current module to the global ~./vmodules directory
    vp link

    # prepare the current module for publishing a new version
    # (update changelog, bump version, commit and tag the change)
    # and push it to the remote repository if confirmed by "y"
    vp publish -v

## Usage

    vp [options] <command> [parameters]

    Commands:
      link          links the current module to the global ~./vmodules directory
      unlink        remove the current module link from the global ~./vmodules
      version       prepare the current module for publishing a new version
                    (update changelog, bump version, commit and tag the change)
      publish       publish a new version prepared earlier by `vp version`
                    (push the change and tag, create a github release)
      release       perform both `vp version` and `vp publish`

    Parameters for link and unlink:
      [<pkg name>]  name of the package if guessing is not reliable

    Options for link and unlink:
      -f|--force    proceed even if the guessed package name was not reliable

    Parameters for publish:
      [<version>]   version if the changelog update is disabled
                    (also major, minor or patch for bumping the existing version)

    Options for version, publish and release:
      --no-changes       do not update the changelog
      --no-bump          do not bumpt the version in the package manifest
      --no-commit        do not commit the changes during publishing
      --no-tag           do not tag the commit during publishing
      --no-push          do not push the commit and tag during publishing
      --no-release       do not create a new github release
      --no-archives      do not upload platform archives automatically as assets
      --no-failure       do not fail in case of no version change or release
      -a|--assets <file> files to upload as extra assets to the github release
      -y|--yes           answer the push confirmation with "yes"
      -v|--verbose       print the new changes on the console too

    Common options:
      -V|--version  prints the version of the executable and exits
      -h|--help     prints the usage information and exits

## Linking

Let's develop two V modules:

    /sources/cargs     - command-line argument handling
    /sources/yaml2json - conversion from YAML to JSON

Case 1: let's make `yaml2json` depend on `cargs`. But `cargs` wasn't published yet. And we don't want to publish it before starting with `yaml2json`, because the command-line tool will help us to finalize the interface.

Case 2: we're fixing a bug in `cargs`, which was discovered when using `yaml2json`. It's convenient to confirm that everything works using the local `cargs` repository. Not only by adding a test to `cargs`, btu also by building and testing `yaml2json` with the locally modified `cargs`.

    cd /sources/cargs
    # link the cargs module to the global ~/.vmodules
    vp link

    cd /sources/yaml2json
    # build the yaml2json module with /sources/cargs linked via ~/.vmodules
    v .

## Publishing

Publishing a package usually means the following steps:

1. Update the changelog. One of the tools automating the task using the commit messages is [newchanges]:

```
❯ newchanges
discovered 1 significant commit from 1 total since v0.2.1
version 0.3.0 (2023-08-13) and 10 lines written to "./CHANGELOG.md"
```

2. Bump the version number if the package manifest:

```
❯ v bump --minor
Bumped version in v.mod
```

3. Commit the above changes:

```
❯ git commit -am "0.3.0 [skip ci]"
[master 0bea6c0] 0.3.0 [skip ci]

2 files changed, 12 insertions(+), 1 deletion(-)
```

4. Tag the above Commit:

```
❯ git tag -a v0.3.0 -m 0.3.0
```

5. Push the commit and the tag:

```
❯ git push --atomic origin HEAD v0.3.0
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 12 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 507 bytes | 507.00 KiB/s, done.
Total 3 (delta 2), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
To github.com:prantlf/v-yaml.git
32fffa8..b179a2d  master -> master
```

6. Create a new GitHub release.

### Improvement

All the commands above can be shortened with:

    ❯ vp release

That's how a new version of a library can be released from a local machine, once the last pushed productive change was built successfully.

### Pipeline

A new version can be published during the build job too, if it succeeds. The process is divided to two parts, one to be executed before the build and one after it:

1. Update the changelog and bump the version number in the source files:

```
❯ vp version --no-commit
```

2. Run the build and tests:

```
❯ make RELEASE=1
```

3. Commit and push the changes related to the new version and create a new release:

```
❯ vp publish
```

If the pipeline consists of multiple jobs, you can repeat the version bumping in the release job:

1. Build job: Update the changelog and bump the version number in the source files:

```
❯ vp version --no-commit
```

2. Build job: Run the build and tests:

```
❯ make RELEASE=1
```

3. Release job: Update the changelog and bump the version number in the source files, commit and push the changes related to the new version and create a new release:

```
❯ vp release
```

## Contributing

In lieu of a formal styleguide, take care to maintain the existing coding style. Lint and test your code.

## License

Copyright (c) 2023 Ferdinand Prantl

Licensed under the MIT license.

[newchanges]: https://github.com/prantlf/v-newchanges
