//
//  VirtualController.swift
//  MeloNX
//
//  Created by Stossy11 on 28/11/2024.
//

import Foundation
import GameController
import UIKit

public var controllerCallback: (() -> Void)?

var VirtualController: GCVirtualController!
func showVirtualController() {
    let config = GCVirtualController.Configuration()
    if UserDefaults.standard.bool(forKey: "RyuDemoControls") {
        config.elements = [
            GCInputLeftThumbstick,
            GCInputButtonA,
            GCInputButtonB,
            GCInputButtonX,
            GCInputButtonY,
            // GCInputRightThumbstick,
            GCInputRightTrigger,
            GCInputLeftTrigger,
            GCInputLeftShoulder,
            GCInputRightShoulder
        ]
    } else {
        config.elements = [
            GCInputLeftThumbstick,
            GCInputButtonA,
            GCInputButtonB,
            GCInputButtonX,
            GCInputButtonY,
            GCInputRightThumbstick,
            GCInputRightTrigger,
            GCInputLeftTrigger,
            GCInputLeftShoulder,
            GCInputRightShoulder
        ]
    }
    VirtualController = GCVirtualController(configuration: config)
    VirtualController.connect { err in
        print("controller connect: \(String(describing: err))")
        patchMakeKeyAndVisible()
        if let controllerCallback {
            controllerCallback()
        }
    }
}

func waitforcontroller() {
    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
        
        if let window = UIApplication.shared.windows.first {
            // Function to recursively search for GCControllerView
            func findGCControllerView(in view: UIView) -> UIView? {
                // Check if current view is GCControllerView
                if String(describing: type(of: view)) == "GCControllerView" {
                    return view
                }
                
                // Search through subviews
                for subview in view.subviews {
                    if let found = findGCControllerView(in: subview) {
                        return found
                    }
                }
                
                return nil
            }
            
            if let gcControllerView = findGCControllerView(in: window) {
                // Found the GCControllerView
                print("Found GCControllerView:", gcControllerView)
                
                if let theWindow = theWindow, (findGCControllerView(in: theWindow) == nil) {
                    theWindow.addSubview(gcControllerView)
                    
                    theWindow.bringSubviewToFront(gcControllerView)
                }
            }
        }
    }
}

@available(iOS 15.0, *)
func reconnectVirtualController() {
    VirtualController.disconnect()
    DispatchQueue.main.async {
        VirtualController.connect { err in
            print("reconnected: err \(String(describing: err))")
        }
    }
}


