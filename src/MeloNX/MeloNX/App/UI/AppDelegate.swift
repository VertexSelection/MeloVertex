//
//  AppDelegate.swift
//  MeloNX
//
//  Created by Stossy11 on 18/07/2025.
//

import UIKit
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.all
    static var window: UIWindow?
    static var url: URL?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Start log capture as early as possible so crash diagnostics have context.
        _ = LogCapture.shared

        let window = UIWindow(frame: UIScreen.main.bounds)
        // window.transform = CGAffineTransformMakeScale(0.5, 0.5);
        window.rootViewController = UIHostingController(rootView: MeloNXApp())
        AppDelegate.window = window
        window.makeKeyAndVisible()

        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        AppDelegate.url = url
        NotificationCenter.default.post(name: .init("URLOpened"), object: url)
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
