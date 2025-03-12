//
//  TouchView.swift
//  MeloNX
//
//  Created by Stossy11 on 05/03/2025.
//

import SwiftUI
import MetalKit

struct TouchView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = MeloMTKView()
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
