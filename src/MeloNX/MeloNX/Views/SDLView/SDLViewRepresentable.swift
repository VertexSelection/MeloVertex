//
//  VulkanSDLViewRepresentable.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import UIKit
import SwiftUI

struct SDLViewRepresentable: UIViewRepresentable {
    let configure: () -> Void
    func makeUIView(context: Context) -> SDLView {
        // Configure (start ryu) before initialsing SDLView so SDLView can get the SDL_Window from Ryu
        configure()
        let view = SDLView(frame: .zero)
        return view
            
    }

    func updateUIView(_ uiView: SDLView, context: Context) {
        
    }
}
