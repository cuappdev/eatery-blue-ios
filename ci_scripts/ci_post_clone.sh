#!/bin/sh

#  ci_post_clone.sh
#  Eatery Blue
#
#  Created by Vin Bui on 10/9/23.
#

echo "Downloading Secrets"
brew install wget
cd $CI_WORKSPACE/ci_scripts
wget -O ../Eatery\ Blue/Supporting/GoogleService-Info.plist "$GOOGLE_SERVICE_PLIST"
wget -O ../Eatery\ Blue/Supporting/Keys.xcconfig "$KEYS"

# Trust swiftlint
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES

