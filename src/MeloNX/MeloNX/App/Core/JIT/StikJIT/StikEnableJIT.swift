//
//  EnableJIT.swift
//  MeloNX
//
//  Created by Stossy11 on 10/02/2025.
//

import Foundation
import Network
import UIKit



func stikJITorStikDebug() -> Int {
    let teamid = SecTaskCopyTeamIdentifier(SecTaskCreateFromSelf(nil)!, nil)
    
    if checkifappinstalled("com.stik.sj") {
        return 1 // StikDebug
    }
    
    if checkifappinstalled("com.stik.sj.\(String(teamid ?? ""))") {
        return 2 // StikJIT
    }
    
    return 0 // Not Found
}


func checkifappinstalled(_ id: String) -> Bool {
    
    guard let handle = dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices", RTLD_LAZY) else {
        if let error = dlerror() {
            print(String(cString: error))
        }
        return false
        // fatalError("Failed to open dylib")
    }
    
    typealias SBSLaunchApplicationWithIdentifierFunc = @convention(c) (CFString, Bool) -> Int32
    guard let sym = dlsym(handle, "SBSLaunchApplicationWithIdentifier") else {
        if let error = dlerror() {
            print(String(cString: error))
        }
        dlclose(handle)
        return false
    }
    
    let bundleID: CFString = id as CFString
    let suspended: Bool = false
    

    let SBSLaunchApplicationWithIdentifier = unsafeBitCast(sym, to: SBSLaunchApplicationWithIdentifierFunc.self)
    let result = SBSLaunchApplicationWithIdentifier(bundleID, suspended)

    return result == 9
}

func enableJITStik() {
    let urlScheme = "stikjit://enable-jit?bundle-id=\(Bundle.main.bundleIdentifier ?? "wow")"
    if let launchURL = URL(string: urlScheme), !isJITEnabled() {
        UIApplication.shared.open(launchURL, options: [:], completionHandler: nil)
    }
}
