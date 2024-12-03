# How to compile MeloNX using macOS

## Prerequisites
- [dotnet 8.0](<https://dotnet.microsoft.com/en-us/download/dotnet/8.0>)
- a computer with macOS

1. Open Terminal

2. Run the command = git clone https://github.com/melonx-emu/melonx/tree/XC-ios-ht

3. In terminal run = `cd MeloNX`

4. Again in terminal type in 
```./compile.sh -x```

5. Open Xcode file store at .../MeloNX/src/MeloNX and remove Paid Entititlments:
  ```Increased Debugging Memory Limit```
  ```Extended Virtual Addressing```

6. Make sure the Ryujinx.SDL2.Headless dylib is put in as embed and sign in settings
  
7. Change the Identifier if the app to whatever u want and change the developer account

8. Build and run

9. Check the [post-setup guide](<https://github.com/melonx-emu/melonx/tree/XC-ios-ht/postsetup.md>)

10. Enjoy the app and run games
