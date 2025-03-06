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
            var view = MeloMTKView()
            
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
        
        let uiview = UIView()
        
        uiview.layer.addSublayer(Ryujinx.shared.metalLayer!)
        
        uiview.contentScaleFactor = Ryujinx.shared.metalLayer!.contentsScale
        
        return uiview
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // nothin
    }
}
