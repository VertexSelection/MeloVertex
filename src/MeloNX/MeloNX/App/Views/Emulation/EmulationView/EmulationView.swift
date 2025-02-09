//
//  EmulationView.swift
//  MeloNX
//
//  Created by Stossy11 on 09/02/2025.
//

import SwiftUI

// Emulation View
struct EmulationView: View {
    @AppStorage("isVirtualController") var isVCA: Bool = true
    var body: some View {
        ZStack {
            MetalView() // The Emulation View
                .ignoresSafeArea()
                .edgesIgnoringSafeArea(.all)
            
            // Above Emulation View
            
            if isVCA {
                ControllerView() // Virtual Controller
            }
        }
    }
}
