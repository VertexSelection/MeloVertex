# Compiling MeloNX on macOS

## Prerequisites

Before you begin, ensure you have the following installed:

- [**.NET 8.0**](https://dotnet.microsoft.com/en-us/download/dotnet/8.0)
- [**Xcode**](https://apps.apple.com/de/app/xcode/id497799835?l=en-GB&mt=12$0)
- A Mac running **macOS**

## Compilation Steps

### 1. Clone the Repository and Build Ryujinx

Open a terminal and run:

```sh
git clone https://git.743378673.xyz/MeloNX/MeloNX.git
```

However, if you only need to update MeloNX, make sure you have cd into the directory then run this 
```
git pull
```

### 2. Compile Ryujinx.Headless.SDL2.dylib

In the MeloNX folder run:

```
bash distribution/ios/compile.sh
```

### 3. Open the Xcode Project

Navigate to the **Xcode project file** located at:

```
src/MeloNX/MeloNX.xcodeproj
```

Double-click to open it in **Xcode**.

### 4. Configure the Project Settings

- In **Xcode**, select the **MeloNX** project.
- Under the **General** tab, find `Ryujinx.Headless.SDL2.dylib`.
- Set its **Embed setting** to **"Embed & Sign"**.

### 5. Configure Signing & Capabilities

- In **Xcode**, go to **Signing & Capabilities**.
- Set the **Team** to your **Apple Developer account** (free or paid).
- Change the **Bundle Identifier** to:

  ```
  com.<your-name>.MeloNX
  ```

  *(Replace `<your-name>` with your actual name or identifier.)*

### 6. Connect Your Device

Ensure your **iPhone/iPad** is **connected** and **selected** (Next to MeloNX with the arrow) in Xcode.
- You may need to install the iOS SDK. it will say next to MeloNX with the arrow saying "iOS XX Not Installed (GET)"
- You will be need to press GET and wait for it to finish downloading and installing
- Then you will be able to select your device and Build and Run.

### Make Sure you do **NOT** select the Simulator. (Which is the Generic names and the ones with the non-coloured icons, e.g. "iPhone 16 Pro")

### 7. Build and Run

Click the **Run (▶️) button** in Xcode to compile and launch MeloNX.
- When running on your device, Click the **Spray Can Button** below the Run button 
- Right Click where it says "> MeloNX PID XXXX" 
- Press Detach in the Context Menu.

---

Now you're all set! 🚀 If you encounter issues, please join the discord at https://melonx.org