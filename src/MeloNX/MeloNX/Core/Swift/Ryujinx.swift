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

struct Controller: Identifiable, Hashable {
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
        // args.append(contentsOf: ["--memory-manager-mode", "HostMapped"])
        args.append(contentsOf: ["--memory-manager-mode", "SoftwarePageTable"])
        if config.fullscreen {
            // args.append(contentsOf: ["--fullscreen", String(config.fullscreen)])
            args.append(contentsOf: ["--exclusive-fullscreen", String(config.fullscreen)])
            args.append(contentsOf: ["--exclusive-fullscreen-width", "1280"])
            args.append(contentsOf: ["--exclusive-fullscreen-height", "720"])
            // exclusive-fullscreen
        }
        args.append(contentsOf: ["--disable-vsync", "true"]) // ios already forces vsync
        args.append(contentsOf: ["--disable-shader-cache", "false"])
        args.append(contentsOf: ["--disable-docked-mode", "true"])
        args.append(contentsOf: ["--enable-texture-recompression", "true"])
        
        if config.debuglogs {
            args.append(contentsOf: ["--enable-debug-logs", String(config.debuglogs)])
        }
        if config.tracelogs {
            args.append(contentsOf: ["--enable-trace-logs", String(config.tracelogs)])
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



