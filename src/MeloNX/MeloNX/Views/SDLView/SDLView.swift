//
//  VulkanSDLView.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import UIKit
import MetalKit
import SDL2

/*
class SDLView: UIView {
    var sdlwin: OpaquePointer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        DispatchQueue.main.async { [self] in
            makeSDLWindow()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        DispatchQueue.main.async { [self] in
            makeSDLWindow()
        }
    }

    func getWindowFlags() -> UInt32 {
        return SDL_WINDOW_VULKAN.rawValue
    }

    private func makeSDLWindow() {
        let width: Int32 = 1280  // Replace with the desired width
        let height: Int32 = 720  // Replace with the desired height
        
        let defaultFlags: UInt32 = SDL_WINDOW_SHOWN.rawValue
        let fullscreenFlag: UInt32 = SDL_WINDOW_FULLSCREEN.rawValue // Or SDL_WINDOW_FULLSCREEN_DESKTOP if needed
        
        // Create the SDL window
        sdlwin = SDL_CreateWindow(
            "Ryujinx",
            0,
            0,
            width,
            height,
            defaultFlags | getWindowFlags() // | fullscreenFlag | getWindowFlags()
        )

        // Check if we successfully retrieved the SDL window
        guard sdlwin != nil else {
            print("Error creating SDL window: \(String(cString: SDL_GetError()))")
            return
        }
        
        print("SDL window created successfully.")
        
        // Position SDL window over this UIView
        self.syncSDLWindowPosition()
    }
    
    private func syncSDLWindowPosition() {
        guard let sdlwin = sdlwin else { return }
        
        
        // Get the frame of the UIView in screen coordinates
        let viewFrameInWindow = self.convert(self.bounds, to: nil)
        
        // Set the SDL window position and size to match the UIView frame
        SDL_SetWindowPosition(sdlwin, Int32(viewFrameInWindow.origin.x), Int32(viewFrameInWindow.origin.y))
        SDL_SetWindowSize(sdlwin, Int32(viewFrameInWindow.width), Int32(viewFrameInWindow.height))
        
        // Bring SDL window to the front
        SDL_RaiseWindow(sdlwin)
        
        print("SDL window positioned over SDLView.")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Adjust SDL window whenever layout changes
        syncSDLWindowPosition()
    }
}

*/

