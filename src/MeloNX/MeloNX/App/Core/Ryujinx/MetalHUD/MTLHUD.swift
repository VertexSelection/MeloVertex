//
//  MTLHUD.swift
//  MeloNX
//
//  Created by Stossy11 on 26/11/2024.
//

import Foundation


class MTLHud {
    
    @Published var canMetalHud: Bool = false
    
    var isEnabled: Bool {
        if let getenv = getenv("MTL_HUD_ENABLED") {
            return String(cString: getenv).contains("1")
        }
        return false
    }
    
    static let shared = MTLHud()
    
    private init() {
        let _ = openMetalDylib() // i'm fixing the warnings just because you said i suck at coding Autumn (propenchiefer,
        https://youtu.be/tc65SNOTMz4 7:23)
        if UserDefaults.standard.bool(forKey: "MTL_HUD_ENABLED") {
            enable()
        } else {
            disable()
        }
    }
    
    func toggle() {
        print(UserDefaults.standard.bool(forKey: "MTL_HUD_ENABLED"))
        if UserDefaults.standard.bool(forKey: "MTL_HUD_ENABLED") {
            enable()
        } else {
            disable()
        }
    }
    
    func openMetalDylib() -> Bool {
        let path = "/usr/lib/libMTLHud.dylib"

        if dlopen(path, RTLD_NOW) != nil {
            print("Library loaded from \(path)")
            canMetalHud = true
            return true
        } else {
            if let error = String(validatingUTF8: dlerror()) {
                print("Error loading library: \(error)")
            }
            canMetalHud = false
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
