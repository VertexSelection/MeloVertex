#!/bin/bash

# Define the destination directory (hardcoded)
DESTINATION_DIR="src/MeloNX/Dependencies/Dynamic\ Libraries/Ryujinx.Headless.SDL2.dylib"

# Restore the project 
dotnet restore

# Build the project with the specified version 
dotnet build -c Release

# Publish the project with the specified runtime and settings 
dotnet publish -c Release -r ios-arm64 -p:ExtraDefineConstants=DISABLE_UPDATER src/Ryujinx.Headless.SDL2 --self-contained true

# Move the published .dylib to the specified location
mv src/Ryujinx.Headless.SDL2/bin/Release/net8.0/ios-arm64/native/Ryujinx.Headless.SDL2.dylib src/MeloNX/MeloNX/Dependencies/Dynamic\ Libraries/Ryujinx.Headless.SDL2.dylib

