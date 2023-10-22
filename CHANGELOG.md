# Changes

## [0.1.0](https://github.com/prantlf/vp/compare/v0.0.1...v0.1.0) (2023-10-22)

### Features

* Upload shelved assets to the new release automatically ([5026796](https://github.com/prantlf/vp/commit/502679674c68290dc5c9ad0ed61115c095304a1a))

### Bug Fixes

* Support resolving symlinks on Windows (#1) ([b7bee66](https://github.com/prantlf/vp/commit/b7bee661041414dd041c38cfa2378ab34c2944d6))
* Fix crash in debug logging ([2084100](https://github.com/prantlf/vp/commit/208410075afb1cbaf8cc2b6f30dd334d50069889))

### BREAKING CHANGES

However unlikely, if you happen to have an archive `{name}-{platform}-x64.zip` in the project directory, it will be automatically upload to the newly created release. If you want to prevent it, add the argument `--no-archives` to the command line.

## 0.0.1 (2023-10-22)

Initial release.
