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

set -e

echo "▸ ci_post_clone: ensuring XcodeGen is installed"
if ! command -v xcodegen >/dev/null 2>&1; then
  brew install xcodegen
fi

echo "▸ ci_post_clone: generating Quietbox.xcodeproj from project.yml"
cd "$CI_PRIMARY_REPOSITORY_PATH"
xcodegen generate

echo "▸ ci_post_clone: done"
