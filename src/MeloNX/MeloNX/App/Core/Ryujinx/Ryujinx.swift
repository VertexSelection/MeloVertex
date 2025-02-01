//
//  Ryujinx.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import Foundation
import SwiftUI
import GameController

struct Controller: Identifiable, Hashable {
    var id: String
    var name: String
}

struct iOSNav<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        if #available(iOS 16, *) {
            NavigationStack(root: content)
        } else {
            NavigationView(content: content)
                .navigationViewStyle(StackNavigationViewStyle())
                .navigationViewStyle(.stack)
        }
    }
}

class Ryujinx {
    private var isRunning = false
    
    let virtualController = VirtualController()
    
    @Published var controllerMap: [Controller] = []
    @State var firmwareversion = "0"
    
    static let shared = Ryujinx()
    
    private init() {}
    
    public struct Configuration : Codable, Equatable {
        var gamepath: String
        var inputids: [String]
        var resscale: Float
        var debuglogs: Bool
        var tracelogs: Bool
        var nintendoinput: Bool
        var enableInternet: Bool
        var listinputids: Bool
        var fullscreen: Bool
        var memoryManagerMode: String
        var disableShaderCache: Bool
        var hypervisor: Bool
        var disableDockedMode: Bool
        var enableTextureRecompression: Bool
        var additionalArgs: [String]
        var maxAnisotropy: Float
        var macroHLE: Bool
        var ignoreMissingServices: Bool
        var expandRam: Bool
        
        

        init(gamepath: String,
             inputids: [String] = [],
             debuglogs: Bool = false,
             tracelogs: Bool = false,
             listinputids: Bool = false,
             fullscreen: Bool = false,
             memoryManagerMode: String = "HostMappedUnsafe",
             disableShaderCache: Bool = false,
             disableDockedMode: Bool = false,
             nintendoinput: Bool = true,
             enableInternet: Bool = false,
             enableTextureRecompression: Bool = true,
             additionalArgs: [String] = [],
             resscale: Float = 1.00,
             maxAnisotropy: Float = 0,
             macroHLE: Bool = false,
             ignoreMissingServices: Bool = false,
             hypervisor: Bool = false,
             expandRam: Bool = false
        ) {
            self.gamepath = gamepath
            self.inputids = inputids
            self.debuglogs = debuglogs
            self.tracelogs = tracelogs
            self.listinputids = listinputids
            self.fullscreen = fullscreen
            self.disableShaderCache = disableShaderCache
            self.disableDockedMode = disableDockedMode
            self.enableTextureRecompression = enableTextureRecompression
            self.additionalArgs = additionalArgs
            self.memoryManagerMode = memoryManagerMode
            self.resscale = resscale
            self.nintendoinput = nintendoinput
            self.enableInternet = enableInternet
            self.maxAnisotropy = maxAnisotropy
            self.macroHLE = macroHLE
            self.expandRam = expandRam
            self.ignoreMissingServices = ignoreMissingServices
            self.hypervisor = hypervisor
        }
    }

    
    func start(with config: Configuration) throws {
        guard !isRunning else {
            throw RyujinxError.alreadyRunning
        }
        
        isRunning = true
        
        RunLoop.current.perform {
            let url = URL(string: config.gamepath)!
            
            do {
                let args = self.buildCommandLineArgs(from: config)
                let accessing = url.startAccessingSecurityScopedResource()
                
                // Convert Arguments to ones that Ryujinx can Read
                let cArgs = args.map { strdup($0) }
                defer { cArgs.forEach { free($0) } }
                var argvPtrs = cArgs
                
                // Start the emulation
                let result = main_ryujinx_sdl(Int32(args.count), &argvPtrs)
                
                if result != 0 {
                    self.isRunning = false
                    if accessing {
                        url.stopAccessingSecurityScopedResource()
                    }
                    
                    throw RyujinxError.executionError(code: result)
                }
            } catch {
                self.isRunning = false
                Self.log("Emulation failed to start: \(error)")
            }
        }
    }


    func stop() throws {
        guard isRunning else {
            throw RyujinxError.notRunning
        }

        isRunning = false
    }

    var running: Bool {
        return isRunning
    }

    private func buildCommandLineArgs(from config: Configuration) -> [String] {
        var args: [String] = []
        
        // Add the game path
        args.append(config.gamepath)
        
        // Starts with vulkan
        args.append("--graphics-backend")
        args.append("Vulkan")
        
        args.append(contentsOf: ["--memory-manager-mode", config.memoryManagerMode])
        
        // args.append(contentsOf: ["--exclusive-fullscreen", String(true)])
        // args.append(contentsOf: ["--exclusive-fullscreen-width", "\(Int(UIScreen.main.bounds.width))"])
        // args.append(contentsOf: ["--exclusive-fullscreen-height", "\(Int(UIScreen.main.bounds.height))"])
        // We don't need this. Ryujinx should handle it fine :3
        // this also causes crashes in some games :3
        
        if config.fullscreen {
            args.append(contentsOf: ["--aspect-ratio", "Stretched"])
        }
        
        
        if config.nintendoinput {
            args.append("--correct-controller")
        }
        
        
        // args.append("--disable-vsync")
        
        if config.hypervisor {
            args.append("--use-hypervisor")
        }
        
        
        if config.resscale != 1.0 {
            args.append(contentsOf: ["--resolution-scale", String(config.resscale)])
        }
        
        if config.expandRam {
            args.append(contentsOf: ["--expand-ram", String(config.maxAnisotropy)])
        }
        
        if config.ignoreMissingServices {
            args.append(contentsOf: ["--ignore-missing-services", String(config.maxAnisotropy)])
        }
        
        if config.maxAnisotropy != 0 {
            args.append(contentsOf: ["--max-anisotropy", String(config.maxAnisotropy)])
        }
        
        if !config.macroHLE {
            args.append("--disable-macro-hle")
        }
        
        if !config.disableShaderCache { // same with disableShaderCache
            args.append("--disable-shader-cache")
        }
        
        if !config.disableDockedMode { // disableDockedMode is actually enableDockedMode, i just have flipped it around in the settings page to make it easier to understand :3
            args.append("--disable-docked-mode")
        }
        if config.enableTextureRecompression {
            args.append("--enable-texture-recompression")
        }
        
        if config.debuglogs {
            args.append(contentsOf: ["--enable-debug-logs"])
        }
        if config.tracelogs {
            args.append(contentsOf: ["--enable-trace-logs"])
        }

        // List the input ids
        if config.listinputids {
            args.append(contentsOf: ["--list-inputs-ids"])
        }
        
        // Append the input ids (limit to 4 just in case)
        if !config.inputids.isEmpty {
            config.inputids.prefix(4).enumerated().forEach { index, inputId in
                args.append(contentsOf: ["--input-id-\(index + 1)", inputId])
            }
        }

        // Apped any additional arguments
        args.append(contentsOf: config.additionalArgs)

        return args
    }
    
    func fetchFirmwareVersion() -> String {
        do {
            let firmwareVersionPointer = installed_firmware_version()
            if let pointer = firmwareVersionPointer {
                let firmwareVersion = String(cString: pointer)
                DispatchQueue.main.async {
                    self.firmwareversion = firmwareVersion
                }
                return firmwareVersion
            }
            
        } catch {
            print(error)
        }

        return "0"
    }
    
    func installFirmware(firmwarePath: String) {
        guard let cString = firmwarePath.cString(using: .utf8) else {
            print("Invalid firmware path")
            return
        }

        install_firmware(cString)
        
        let version = fetchFirmwareVersion()
        if !version.isEmpty {
            self.firmwareversion = version
        }
    }
    
    private func generateGamepadId(joystickIndex: Int32) -> String? {
        var guid = SDL_JoystickGetDeviceGUID(joystickIndex)

        if guid.data.0 == 0 && guid.data.1 == 0 && guid.data.2 == 0 && guid.data.3 == 0 {
            return nil
        }

        let reorderedGUID: [UInt8] = [
            guid.data.3, guid.data.2, guid.data.1, guid.data.0,
            guid.data.5, guid.data.4,
            guid.data.7, guid.data.6,
            guid.data.8, guid.data.9,
            guid.data.10, guid.data.11, guid.data.12, guid.data.13, guid.data.14, guid.data.15
        ]

        let guidString = reorderedGUID.map { String(format: "%02X", $0) }.joined().lowercased()

        func substring(_ str: String, _ start: Int, _ end: Int) -> String {
            let startIdx = str.index(str.startIndex, offsetBy: start)
            let endIdx = str.index(str.startIndex, offsetBy: end)
            return String(str[startIdx..<endIdx])
        }

        let formattedGUID = "\(substring(guidString, 0, 8))-\(substring(guidString, 8, 12))-\(substring(guidString, 12, 16))-\(substring(guidString, 16, 20))-\(substring(guidString, 20, 32))"

        return "\(joystickIndex)-\(formattedGUID)"
    }
    
    func getConnectedControllers() -> [Controller] {
        var controllers: [Controller] = []

        let numJoysticks = SDL_NumJoysticks()

        for i in 0..<numJoysticks {
            if let controller = SDL_GameControllerOpen(i) {
                let guid = generateGamepadId(joystickIndex: i)
                let name = String(cString: SDL_GameControllerName(controller))
                
                print("Controller \(i): \(name), GUID: \(guid ?? "")")
                
                guard let guid else {
                    SDL_GameControllerClose(controller)
                    return []
                }
                
                controllers.append(Controller(id: guid, name: name))

                SDL_GameControllerClose(controller)
            }
         }
        
        return controllers
    }
    
    func removeFirmware() {
        let fileManager = FileManager.default
        
        let documentsfolder = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        
        let bisFolder = documentsfolder.appendingPathComponent("bis")
        let systemFolder = bisFolder.appendingPathComponent("system")
        let contentsFolder = systemFolder.appendingPathComponent("Contents")
        let registeredFolder = contentsFolder.appendingPathComponent("registered").path
        
    
        do {
            if fileManager.fileExists(atPath: registeredFolder) {
                try fileManager.removeItem(atPath: registeredFolder)
                print("Folder removed successfully.")
                let version = fetchFirmwareVersion()
                
                if version.isEmpty {
                    self.firmwareversion = "0"
                } else {
                    print("Firmware eeeeee \(version)")
                }
                
            } else {
                print("Folder does not exist.")
            }
        } catch {
            print("Error removing folder: \(error)")
        }
    }



    static func log(_ message: String) {
        print("[Ryujinx] \(message)")
    }
}



