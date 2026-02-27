#!/bin/sh

#  ci_post_clone.sh
#  Eatery Blue
#
#  Created by Vin Bui on 10/9/23.
#

set -e

# Install Minio Client
curl -L -O https://dl.min.io/client/mc/release/darwin-amd64/mc
chmod +x mc

# Sync secrets from DigitalOcean Spaces
./mc alias set my-space https://nyc3.digitaloceanspaces.com "$SPACES_ACCESS_KEY_ID" "$SPACES_SECRET_ACCESS_KEY"
./mc mirror my-space/appdev-upload/ios-secrets/eatery-blue/ "$CI_PRIMARY_REPOSITORY_PATH/Eatery Blue/Supporting"

# Trust swiftlint
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
