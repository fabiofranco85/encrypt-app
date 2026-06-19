#!/bin/sh
#
#  ci_post_clone.sh
#  Xcode Cloud runs this automatically after cloning the repository and before
#  the build/test actions. Quietbox's Xcode project is generated from
#  `project.yml` by XcodeGen and is gitignored, so a freshly-cloned checkout has
#  no `.xcodeproj`/scheme and no resolved Swift packages. This recreates both in
#  the Xcode Cloud environment.
#
#  Not used by local builds or the GitHub Actions CI — both already run
#  `xcodegen generate` themselves.

set -ex

# Put Homebrew (and anything it installs, like xcodegen) on PATH. Xcode Cloud's
# default script PATH doesn't include it. Runners are Apple Silicon (/opt/homebrew).
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

brew install xcodegen

cd "$CI_PRIMARY_REPOSITORY_PATH"

# Generate Quietbox.xcodeproj from project.yml.
xcodegen generate

# Xcode Cloud builds with automatic Swift Package resolution DISABLED and refuses
# to build without a Package.resolved. The generated project ships none, so
# resolve here — this writes Package.resolved to the exact path the build expects
# (Quietbox.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved).
xcodebuild -resolvePackageDependencies -project Quietbox.xcodeproj -scheme Quietbox
