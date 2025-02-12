//
//  Untitled.swift
//  MeloNX
//
//  Created by Stossy11 on 28/11/2024.
//

import Foundation
import GameController
import UIKit
import SwiftUI



var theWindow: UIWindow? = nil
extension UIWindow {
    // Makes the SDLWindow use the current WindowScene instead of making its own window.
    // Also waits for the window to append the on-screen controller
    @objc func wdb_makeKeyAndVisible() {
        let enabled =  UserDefaults.standard.bool(forKey: "oldWindowCode")
        
        if #unavailable(iOS 17.0), enabled {
            self.windowScene = (UIApplication.shared.connectedScenes.first! as! UIWindowScene)
        }
        
        self.wdb_makeKeyAndVisible()
        theWindow = self
        
        if #available(iOS 17, *) {
            Ryujinx.shared.repeatuntilfindLayer()
        } else if UserDefaults.standard.bool(forKey: "isVirtualController") && enabled {
            waitForController()
        }
    }
}

// MARK: - iOS 16 and below Only

var hostingController: UIHostingController<ControllerView>?
func waitForController() {
    guard let window = theWindow else { return }

    // Function to search for an existing UIHostingController with ControllerView
    func findGCControllerView(in view: UIView) -> UIHostingController<ControllerView>? {
        if let hostingVC = view.next as? UIHostingController<ControllerView> {
            return hostingVC
        }
        
        for subview in view.subviews {
            if let found = findGCControllerView(in: subview) {
                return found
            }
        }
        
        return nil
    }
    
    let controllerView = ControllerView()
    let newHostingController = UIHostingController(rootView: controllerView)
    
    hostingController = newHostingController
    
    let containerView = newHostingController.view!
    containerView.backgroundColor = .clear
    containerView.frame = window.bounds
    containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    // Timer for controller
    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
        if findGCControllerView(in: window) == nil {
            // Adds Virtual Controller Subview
            window.addSubview(containerView)
            window.bringSubviewToFront(containerView)

            if let sdlWindow = SDL_GetWindowFromID(1) {
                SDL_SetWindowPosition(sdlWindow, 0, 0)
            }

            timer.invalidate()
        }
    }
}


class TransparentHostingContainerView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Check if the point is within the subviews of this container
        let view = super.hitTest(point, with: event)
        print(view)
        
        // Return nil if the touch is outside visible content (passes through to views below)
        return view === self ? nil : view
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

