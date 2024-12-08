//
//  VirtualController.swift
//  MeloNX
//
//  Created by Stossy11 on 28/11/2024.
//

import Foundation
import GameController
import UIKit
import SwiftUI

func waitforcontroller() {
    if let window = theWindow {
        
        
        
        // Function to recursively search for GCControllerView
        func findGCControllerView(in view: UIView) -> UIView? {
            // Check if current view is GCControllerView
            if String(describing: type(of: view)) == "ControllerView" {
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
        
        let controllerView = ControllerView()

        let hostingController = UIHostingController(rootView: controllerView)
        
        hostingController.view.frame = window.bounds  // Set the frame of the SwiftUI view
        hostingController.view.backgroundColor = .clear
        
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if findGCControllerView(in: window) == nil {
                window.addSubview(hostingController.view)
            }
            
            window.bringSubviewToFront(hostingController.view)
        }

    }
}
