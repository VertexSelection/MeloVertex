//
//  Ryujinx.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import Foundation
import SwiftUI
import SDL2
import GameController

struct Controller: Identifiable {
    let id: String
    let name: String
}

class Ryujinx {
    private var isRunning = false
    
    @Published var controllerMap: [Controller] = []
    
    public struct Configuration {
        let gamepath: String
        let inputids: [String]
        let debuglogs: Bool
        let tracelogs: Bool
        let listinputids: Bool
        let fullscreen: Bool
        var additionalArgs: [String]

        init(gamepath: String, additionalArgs: [String] = [], debuglogs: Bool = false, tracelogs: Bool = false, listinputids: Bool = false, inputids: [String] = [], ryufullscreen: Bool = false) {
            self.gamepath = gamepath
            self.debuglogs = debuglogs
            self.tracelogs = tracelogs
            self.inputids = inputids
            self.listinputids = listinputids
            self.fullscreen = ryufullscreen
            self.additionalArgs = additionalArgs
        }
    }
    
    func start(with config: Configuration) throws {
        guard !isRunning else {
            throw RyujinxError.alreadyRunning
        }
        
        isRunning = true
        // Start The Emulation on the main thread
        DispatchQueue.main.async {
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
                // Start The Emulation loop (probably not needed)
                self.runEmulationLoop()
            } catch {
                self.isRunning = false
                Self.log("Emulation failed to start: \(error)")
            }
        }
    }

    private func runEmulationLoop() {
        let runLoop = RunLoop.current
        let port = Port()
        runLoop.add(port, forMode: .default)
        
        while isRunning && runLoop.run(mode: .default, before: .distantFuture) {
            autoreleasepool { }
        }

        Self.log("Emulation loop ended")
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
        // args.append(contentsOf: ["--memory-manager-mode", "HostMapped"])
        args.append(contentsOf: ["--memory-manager-mode", "SoftwarePageTable"])
        if config.fullscreen {
            // args.append(contentsOf: ["--fullscreen", String(config.fullscreen)])
            args.append(contentsOf: ["--exclusive-fullscreen", String(config.fullscreen)])
            args.append(contentsOf: ["--exclusive-fullscreen-width", "1280"])
            args.append(contentsOf: ["--exclusive-fullscreen-height", "720"])
            // exclusive-fullscreen
        }
        // Debug Logs
        
        args.append(contentsOf: ["--disable-shader-cache", "true"])
        args.append(contentsOf: ["--disable-docked-mode", "true"])
        args.append(contentsOf: ["--enable-texture-recompression", "true"])
        // args.append(contentsOf: ["--enable-debug-logs", String(config.debuglogs)])
        // args.append(contentsOf: ["--enable-trace-logs", String(config.tracelogs)])

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
    
    func getConnectedControllers() {
        

        // Retrieve all connected controllers
        let controllers = GCController.controllers()
        
        for controller in controllers {
            if let controllerID = controller.vendorName {
                // Assuming controller's name is used as the ID
                let controllerName = controller.vendorName ?? "Unknown Controller"
                
                // You can customize the key format here
                DispatchQueue.main.async {
                    self.controllerMap.append(Controller(id: controllerID, name: controllerName))
                }
            }
        }
        
    }



    static func log(_ message: String) {
        print("[Ryujinx] \(message)")
    }
}



