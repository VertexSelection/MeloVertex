//
//  MTLHUD.swift
//  MeloNX
//
//  Created by Stossy11 on 26/11/2024.
//

import Foundation
import SwiftUI

class MTLHud: ObservableObject {
    @Published var canMetalHud: Bool = false
    
    @AppStorage("MTL_HUD_ENABLED") var metalHudEnabled: Bool = false {
        didSet {
            if metalHudEnabled {
                enable()
            } else {
                disable()
            }
        }
    }
    
    
    static let shared = MTLHud()
    
    private init() {
        canMetalHud = openMetalDylib() // i'm fixing the warnings just because you said i suck at coding Autumn (propenchiefer, https://youtu.be/tc65SNOTMz4 7:23)
        
        if metalHudEnabled {
            enable()
        } else {
            disable()
        }
    }
    
    func openMetalDylib() -> Bool {
        let path = "/usr/lib/libMTLHud.dylib"

        if dlopen(path, RTLD_NOW) != nil {
            return true
        } else {
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
