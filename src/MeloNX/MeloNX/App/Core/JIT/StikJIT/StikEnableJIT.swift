//
//  EnableJIT.swift
//  MeloNX
//
//  Created by Stossy11 on 10/02/2025.
//

import Foundation
import Network
import UIKit

func enableJITStik() {
    let bundleid = Bundle.main.bundleIdentifier ?? "Unknown"
    
    let address = URL(string: "stikjit://enable-jit?bundle-id=\(bundleid)")!
    if UIApplication.shared.canOpenURL(address) {
        UIApplication.shared.open(address)
    }
}
