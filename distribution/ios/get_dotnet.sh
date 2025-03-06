#!/bin/bash

XCCONFIG_FILE="${SRCROOT}/MeloNX.xcconfig"

# Define the common paths to search for dotnet, including user-specific directories
SEARCH_PATHS=(
    "/usr/local/share/dotnet"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/opt"
    "/Library/Frameworks"
    "$HOME/.dotnet"
    "$HOME/Developer"
)

# Initialize DOTNET_PATH as empty
DOTNET_PATH=""

# Search in the defined paths
for path in "${SEARCH_PATHS[@]}"; do
    if [ -d "$path" ]; then
        DOTNET_PATH=$(find "$path" -name dotnet -type f -print -quit 2>/dev/null)
        if [ -n "$DOTNET_PATH" ]; then
            break
        fi
    fi
done

# Check if the path was found
if [ -z "$DOTNET_PATH" ]; then
    echo "Error: dotnet path not found."
    exit 1
fi

echo "dotnet path: $DOTNET_PATH"

# Escape the path for sed
ESCAPED_PATH=$(echo "$DOTNET_PATH" | sed 's/\//\\\//g')

# Update the xcconfig file
sed -i '' "s/^DOTNET = .*/DOTNET = $ESCAPED_PATH/g" "$XCCONFIG_FILE"

echo "Updated MeloNX.xcconfig with DOTNET path: $DOTNET_PATH"
