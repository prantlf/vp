# Changes

## [0.2.0](https://github.com/prantlf/vp/compare/v0.1.4...v0.2.0) (2023-10-23)

### Features

* Implement dry-run ([c523d2d](https://github.com/prantlf/vp/commit/c523d2d48e726d7a55d1439ce0275ef3d1efa254))

## [0.1.4](https://github.com/prantlf/vp/compare/v0.1.3...v0.1.4) (2023-10-22)

### Bug Fixes

* Have newchanges try fetching the missing history ([3b3096f](https://github.com/prantlf/vp/commit/3b3096fe7ce5131941a0562804be2f584c816b43))

## [0.1.3](https://github.com/prantlf/vp/compare/v0.1.2...v0.1.3) (2023-10-22)

### Bug Fixes

* Add release assets to be uploaded to the prompt ([21e6da7](https://github.com/prantlf/vp/commit/21e6da788894cfad37a8fa6da1679ad63365ff27))

## [0.1.2](https://github.com/prantlf/vp/compare/v0.1.1...v0.1.2) (2023-10-22)

### Bug Fixes

* Include assets in the release confirm prompt ([9b381be](https://github.com/prantlf/vp/commit/9b381bee1e69c8602561a5c350e0ebc42cdc521c))

## [0.1.1](https://github.com/prantlf/vp/compare/v0.1.0...v0.1.1) (2023-10-22)

### Bug Fixes

* Ask for both pushing and releasing separately ([f33a3ca](https://github.com/prantlf/vp/commit/f33a3ca5ffe8e03bff024f84050debdd4a6fc6f4))
* Do not fail if newchanges cannot find any commit ([037d825](https://github.com/prantlf/vp/commit/037d82509491b8cddc2960452208cef8f9105fa0))

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
