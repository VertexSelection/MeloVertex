//
//  MetalView.swift
//  MeloNX
//
//  Created by Stossy11 on 09/02/2025.
//

import SwiftUI
import MetalKit

struct MetalView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let metalLayer = Ryujinx.shared.metalLayer!
        metalLayer.frame = view.bounds
        view.contentScaleFactor = metalLayer.contentsScale // Right size and Fix Touch :3
        view.layer.addSublayer(metalLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // nothin
    }
}
