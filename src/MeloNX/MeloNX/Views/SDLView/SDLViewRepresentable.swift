//
//  VulkanSDLViewRepresentable.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import UIKit
import SwiftUI
import SDL2
import GameController

struct SDLViewRepresentable: UIViewRepresentable {
    let configure: (UInt32) -> Void
    func makeUIView(context: Context) -> SDLView {
        // Configure (start ryu) before initialsing SDLView so SDLView can get the SDL_Window from Ryu
        let view = SDLView(frame: .zero)
        configure(SDL_GetWindowID(view.sdlwin))
        return view
            
    }

    func updateUIView(_ uiView: SDLView, context: Context) {
        
    }
    
}
