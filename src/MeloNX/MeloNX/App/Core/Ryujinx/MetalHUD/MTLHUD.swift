//
//  MTLHUD.swift
//  MeloNX
//
//  Created by Stossy11 on 26/11/2024.
//

import Foundation


class MTLHud {
    
    var canMetalHud: Bool {
        return openMetalDylib()
    }
    
    var isEnabled: Bool {
        if let getenv = getenv("MTL_HUD_ENABLED") {
            return String(cString: getenv).contains("1")
        }
        return false
    }
    
    static let shared = MTLHud()
    
    private init() {
        openMetalDylib()
        if UserDefaults.standard.bool(forKey: "MTL_HUD_ENABLED") {
            enable()
        } else {
            disable()
        }
    }
    
    func openMetalDylib() -> Bool {
        let path = "/usr/lib/libMTLHud.dylib"

        // Load the dynamic library
        if dlopen(path, RTLD_NOW) != nil {
            // Library loaded successfully
            print("Library loaded from \(path)")
            return true
        } else {
            // Handle error
            if let error = String(validatingUTF8: dlerror()) {
                print("Error loading library: \(error)")
            }
            return false
        }
    }
    
    
    func enable() {
        setenv("MTL_HUD_ENABLED", "1", 1)
    }
    
    func disable() {
        setenv("MTL_HUD_ENABLED", "0", 1)
    }
}
