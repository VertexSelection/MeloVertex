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
    @State var isAirplaying = Air.shared.connected
    var body: some View {
        ZStack {
            if isAirplaying {
                Text("")
                    .onAppear {
                        Air.play(AnyView(MetalView().ignoresSafeArea()))
                    }
            } else {
                MetalView() // The Emulation View
                    .ignoresSafeArea()
                    .edgesIgnoringSafeArea(.all)
            }
            
            // Above Emulation View
            
            if isVCA {
                ControllerView() // Virtual Controller
            }
        }
        .onAppear {
            Air.shared.connectionCallbacks.append { cool in
                DispatchQueue.main.async {
                    isAirplaying = cool
                    print(cool)
                }
            }
        }
    }
}
