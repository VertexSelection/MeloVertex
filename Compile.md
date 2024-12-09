# How to compile MeloNX using macOS

## Prerequisites
- [.NET 8.0](<https://dotnet.microsoft.com/en-us/download/dotnet/8.0>)
- A computer with macOS

## Compiling
1. Clone the Git Repo and build Ryujinx
    ```
       git clone https://github.com/melonx-emu/melonx/tree/XC-ios-ht
       cd melonx
       ./compile.sh -x
    ```

2. Open the Xcode project, stored at MeloNX/src/MeloNX

3. Make sure `Ryujinx.SDL2.Headless.dylib` is set to `Embed & Sign` in the General settings for the Xcode project
  
4. Signing & Capabilities
    Change your 'Team' to your Developer Account (free or paid) and change Bundle Identifier to
    `com.*your name*.MeloNX`

6. Build and Run
    `CMD+R`

7. Check the [post-setup guide](<https://github.com/melonx-emu/melonx/tree/XC-ios-ht/postsetup.md>)

## If you don't have a paid developer account
Make sure these entitlements are removed if you don't have a paid Apple Developer account
```
    Extended Virtual Addressing
    Increased Debugging Memory Limit
```
