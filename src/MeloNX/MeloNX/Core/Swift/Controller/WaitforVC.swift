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
        let controllerHostingController = UIHostingController(rootView: controllerView)
        let containerView = TransparentHostingContainerView(frame: window.bounds)
        containerView.backgroundColor = .clear

        controllerHostingController.view.frame = containerView.bounds
        controllerHostingController.view.backgroundColor = .clear
        containerView.addSubview(controllerHostingController.view)

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if findGCControllerView(in: window) == nil {
                window.addSubview(containerView)
            } else {
                timer.invalidate()
            }
            
            window.bringSubviewToFront(containerView)
        }

    }
}


class TransparentHostingContainerView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Check if the point is within the subviews of this container
        let view = super.hitTest(point, with: event)
        
        // Return nil if the touch is outside visible content (passes through to views below)
        return view === self ? nil : view
    }
}
