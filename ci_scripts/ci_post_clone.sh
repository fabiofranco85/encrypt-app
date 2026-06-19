#!/bin/sh
#
#  ci_post_clone.sh
#  Xcode Cloud runs this automatically after cloning the repository and before
#  the build/test actions. Quietbox's Xcode project is generated from
#  `project.yml` by XcodeGen and is gitignored, so a freshly-cloned checkout has
#  no `.xcodeproj`/scheme to build. This regenerates it in the Xcode Cloud
#  environment.
#
#  Not used by local builds or the GitHub Actions CI — both already run
#  `xcodegen generate` themselves.

set -ex

# Put Homebrew (and anything it installs, like xcodegen) on PATH. Xcode Cloud's
# default script PATH doesn't include it, so `xcodegen` would be "command not
# found" right after install. Xcode Cloud runners are Apple Silicon (/opt/homebrew).
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

brew install xcodegen

# Generate Quietbox.xcodeproj from project.yml at the repo root.
cd "$CI_PRIMARY_REPOSITORY_PATH"
xcodegen generate
