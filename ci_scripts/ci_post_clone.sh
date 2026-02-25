#!/bin/sh

#  ci_post_clone.sh
#  Eatery Blue
#
#  Created by Vin Bui on 10/9/23.
#

brew install awscli

export AWS_ACCESS_KEY_ID="$SPACES_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$SPACES_SECRET_ACCESS_KEY"

aws s3 sync \
    s3://appdev-upload/ios-secrets/eatery-blue/ \
    "$CI_WORKSPACE/Eatery Blue/Supporting" \
    --endpoint-url=https://nyc3.digitaloceanspaces.com \
    --no-progress 2>&1 | grep -v "Is a directory"

# Trust swiftlint
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidation -bool YES