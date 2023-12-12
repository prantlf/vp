# Changes

## [0.5.1](https://github.com/prantlf/vp/compare/v0.5.0...v0.5.1) (2023-12-12)

### Bug Fixes

* Fix listing dependencies ([abe590c](https://github.com/prantlf/vp/commit/abe590c6abfbcf84aaa2ad6075be680d45af53e4))

## [0.5.0](https://github.com/prantlf/vp/compare/v0.4.0...v0.5.0) (2023-12-12)

### Features

* Publish by npm if package.json is found ([00150e1](https://github.com/prantlf/vp/commit/00150e16af8adcc96bb6674105743efe3563cdb6))

## [0.4.0](https://github.com/prantlf/vp/compare/v0.3.0...v0.4.0) (2023-12-12)

### Features

* Bump version in package.json too, if it exists ([86d118e](https://github.com/prantlf/vp/commit/86d118e5edf312b100ab2148bc9d51f995ff37c0))
* Implement dependent and global module listing ([0c2b1d7](https://github.com/prantlf/vp/commit/0c2b1d780048561363f075b33982dd4f77748182))
* Build for Windows by cross-compiling ([f0b79d0](https://github.com/prantlf/vp/commit/f0b79d0576f1f9c17fc906e564232c2c884930da))
* Build for Windows by cross-compiling on Mac ([8c41eb3](https://github.com/prantlf/vp/commit/8c41eb340117cb5a54493aeb3f47097d2625c721))
* Disable Windows build ([9edce5b](https://github.com/prantlf/vp/commit/9edce5b317f798f1210c0739026aa3c0958bfcf2))

### Bug Fixes

* Declare BOOL on Windows properly ([bafa161](https://github.com/prantlf/vp/commit/bafa161e5262945fb7b3a2d0f9a954252d6fdcd7))

## [0.3.0](https://github.com/prantlf/vp/compare/v0.2.2...v0.3.0) (2023-10-24)

### Features

* Allow bumping version number in other files than v.mod ([9b8507b](https://github.com/prantlf/vp/commit/9b8507ba91f59616c1c7295a90c31784ef109cbf))
* Allow specifying cli options in config file ([e20e2e1](https://github.com/prantlf/vp/commit/e20e2e15c6b4a812fb6a7070b2c34a2b4512fc60))
* Allow configuring regexes for version detection and replacement ([b4a1f92](https://github.com/prantlf/vp/commit/b4a1f92601715859b36c1a2c2632e653c486d90d))
* Allow specifying github token in config file ([39aae3a](https://github.com/prantlf/vp/commit/39aae3a8e2eec5e07098b67fcd4f51e56e692161))

## [0.2.2](https://github.com/prantlf/vp/compare/v0.2.1...v0.2.2) (2023-10-23)

### Bug Fixes

* Do not cut off the last line in the published log ([f2e62ff](https://github.com/prantlf/vp/commit/f2e62ff2ba12613113a2a2dc9e1ddc98814878e7))

## [0.2.1](https://github.com/prantlf/vp/compare/v0.2.0...v0.2.1) (2023-10-23)

### Bug Fixes

* Recognise a github home page url as git url ([3ce8ade](https://github.com/prantlf/vp/commit/3ce8ade16301aec640259ccbd7e0ff4f6e344246))

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
