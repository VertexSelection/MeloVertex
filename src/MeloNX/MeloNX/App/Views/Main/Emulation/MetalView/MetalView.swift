//
//  MetalView.swift
//  MeloNX
//
//  Created by Stossy11 on 09/02/2025.
//

import SwiftUI
import MetalKit

struct MetalView: UIViewRepresentable {
    
    var airplay: Bool = Air.shared.connected // just in case :3
    
    func makeUIView(context: Context) -> UIView {
        
        if Ryujinx.shared.emulationUIView == nil {
            let view = MeloMTKView()
            
            guard let metalLayer = view.layer as? CAMetalLayer else {
                fatalError("[Swift] Error: MTKView's layer is not a CAMetalLayer")
            }
            
            metalLayer.device = MTLCreateSystemDefaultDevice()
            
            let layerPtr = Unmanaged.passUnretained(metalLayer).toOpaque()
            set_native_window(layerPtr)
            
            Ryujinx.shared.emulationUIView = view
            
            
            Ryujinx.shared.metalLayer = metalLayer
            
            return view
        }
        
        if Double(UIDevice.current.systemVersion)! < 17.0 {
            
            let uiview = MTKView()
            let layer = Ryujinx.shared.metalLayer!
            
            layer.frame = uiview.bounds
            
            uiview.layer.addSublayer(layer)
            
            return uiview
        } else {
            return Ryujinx.shared.emulationUIView!
        }
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // nothin
    }
}
