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
    var mtkview: UnsafeMutableRawPointer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeSDLWindow()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        makeSDLWindow()
        
    }

    private func makeSDLWindow() {
        DispatchQueue.main.async { [self] in
            
            // Gets window created from Ryujinx
            sdlwin = SDL_GetWindowFromID(1)
            
            // Check if it got the window.
            guard sdlwin != nil else {
                print("Error getting SDL window: \(String(cString: SDL_GetError()))")
                return
            }
            // Create metal View from the Window
            mtkview = SDL_Metal_CreateView(sdlwin)
            if mtkview == nil {
                print("Failed to create SDL Metal view.")
                return
            }
            
            // Convert Metal View to Sublayer
            if let metalLayerPointer = SDL_Metal_GetLayer(mtkview) {
                let metalLayer = Unmanaged<CAMetalLayer>.fromOpaque(metalLayerPointer).takeUnretainedValue()
                metalLayer.device = MTLCreateSystemDefaultDevice()
                layer.addSublayer(metalLayer)
            }
        }
    }
}
