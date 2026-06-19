#!/bin/sh
#
#  ci_post_clone.sh
#  Xcode Cloud runs this automatically after cloning the repository and before
#  the build/test actions. Quietbox's Xcode project is generated from
#  `project.yml` by XcodeGen and is gitignored, so a freshly-cloned checkout has
#  no `.xcodeproj`/scheme. This recreates it in the Xcode Cloud environment.
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
# to build without a Package.resolved (and won't resolve one itself). The .xcodeproj
# is generated, so its resolved file is too — drop our committed lock file into the
# exact path the build expects. Keep ci_scripts/Package.resolved in sync if the
# swift-sodium version in project.yml changes (regenerate + recopy locally).
SWIFTPM_DIR="Quietbox.xcodeproj/project.xcworkspace/xcshareddata/swiftpm"
mkdir -p "$SWIFTPM_DIR"
cp ci_scripts/Package.resolved "$SWIFTPM_DIR/Package.resolved"
