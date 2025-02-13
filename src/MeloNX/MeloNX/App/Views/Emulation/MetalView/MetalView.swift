//
//  MetalView.swift
//  MeloNX
//
//  Created by Stossy11 on 09/02/2025.
//

import SwiftUI
import MetalKit

struct MetalView: UIViewRepresentable {
    
    var airplay: Bool // just in case :3
    
    func makeUIView(context: Context) -> UIView {
        let metalLayer = Ryujinx.shared.metalLayer!
        
        var view = UIView()
        
        metalLayer.frame = view.bounds
        if airplay {
            metalLayer.contentsScale = view.contentScaleFactor
        } else {
            Ryujinx.shared.emulationUIView.contentScaleFactor = metalLayer.contentsScale // Right size and Fix Touch :3
        }
        
        Ryujinx.shared.emulationUIView = view
        
        if !Ryujinx.shared.emulationUIView.subviews.contains(where: { $0 == metalLayer }) {
            Ryujinx.shared.emulationUIView.layer.addSublayer(metalLayer)
        }
        
        return Ryujinx.shared.emulationUIView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // nothin
    }
}
