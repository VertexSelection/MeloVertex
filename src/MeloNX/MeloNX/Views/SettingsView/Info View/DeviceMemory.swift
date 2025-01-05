//
//  DeviceMemory.swift
//  MeloNX
//
//  Created by Tech Guy on 12/31/24.
//
import SwiftUI
import Foundation
import UIKit

enum DeviceMemory {
    /// Check if device has 8GB or more RAM
    static var has8GBOrMore: Bool {
        #if targetEnvironment(simulator)
        return ProcessInfo.processInfo.physicalMemory >= 7 * 1024 * 1024 * 1024 // 8GB in bytes
        #else
        return ProcessInfo.processInfo.physicalMemory >= 7 * 1024 * 1024 * 1024 // 8GB in bytes
        #endif
    }
    
    /// Get total RAM in GB (rounded)
    static var totalRAM: Int {
        Int(ProcessInfo.processInfo.physicalMemory / 1024 / 1024 / 1024) + 1
    }
}
