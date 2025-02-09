//
//  Untitled.swift
//  MeloNX
//
//  Created by Stossy11 on 28/11/2024.
//

import Foundation
import GameController
import UIKit



var theWindow: UIWindow? = nil
extension UIWindow {
    // Makes the SDLWindow use the current WindowScene instead of making its own window.
    // Also waits for the window to append the on-screen controller
    @objc func wdb_makeKeyAndVisible() {
        if #available(iOS 13.0, *) {
            // self.windowScene = (UIApplication.shared.connectedScenes.first! as! UIWindowScene)
        }
        self.wdb_makeKeyAndVisible()
        theWindow = self
        Ryujinx.shared.repeatuntilfindLayer()
    }
}

// Patches makeKeyAndVisible to wdb_makeKeyAndVisible
func patchMakeKeyAndVisible() {
    let uiwindowClass = UIWindow.self
    if let m1 = class_getInstanceMethod(uiwindowClass, #selector(UIWindow.makeKeyAndVisible)),
       let m2 = class_getInstanceMethod(uiwindowClass, #selector(UIWindow.wdb_makeKeyAndVisible)) {
        method_exchangeImplementations(m1, m2)
    }
}

