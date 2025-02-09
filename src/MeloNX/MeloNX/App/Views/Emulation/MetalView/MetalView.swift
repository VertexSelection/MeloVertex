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
        
        let metalLayer = Ryujinx.shared.metalLayer!
        metalLayer.frame = Ryujinx.shared.emulationUIView.bounds
        Ryujinx.shared.emulationUIView.contentScaleFactor = metalLayer.contentsScale // Right size and Fix Touch :3
        if !Ryujinx.shared.emulationUIView.subviews.contains(where: { $0 == metalLayer }) {
            Ryujinx.shared.emulationUIView.layer.addSublayer(metalLayer)
        }
        
        return Ryujinx.shared.emulationUIView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // nothin
    }
}
