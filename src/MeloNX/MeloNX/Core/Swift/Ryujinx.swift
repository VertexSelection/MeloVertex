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
        var disableDockedMode: Bool
        var enableTextureRecompression: Bool
        var additionalArgs: [String]
        

        init(gamepath: String,
             inputids: [String] = [],
             debuglogs: Bool = false,
             tracelogs: Bool = false,
             listinputids: Bool = false,
             fullscreen: Bool = true,
             memoryManagerMode: String = "HostMapped",
             disableShaderCache: Bool = false,
             disableDockedMode: Bool = false,
             nintendoinput: Bool = true,
             enableInternet: Bool = false,
             enableTextureRecompression: Bool = true,
             additionalArgs: [String] = [],
             resscale: Float = 1.00
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
        }
    }

    
    func start(with config: Configuration) throws {
        guard !isRunning else {
            throw RyujinxError.alreadyRunning
        }
        
        isRunning = true
        
        // Start The Emulation on the main thread
        RunLoop.current.perform {
            do {
                let args = self.buildCommandLineArgs(from: config)
                
                // Convert Arguments to ones that Ryujinx can Read
                let cArgs = args.map { strdup($0) }
                defer { cArgs.forEach { free($0) } }
                var argvPtrs = cArgs
                
                // Start the emulation
                let result = main_ryujinx_sdl(Int32(args.count), &argvPtrs)
                
                if result != 0 {
                    self.isRunning = false
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
        
        // Fixes the Stubs.DispatchLoop Crash
        args.append(contentsOf: ["--memory-manager-mode", config.memoryManagerMode])
        args.append(contentsOf: ["--exclusive-fullscreen", String(config.fullscreen)])
        args.append(contentsOf: ["--exclusive-fullscreen-width", "\(Int(UIScreen.main.bounds.width))"])
        args.append(contentsOf: ["--exclusive-fullscreen-height", "\(Int(UIScreen.main.bounds.height))"])
        
        
        if config.nintendoinput {
            args.append("--correct-controller")
        }
        
        
        args.append("--disable-vsync")
        
        if config.disableShaderCache {
            args.append("--disable-shader-cache")
        }
        if config.disableDockedMode {
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
    
    func getConnectedControllers() -> [Controller] {
        

        guard let jsonPtr = get_game_controllers() else {
            return []
        }
        
        // Convert the unmanaged memory (C string) to a Swift String
        let jsonString = String(cString: jsonPtr)
        
        var controllers: [Controller] = []
        
        // Splitting the string by newline
        let lines = jsonString.components(separatedBy: "\n")
        
        // Parsing each line
        for line in lines {
            if line.contains(":") {
                let parts = line.components(separatedBy: ":")
                if parts.count == 2 {
                    let id = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let name = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    controllers.append(Controller(id: id, name: name))
                }
            }
        }
        
        return controllers
        
    }



    static func log(_ message: String) {
        print("[Ryujinx] \(message)")
    }
}



