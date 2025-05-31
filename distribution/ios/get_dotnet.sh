#!/bin/bash

# XCCONFIG_FILE="${SRCROOT}/MeloNX.xcconfig"

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



DOTNET_PATH=""

for path in "${SEARCH_PATHS[@]}"; do
    if [ -d "$path" ]; then
        DOTNET_PATH=$(find "$path" -name dotnet -type f -print -quit 2>/dev/null)
        if [ -n "$DOTNET_PATH" ]; then
            break
        fi
    fi
done

if [ -z "$DOTNET_PATH" ]; then
    exit 1
fi

echo "$DOTNET_PATH"
