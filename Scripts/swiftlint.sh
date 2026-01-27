#!/bin/sh

# Ensure Homebrew path on Apple Silicon
if [[ "$(uname -m)" == arm64 ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

# Move to project root
# cd "${SRCROOT}" || exit 0

# Print diagnostics
# echo "SwiftLint run script"
# which swiftlint || true
# swiftlint --version || true
pwd

# Only run if swiftlint is available
if command -v swiftlint >/dev/null 2>&1; then
    # Check for any Swift files under SRCROOT
   #if find . -type f -name "*.swift" -not -path "./Carthage/*" -not -path "./Pods/*" | grep -q ".swift"; then
        # Prefer local config if present
        if [ -f ".swiftlint.yml" ]; then
            pwd
            echo "Using .swiftlint.yml at the above location. ( ${SRCROOT}/.swiftlint.yml )? "
            swiftlint --config .swiftlint.yml || true
        else
            echo "No .swiftlint.yml found. Running with default configuration."
            swiftlint || true
        fi
    #else
        #echo "SwiftLint: No Swift files found under ${SRCROOT}. Skipping lint."
    #fi
else
    echo "warning: \`swiftlint\` command not found - See https://github.com/realm/SwiftLint#installation for installation instructions."
fi

