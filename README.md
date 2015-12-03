# Backflip for iOS

[![Build status](https://badge.buildkite.com/ac01128a2b2b4ab64713fd7ba43d77300728a3293ad3f3c018.svg)](https://buildkite.com/yoshimi-robotics/backflip-for-ios)
![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)
[![volkswagen status](https://auchenberg.github.io/volkswagen/volkswargen_ci.svg?v=1)](https://github.com/auchenberg/volkswagen)
![Platforms](https://img.shields.io/badge/Platform-iOS%20%7C%20tvOS-lightgrey.svg)


Backflip is the best way to share photos with the crowd around you. Check into a nearby event, take and upload photos, and view the best content from everyone there.


### Requirements

- [ ] Xcode 7.1+ (Currently Swift 2.0 compatible)
- [ ] Device running iOS 8.3+
- [ ] Understanding of git [submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [ ] Whiskey
	

### Getting Started

- Clone repo (`git clone git@github.com:ibratanov/backflip.git`)
- Setup submodules (`git submodule update --init --recursive`)
- Open Project (`open *.xcodeproj`)


## Release Cycle

### Branches

- `master` This is the current, most up to date (**stable**) AppStore build
- `develop` This is the current, most up to date (**unstable**) Testflight build. Never work on `develop` directly, always use a feature/bug branch and merge in (after adequate testing)
- `feature/bug.*` These are feature/bug branches, only commit and push these when required. 

### Committing

When pushing a commit with fixes for an issue, please reference that issue in your commit, for example:

	Updated camera for iOS 9, fixes #153
	
### AppStore

We ship every Friday, whatever is on `develop` and has been tested and marked stable, will be compiled; packaged and shipped off to Apple for review. Please ensure you have tested any code committed to `develop` to the best of your ability.


## Feature Flags

We take advantage of [feature flags](http://code.flickr.net/2009/12/02/flipping-out/), using them is super simple and quick to implement. If you look in [Supporting files/PrefixHeader.pch](https://github.com/ibratanov/backflip/blob/master/Supporting%20Files/PrefixHeader.pch) you can see how we define a "flag". We use feature flags as they make disabling / removing feature or sections quick and (mostly) pain free.

## Project Management

### Managing Submodules

All submodules (both iOS and tvOS are managed in the .gitmodules file). New submodules are added by drag-and-dropping the project file for the submodule into a new "Group"(folder) in the Vendor directory in Xcode.
The framework should then be added to the Embedded Binaries section of the Project settings under Targets (for either iOS or tvOS). The framework should then appear under the Linked Frameworks and Libraries section.
