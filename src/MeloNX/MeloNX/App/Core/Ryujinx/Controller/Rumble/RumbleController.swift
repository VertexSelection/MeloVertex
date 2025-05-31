//
//  RumbleController.swift
//  MeloNX
//
//  Created by MediaMoots on 2025/5/24.
//

import CoreHaptics
import Foundation

class RumbleController {
    
    private var engine: CHHapticEngine?
    private var lowHapticPlayer: CHHapticPatternPlayer?
    private var highHapticPlayer: CHHapticPatternPlayer?
    private var rumbleMultiplier: Float = 1.0
    
    // The duration of each continuous haptic event.
    // We'll restart the players before this duration expires.
    private let hapticEventDuration: TimeInterval = 20
    
    // Timer to schedule player restarts
    private var playerRestartTimer: Timer?
    
    // Interval before the haptic event duration runs out to restart
    private let restartGracePeriod: TimeInterval = 1.0

    init (engine: CHHapticEngine?, rumbleMultiplier: Float) {
        self.engine = engine
        self.rumbleMultiplier = rumbleMultiplier
        
        createPlayers()
        setupPlayerRestartTimer()
    }
    
    // Deinitializer to clean up the timer and stop players when the controller is deallocated
    deinit {
        playerRestartTimer?.invalidate() // Stop the timer
        playerRestartTimer = nil
        
        // Optionally stop the haptic players immediately
        try? lowHapticPlayer?.stop(atTime: CHHapticTimeImmediate)
        try? highHapticPlayer?.stop(atTime: CHHapticTimeImmediate)
        
        // print("RumbleController deinitialized.")
    }

    // MARK: - Private Methods for Player Management
    private func createPlayers() {
        // Ensure the engine is available before proceeding
        guard let engine = self.engine else {
            // print("CHHapticEngine is nil. Cannot initialize RumbleController.")
            return
        }
        
        do {
            let baseIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
            
            let lowSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.0)
            let highSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
            
            // Create continuous haptic events with the defined duration
            let lowContinuousEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [baseIntensity, lowSharpness], relativeTime: 0, duration: hapticEventDuration)
            let highContinuousEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [baseIntensity, highSharpness], relativeTime: 0, duration: hapticEventDuration)
            
            // Create patterns from the continuous haptic events.
            let lowPattern = try CHHapticPattern(events: [lowContinuousEvent], parameters: [])
            let highPattern = try CHHapticPattern(events: [highContinuousEvent], parameters: [])
            
            // Make players from the patterns
            lowHapticPlayer = try engine.makePlayer(with: lowPattern)
            highHapticPlayer = try engine.makePlayer(with: highPattern)
            
            rumble(lowFreq: 0, highFreq: 0)
            
            // Start players initially
            try lowHapticPlayer?.start(atTime: 0)
            try highHapticPlayer?.start(atTime: 0)
        } catch {
            // print("Error initializing RumbleController or setting up haptic player: \(error.localizedDescription)")
            
            // Clean up if setup fails
            lowHapticPlayer = nil
            highHapticPlayer = nil
            playerRestartTimer?.invalidate()
            playerRestartTimer = nil
        }
    }

    private func setupPlayerRestartTimer() {
        // Invalidate any existing timer to prevent multiple timers if init is called multiple times
        playerRestartTimer?.invalidate()
        
        // Calculate the interval for restarting: 1 second before the haptic event duration ends
        let restartInterval = hapticEventDuration - restartGracePeriod
        
        guard restartInterval > 0 else {
            // print("Warning: hapticEventDuration (\(hapticEventDuration)s) is too short for scheduled restart with grace period (\(restartGracePeriod)s). Timer will not be set.")
            return
        }

        // Schedule a repeating timer that calls restartPlayers()
        playerRestartTimer = Timer.scheduledTimer(withTimeInterval: restartInterval, repeats: true) { [weak self] _ in
            self?.createPlayers()
        }
        // Ensure the timer is added to the current run loop in its default mode
        RunLoop.current.add(playerRestartTimer!, forMode: .default)
        
        // print("Haptic Players restart timer scheduled to fire every \(restartInterval) seconds.")
    }
    
    // MARK: - Public Rumble Control

    public func rumble(lowFreq: Float, highFreq: Float) {
       
        // Normalize SDL values (0-65535) to CoreHaptics range (0.0-1.0)
        let normalizedLow = min(1.0, max(0.0, lowFreq * rumbleMultiplier / 65535.0))
        let normalizedHigh = min(1.0, max(0.0, highFreq * rumbleMultiplier / 65535.0))
        
        // Create dynamic parameters to control intensity
        let lowIntensityParameter = CHHapticDynamicParameter(parameterID: .hapticIntensityControl, value: normalizedLow, relativeTime: 0)
        let highIntensityParameter = CHHapticDynamicParameter(parameterID: .hapticIntensityControl, value: normalizedHigh, relativeTime: 0)

        // Send parameters to the players
        do {
            try lowHapticPlayer?.sendParameters([lowIntensityParameter], atTime: 0)
            try highHapticPlayer?.sendParameters([highIntensityParameter], atTime: 0)
        } catch {
            // print("Error sending haptic parameters: \(error.localizedDescription)")
        }
    }
}
