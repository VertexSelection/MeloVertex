//
//  Ryujinx.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import Foundation
import SwiftUI

class Ryujinx {
    private var isRunning = false
    
    public struct Configuration {
        let gamepath: String
        let inputids: [String]
        let debuglogs: Bool
        let tracelogs: Bool
        let listinputids: Bool
        var additionalArgs: [String]

        init(gamepath: String, additionalArgs: [String] = [], debuglogs: Bool = false, tracelogs: Bool = false, listinputids: Bool = false, inputids: [String] = []) {
            self.gamepath = gamepath
            self.debuglogs = debuglogs
            self.tracelogs = tracelogs
            self.inputids = inputids
            self.listinputids = listinputids
            self.additionalArgs = additionalArgs
        }
    }
    
    func start(with config: Configuration) throws {
        guard !isRunning else {
            throw RyujinxError.alreadyRunning
        }
        
        isRunning = true

        DispatchQueue.main.async {
            do {
                let args = self.buildCommandLineArgs(from: config)
                let cArgs = args.map { strdup($0) }
                defer { cArgs.forEach { free($0) } }

                var argvPtrs = cArgs
                let result = main_ryujinx_sdl(Int32(args.count), &argvPtrs)

                if result != 0 {
                    self.isRunning = false
                    throw RyujinxError.executionError(code: result)
                }
                
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
        
        args.append("--graphics-backend")
        args.append("Vulkan")
        args.append(contentsOf: ["--memory-manager-mode", "SoftwarePageTable"])
        args.append(contentsOf: ["--fullscreen", "true"])
        args.append(contentsOf: ["--enable-debug-logs", String(config.debuglogs)])
        args.append(contentsOf: ["--enable-trace-logs", String(config.tracelogs)])

        // Add list input IDs option
        if config.listinputids {
            args.append(contentsOf: ["--list-inputs-ids"])
        }
        
        // Add input IDs, limiting to the first 4
        if !config.inputids.isEmpty {
            config.inputids.prefix(4).enumerated().forEach { index, inputId in
                args.append(contentsOf: ["--input-id-\(index + 1)", inputId])
            }
        }

        // Add any additional arguments
        args.append(contentsOf: config.additionalArgs)

        return args
    }

    static func log(_ message: String) {
        print("[Ryujinx] \(message)")
    }
}
