# Changes

## [0.14.5](https://github.com/prantlf/vp/compare/v0.14.4...v0.14.5) (2024-04-14)

### Bug Fixes

* Pass bump-major-0 to newchanges ([2a70724](https://github.com/prantlf/vp/commit/2a707244ab013c209473fe5f587c97aba51942dd))

## [0.14.4](https://github.com/prantlf/vp/compare/v0.14.3...v0.14.4) (2024-04-02)

### Bug Fixes

* Insert --no-verify before -am in git commit ([8854d50](https://github.com/prantlf/vp/commit/8854d50b329c36fc377b772da38b88133159f959))

## [0.14.3](https://github.com/prantlf/vp/compare/v0.14.2...v0.14.3) (2024-04-02)

### Bug Fixes

* Reword the description of --pre-release ([de4f673](https://github.com/prantlf/vp/commit/de4f67383559f90ee471d371b17e62a4407850aa))

## [0.14.2](https://github.com/prantlf/vp/compare/v0.14.1...v0.14.2) (2024-04-02)

### Bug Fixes

* Correct recognition of GitHub and GitLab URLs ([17e3f0a](https://github.com/prantlf/vp/commit/17e3f0a178b547f1c45b02a26a623728fda25cb2))

## [0.14.1](https://github.com/prantlf/vp/compare/v0.14.0...v0.14.1) (2024-03-31)

### Bug Fixes

* Enable github releases only for github repositories ([733cd84](https://github.com/prantlf/vp/commit/733cd84c6f8c921a36fab5e92d74b6cdbb1cec0f))

## [0.14.0](https://github.com/prantlf/vp/compare/v0.13.0...v0.14.0) (2024-03-30)

### Features

* Allow using --no-verify for disabling git hooks ([6ad6766](https://github.com/prantlf/vp/commit/6ad676674a9147cad1861f7b9dfdc449bf5da53b))
* Allow using -o ci.skip for disabling gitlab pipeline ([4a23cec](https://github.com/prantlf/vp/commit/4a23cec51934eddfb80e9f7b46e6ee2c6881c806))

### Bug Fixes

* Add "skip ci" to commit and tag mesages only for github ([99ac8ac](https://github.com/prantlf/vp/commit/99ac8acce83330d3e4483d7c1e358ee89adf43e5))

## [0.13.0](https://github.com/prantlf/vp/compare/v0.12.1...v0.13.0) (2024-03-30)

### Features

* Allow specifying a tag prefix ([818fc38](https://github.com/prantlf/vp/commit/818fc38d3a42b3d2aee2182d9a6d1a0ec1fffded))
* Support pre-releases ([e48d55b](https://github.com/prantlf/vp/commit/e48d55b663b16670c905fbb8bab97dbb855f731b))

## [0.12.1](https://github.com/prantlf/vp/compare/v0.12.0...v0.12.1) (2024-02-12)

### Bug Fixes

* Upgrade dependencies ([0d1f5e6](https://github.com/prantlf/vp/commit/0d1f5e603910c6e005a59020fcd834ba6fc27ba7))

## [0.12.0](https://github.com/prantlf/vp/compare/v0.11.1...v0.12.0) (2024-02-05)

### Features

* Allow removing "skip ci" from the versioning commits ([514a15d](https://github.com/prantlf/vp/commit/514a15dd156b2076bccd126b33539d70ca5ea878))
* Allow versioning a Rust cargo ([8a08026](https://github.com/prantlf/vp/commit/8a08026c1f0356840689d6c5f31dc5c77007f4ce))

## [0.11.1](https://github.com/prantlf/vp/compare/v0.11.0...v0.11.1) (2024-01-01)

### Bug Fixes

* Adapt to changes on interface of json and yaml packages ([60c24de](https://github.com/prantlf/vp/commit/60c24deca7f5e7c3e07f457df4c0fab3c635314c))

## [0.11.0](https://github.com/prantlf/vp/compare/v0.10.0...v0.11.0) (2023-12-17)

### Features

* Authenticate npm using process environment ([e74d80b](https://github.com/prantlf/vp/commit/e74d80b7e9cfb566b1ba4f4a0f3bedfde67dd720))

## [0.10.0](https://github.com/prantlf/vp/compare/v0.9.0...v0.10.0) (2023-12-17)

### Features

* Propagate dry run to npm ([0114ad4](https://github.com/prantlf/vp/commit/0114ad449879bbb70df89c9097aee5ea4f68d97e))

### Bug Fixes

* Use proper parameter for npm verbosity ([f22f505](https://github.com/prantlf/vp/commit/f22f5057d2bf7f0d3fc5a5383f85042d1330edd4))

## [0.9.0](https://github.com/prantlf/vp/compare/v0.8.0...v0.9.0) (2023-12-15)

### Features

* Add the man file ([4fc210e](https://github.com/prantlf/vp/commit/4fc210ea616643e5d8949b17b004ce30ff3a9754))

## [0.8.0](https://github.com/prantlf/vp/compare/v0.7.2...v0.8.0) (2023-12-14)

### Features

* Allow specifying extra args for newchanges ([a4908e7](https://github.com/prantlf/vp/commit/a4908e73ab17fd7ea23c49b8732e7c8c2ee688b5))

## [0.7.2](https://github.com/prantlf/vp/compare/v0.7.1...v0.7.2) (2023-12-14)

### Bug Fixes

* Collect assets for publishing in pure Node.js projects too ([4d2dd9f](https://github.com/prantlf/vp/commit/4d2dd9f94f3e8c2deda4e3d4b6c9f1bdc893b629))

## [0.7.1](https://github.com/prantlf/vp/compare/v0.7.0...v0.7.1) (2023-12-14)

### Bug Fixes

* Fix adding the linux arm64 support ([5e656f0](https://github.com/prantlf/vp/commit/5e656f0fcba5a964452fabafe4bc52cd17a2a47b))

## [0.7.0](https://github.com/prantlf/vp/compare/v0.6.0...v0.7.0) (2023-12-14)

### Features

* Add arm64 linux support ([88977a9](https://github.com/prantlf/vp/commit/88977a9b2aa6795bd225cf857c8028997769c7be))

## [0.6.0](https://github.com/prantlf/vp/compare/v0.5.2...v0.6.0) (2023-12-14)

### Features

* Allow publishing a pure Node.js package ([201d23f](https://github.com/prantlf/vp/commit/201d23f81d5efe4f2df9b43903adde2cfd240ed4))

## [0.5.2](https://github.com/prantlf/vp/compare/v0.5.1...v0.5.2) (2023-12-12)

### Bug Fixes

* Do not check the version in package.json before publishing ([ac39753](https://github.com/prantlf/vp/commit/ac3975300c103f310d5604ee27e466c7cde01a28))

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
