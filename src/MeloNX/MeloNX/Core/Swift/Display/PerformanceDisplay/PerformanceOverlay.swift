//
//  Untitled.swift
//  MeloNX
//
//  Created by Stossy11 on 21/12/2024.
//

import SwiftUI

struct PerformanceOverlayView: View  {
    @StateObject private var memorymonitor = MemoryUsageMonitor()
    
    @StateObject private var fpsmonitor = FPSMonitor()
    
    var body: some View {
        VStack {
            Text("\(fpsmonitor.formatFPS())")
            Text(memorymonitor.formatMemorySize(memorymonitor.memoryUsage))
        }
    }
}

