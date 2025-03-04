<p align="center">
    <a href="https://melonx.org">
        <img src="https://melonx.org/static/imgs/MeloNX.svg" alt="MeloNX Logo" width="120">
    </a>
</p>

<h1 align="center">MeloNX</h1>



<p align="center">
    MeloNX enables Nintendo Switch game emulation on iOS using the Ryujinx iOS code base.
</p>

<p align="center">
       MeloNX is an iOS Nintendo Switch emulator based on Ryujinx, written primarily in C#. Designed to bring accurate performance and a user-friendly interface to iOS, MeloNX makes Switch games accessible on Apple devices.
       Developed from the ground up, MeloNX is open-source and available on Github under the <a href="https://github.com/MeloNX-Emu/MeloNX/blob/master/LICENSE.txt" target="_blank">MeloNX license (Based on MIT)</a>. <br 
</p>

# Compatibility

MeloNX works on iPhone XS/XR and later and iPad 8th Gen and later. Check out the Compatibility on the <a href="https://melonx.org/compatibility/" target="_blank">website</a>.

# Usage

## FAQ
- MeloNX is made for iOS 17+, on iOS 15 - 16 MeloNX can be installed but will have issues or may not work at all.
- MeloNX needs Xcode or a Paid Apple Developer Account. SideStore support may come soon (SideStore Side Issue)
- MeloNX needs JIT
- Recommended Device: iPhone 15 Pro or newer.
- Low-End Recommended Device**: iPhone 13 Pro. 
- Lowest Supported Device: iPhone XR


## How to install

### Paid Developer Account  

1. **Sideload the App**  
   - Use any sideloading tool that supports Apple IDs.  

2. **Enable Entitlements**  
   - Visit [Apple Developer Identifiers](https://developer.apple.com/account/resources/identifiers).  
   - Locate **MeloNX** and enable the following entitlements:  
     - `Increased Memory Limit`  
     - `Increased Debugging Memory Limit`  

3. **Reinstall the App**  
   - Delete the existing installation.  
   - Sideload the app again with the updated entitlements.  

4. **Enable JIT**  
   - Use your preferred method to enable Just-In-Time (JIT) compilation.  

5. **Add Necessary Files**  

If having Issues installing firmware (Make sure your Keys are installed first)
   - If needed, install firmware and keys from **Ryujinx Desktop**.  
   - Copy the **bis** and **system** folders  

### Xcode

**NOTE: These Xcode builds are nightly and may have unfinished features.**

1. **Compile Guide**
   - Visit the [guide here](https://git.743378673.xyz/MeloNX/MeloNX/src/branch/XC-ios-ht/Compile.md).

2. **Add Necessary Files**  

If having Issues installing firmware (Make sure your Keys are installed first)
   - If needed, install firmware and keys from **Ryujinx Desktop**.  
   - Copy the **bis** and **system** folders  
   
## Features

- **Audio**

  Audio output is entirely supported, audio input (microphone) isn't supported.
  We use C# wrappers for [OpenAL](https://openal-soft.org/), and [SDL2](https://www.libsdl.org/) & [libsoundio](http://libsound.io/) as fallbacks.

- **CPU**

  The CPU emulator, ARMeilleure, emulates an ARMv8 CPU and currently has support for most 64-bit ARMv8 and some of the ARMv7 (and older) instructions, including partial 32-bit support.
  It translates the ARM code to a custom IR, performs a few optimizations, and turns that into x86 code.
  There are three memory manager options available depending on the user's preference, leveraging both software-based (slower) and host-mapped modes (much faster).
  The fastest option (host, unchecked) is set by default.
  Ryujinx also features an optional Profiled Persistent Translation Cache, which essentially caches translated functions so that they do not need to be translated every time the game loads.
  The net result is a significant reduction in load times (the amount of time between launching a game and arriving at the title screen) for nearly every game.
  NOTE: This feature is enabled by default, You must launch the game at least twice to the title screen or beyond before performance improvements are unlocked on the third launch!
  These improvements are permanent and do not require any extra launches going forward.

- **GPU**

  The GPU emulator emulates the Switch's Maxwell GPU using Metal (via MoltenVK) APIs through a custom build of OpenTK or Silk.NET respectively.

- **Input**

  We currently have support for keyboard, touch input, JoyCon input support, and nearly all controllers.
  Motion controls are natively supported in most cases; for dual-JoyCon motion support, DS4Windows or BetterJoy are currently required.
  In all scenarios, you can set up everything inside the input configuration menu.

- **DLC & Modifications**

  MeloNX supports DLC + Game Update Add-ons.
  Mods (romfs, exefs, and runtime mods such as cheats) are supported;

- **Configuration**

  The emulator has settings for enabling or disabling some logging, remapping controllers, and more.

## License

This software is licensed under the terms of the [MeloNX license (Based on MIT License)](LICENSE.txt).
This project makes use of code authored by the libvpx project, licensed under BSD and the ffmpeg project, licensed under LGPLv3.
See [LICENSE.txt](LICENSE.txt) and [THIRDPARTY.md](distribution/legal/THIRDPARTY.md) for more details.

## Credits

- [Ryujinx](https://github.com/ryujinx-mirror/ryujinx) is used for the base of this emulator. (link is to ryujinx-mirror since they were supportive)
- [LibHac](https://github.com/Thealexbarney/LibHac) is used for our file-system.
- [AmiiboAPI](https://www.amiiboapi.com) is used in our Amiibo emulation.
- [ldn_mitm](https://github.com/spacemeowx2/ldn_mitm) is used for one of our available multiplayer modes.
- [ShellLink](https://github.com/securifybv/ShellLink) is used for Windows shortcut generation.
