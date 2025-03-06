#!/bin/bash

GITEA_URL="https://git.743378673.xyz/"
REPO="MeloNX"
XCCONFIG_FILE="${SRCROOT}/MeloNX.xcconfig"

INCREMENT_PATCH=false

# Check for --patch argument
if [[ "$1" == "--patch" ]]; then
    INCREMENT_PATCH=true
fi

# Fetch latest tag from Gitea
LATEST_VERSION=$(curl -s "${GITEA_URL}/api/v1/repos/${REPO}/${REPO}/tags" | jq -r '.[].name' | sort -V | tail -n1)

if [ -z "$LATEST_VERSION" ]; then
    echo "Error: Could not fetch latest tag from Gitea"
    exit 1
fi

echo "Latest version: $LATEST_VERSION"

# Split version into major, minor, and patch
IFS='.' read -r MAJOR MINOR PATCH <<< "$LATEST_VERSION"

# Increment version based on argument
if $INCREMENT_PATCH; then
    NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
else
    NEW_VERSION="$MAJOR.$((MINOR + 1)).0"
fi

echo "New version: $NEW_VERSION"

sed -i '' "s/^VERSION = $LATEST_VERSION$/VERSION = $NEW_VERSION/g" "$XCCONFIG_FILE"

echo "Updated MeloNX.xcconfig with version $NEW_VERSION"
