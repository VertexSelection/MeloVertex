//
//  FPSMonitor.swift
//  MeloNX
//
//  Created by Stossy11 on 21/12/2024.
//

import Foundation
import SwiftUI

class FPSMonitor: ObservableObject {
    @Published private(set) var currentFPS: UInt64 = 0
    private var timer: Timer?
    
    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateFPS()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func updateFPS() {
        let currentfps = UInt64(get_current_fps())
        
        self.currentFPS = currentfps
    }
    
    
    func formatFPS() -> String {
        let fps = Double(currentFPS)
        let fpsString = String(format: "FPS: %.2f", fps)
        
        return fpsString
    }
}



