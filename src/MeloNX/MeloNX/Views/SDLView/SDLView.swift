//
//  VulkanSDLView.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import UIKit
import MetalKit
import SDL2

class SDLView: UIView {
    var sdlwin: OpaquePointer?
    private var sdlWindowID: UInt32 = 1  // Adjust this ID based on Ryujinx window ID
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        startSDLWindowRetrieval()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        startSDLWindowRetrieval()
    }

    private func startSDLWindowRetrieval() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.makeSDLWindow()
            
            // Stop the timer once the window is successfully retrieved
            if self.sdlwin != nil {
                timer.invalidate()
            }
        }
    }

    private func makeSDLWindow() {
        // Attempt to retrieve the SDL window created by Ryujinx
        sdlwin = SDL_GetWindowFromID(sdlWindowID)
        
        // Check if we successfully retrieved the SDL window
        guard sdlwin != nil else {
            print("Error getting SDL window: \(String(cString: SDL_GetError()))")
            return
        }
        
        print("SDL window retrieved successfully.")
        
        // Position SDL window over this UIView
        DispatchQueue.main.async {
            self.syncSDLWindowPosition()
        }
    }
    
    private func syncSDLWindowPosition() {
        guard let sdlwin = sdlwin else { return }
        DispatchQueue.main.async {
            
            // Get the frame of the UIView in screen coordinates
            let viewFrameInWindow = self.convert(self.bounds, to: nil)
            
            // Set the SDL window position and size to match the UIView frame
            SDL_SetWindowPosition(sdlwin, Int32(viewFrameInWindow.origin.x), Int32(viewFrameInWindow.origin.y))
            SDL_SetWindowSize(sdlwin, Int32(viewFrameInWindow.width), Int32(viewFrameInWindow.height))
            
            // Bring SDL window to the front
            SDL_RaiseWindow(sdlwin)
        }
        
        print("SDL window positioned over SDLView.")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Adjust SDL window whenever layout changes
        syncSDLWindowPosition()
    }
}
