//
//  AskForJIT.swift
//  Pomelo
//
//  Created by Stossy11 on 9/10/2024.
//  Copyright © 2024 Stossy11. All rights reserved.
//

import Foundation
import UIKit

func askForJIT() {
    // Check if TrollStore exists by checking the presence of the directory
    let urlScheme = "apple-magnifier://enable-jit?bundle-id=\(Bundle.main.bundleIdentifier!)"
    if let launchURL = URL(string: urlScheme) {
        if UIApplication.shared.canOpenURL(launchURL) {
            // Open the URL to enable JIT
            UIApplication.shared.open(launchURL, options: [:], completionHandler: nil)
            
            return
        }
    }
    
    return 
}
