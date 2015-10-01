# Backflip for iOS

Backflip is the best way to share photos with the crowd around you. Check into a nearby event, take and upload photos, and view the best content from everyone there.


### Requirements

- [ ] Xcode 7+ (Currently Swift 2.0 compatible)
- [ ] Device running iOS 8.3+
- [ ] Understanding of git [submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [ ] Whiskey
	

### Getting Started

- Clone repo (`git clone git@github.com:ibratanov/backflip.git`)
- Setup submodules (`git submodule update --init --recursive Vendor/`)
- Open Project (`open *.xcodeproj`)


## Release Cycle

### Branches

- `master` This is the current, most up to date (**stable**) AppStore build
- `develop` This is the current, most up to date (**unstable**) Testflight build. Never work on `develop` directly, always use a feature/bug branch and merge in (after adequate testing)
- `feat/bug-*` These are feature/bug branches, only commit and push these when required. 

### Committing

When pushing a commit with fixes for an issue, please reference that issue in your commit, for example:

	Updated camera for iOS 9, fixes #153
	
### AppStore

We ship every Friday, whatever is on `develop` and has been tested and marked stable, will be compiled; packaged and shipped off to Apple for review. Please ensure you have tested any code committed to `develop` to the best of your ability.


## Feature Flags

We take advantage of [feature flags](http://code.flickr.net/2009/12/02/flipping-out/), using them is super simple and quick to implement. If you look in [Supporting files/PrefixHEader.pch](https://github.com/ibratanov/backflip/blob/master/Supporting%20Files/PrefixHeader.pch) you can see how we define a "flag". We use feature flags as they make disabling / removing feature or sections quick and (mostly) pain free.
