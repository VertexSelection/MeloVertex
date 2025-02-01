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

var hostingController: UIHostingController<ControllerView>? // Store reference to prevent deallocation

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

    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
        if findGCControllerView(in: window) == nil {
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
