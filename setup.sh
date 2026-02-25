#!/bin/bash

echo "🔧 Setting up development environment for Eatery Blue..."
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check if Homebrew package is installed
brew_package_installed() {
    brew list "$1" &> /dev/null
}

# Check if Homebrew is installed
if ! command_exists brew; then
    echo "❌ Homebrew is not installed."
    echo "Please install Homebrew first: https://brew.sh/"
    echo "Run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo "📦 Checking/installing SwiftFormat and SwiftLint..."

# Install or update SwiftFormat
if brew_package_installed swiftformat; then
    echo "  ✅ SwiftFormat already installed"
    brew upgrade swiftformat 2>/dev/null || true
else
    echo "  📥 Installing SwiftFormat..."
    brew install swiftformat
fi

# Install or update SwiftLint
if brew_package_installed swiftlint; then
    echo "  ✅ SwiftLint already installed"
    brew upgrade swiftlint 2>/dev/null || true
else
    echo "  📥 Installing SwiftLint..."
    brew install swiftlint
fi

echo ""
echo "🪝 Configuring git hooks..."

# Ensure ci_scripts directory exists
if [ ! -d "ci_scripts" ]; then
    echo "❌ .githooks directory not found in repository"
    echo "Please ensure the .githooks directory exists in your repo with the pre-commit hook"
    exit 1
fi

# Make all hooks in ci_scripts executable
chmod +x ci_scripts/* 2>/dev/null || true

# Ensure .git/hooks directory exists
mkdir -p .git/hooks

# Copy pre-commit hook from ci_scripts to .git/hooks and make it executable
if [ -f "ci_scripts/pre-commit" ]; then
    echo "  🔧 Copying pre-commit hook to .git/hooks/"
    cp ci_scripts/pre-commit .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    echo "  ✅ Pre-commit hook installed successfully"
else
    echo "  ❌ ci_scripts/pre-commit not found"
    exit 1
fi

echo ""
echo "☁️  Setting up DigitalOcean Spaces credentials..."

# Check if AWS CLI is installed (needed for s3 commands)
if ! command_exists aws; then
    echo "  ❌ AWS CLI is not installed."
    echo "  Installing AWS CLI via Homebrew..."
    brew install awscli
fi

# Prompt for credentials
echo ""
echo "Please enter your DigitalOcean Spaces credentials:"
echo "(Find these pinned in the #ios channel on Slack)"
echo ""
read -p "Access Key ID: " ACCESS_KEY_ID
read -sp "Secret Access Key: " SECRET_ACCESS_KEY
echo ""

# Validate inputs
if [ -z "$ACCESS_KEY_ID" ] || [ -z "$SECRET_ACCESS_KEY" ]; then
    echo "❌ Both Access Key ID and Secret Access Key are required"
    exit 1
fi

# Create target directory if it doesn't exist
TARGET_DIR="Eatery Blue/Supporting"
if [ ! -d "$TARGET_DIR" ]; then
    echo "  📁 Creating directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

echo "  📥 Downloading files from DigitalOcean Spaces..."

# Configure AWS CLI for DigitalOcean Spaces
export AWS_ACCESS_KEY_ID="$ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$SECRET_ACCESS_KEY"

# Snapshot files before sync
BEFORE_FILES=$(ls -1 "$TARGET_DIR" 2>/dev/null | sort || true)

# Download all files from the bucket
aws s3 sync \
    s3://appdev-upload/ios-secrets/eatery-blue/ \
    "$TARGET_DIR" \
    --endpoint-url=https://nyc3.digitaloceanspaces.com \
    --no-progress 2>&1 | grep -v "Is a directory" || true

# Snapshot files after sync
AFTER_FILES=$(ls -1 "$TARGET_DIR" 2>/dev/null | sort || true)

# Find newly downloaded files by comparing before/after
NEW_FILES=$(comm -13 <(echo "$BEFORE_FILES") <(echo "$AFTER_FILES"))

if [ -n "$NEW_FILES" ]; then
    echo "  ✅ Files downloaded successfully to $TARGET_DIR"
    echo "  📄 Downloaded files from DigitalOcean:"
    echo "$NEW_FILES" | sed 's/^/     - /'
elif [ -n "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]; then
    echo "  ✅ All files already up-to-date in $TARGET_DIR"
else
    echo "  ❌ Failed to download files from DigitalOcean Spaces"
    echo "  Please check your credentials and try again"
    exit 1
fi

# Unset credentials from environment
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY

echo ""
echo "🔍 Verifying setup..."

# Verify tools are accessible
if command_exists swiftformat; then
    swiftformat_version=$(swiftformat --version)
    echo "  ✅ SwiftFormat: $swiftformat_version"
else
    echo "  ❌ SwiftFormat not found in PATH"
    exit 1
fi

if command_exists swiftlint; then
    swiftlint_version=$(swiftlint version)
    echo "  ✅ SwiftLint: $swiftlint_version"
else
    echo "  ❌ SwiftLint not found in PATH"
    exit 1
fi

# Check if pre-commit hook exists in .git/hooks
if [ -f ".git/hooks/pre-commit" ] && [ -x ".git/hooks/pre-commit" ]; then
    echo "  ✅ Pre-commit hook installed and executable"
else
    echo "  ❌ Pre-commit hook not found or not executable in .git/hooks/"
    exit 1
fi

# all set
echo "All set!"