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
    @objc func wdb_makeKeyAndVisible() {
        if #available(iOS 13.0, *) {
            self.windowScene = (UIApplication.shared.connectedScenes.first! as! UIWindowScene)
        }
        self.wdb_makeKeyAndVisible()
        theWindow = self
        
        
        if UserDefaults.standard.bool(forKey: "isVirtualController") {
            if let window = theWindow {
                waitforcontroller()
            }
        }
    }
}


func patchMakeKeyAndVisible() {
    let uiwindowClass = UIWindow.self
    if let m1 = class_getInstanceMethod(uiwindowClass, #selector(UIWindow.makeKeyAndVisible)),
       let m2 = class_getInstanceMethod(uiwindowClass, #selector(UIWindow.wdb_makeKeyAndVisible)) {
        method_exchangeImplementations(m1, m2)
    }
}
