//
//  JITPopover.swift
//  MeloNX
//
//  Created by Stossy11 on 05/03/2025.
//

import SwiftUI

struct JITPopover: View {
    var onJITEnabled: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State var isJIT: Bool = false
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "cpu.fill")
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            Text("Waiting for JIT")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("JIT (Just-In-Time) compilation allows MeloNX to run code at as fast as possible by translating it dynamically. This is necessary for running this emulator.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                isJIT = isJITEnabled()
                
                
                if isJIT {
                    dismiss()
                    onJITEnabled()
                    
                    Ryujinx.shared.ryuIsJITEnabled()
                }
            }
        }
    }
}
