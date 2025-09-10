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
    echo "❌ ci_scripts directory not found in repository"
    echo "Please ensure the ci_scripts directory exists in your repo with the pre-commit hook"
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