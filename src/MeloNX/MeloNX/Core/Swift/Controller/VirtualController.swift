//
//  VirtualController.swift
//  MeloNX
//
//  Created by Stossy11 on 8/12/2024.
//

import Foundation
import CoreHaptics
import UIKit

class VirtualController {
    private var instanceID: SDL_JoystickID = -1
    private var controller: OpaquePointer?
    
    public let controllername = "MeloNX Touch Controller"
    
    init() {
        setupVirtualController()
    }
    
    private func setupVirtualController() {
        // Initialize SDL if not already initialized
        if SDL_WasInit(Uint32(SDL_INIT_GAMECONTROLLER)) == 0 {
            SDL_InitSubSystem(Uint32(SDL_INIT_GAMECONTROLLER))
        }
        
        // Create virtual controller
        var joystickDesc = SDL_VirtualJoystickDesc(
            version: UInt16(SDL_VIRTUAL_JOYSTICK_DESC_VERSION),
            type: Uint16(SDL_JOYSTICK_TYPE_GAMECONTROLLER.rawValue),
                naxes: 6,
                nbuttons: 15,
                nhats: 1,
                vendor_id: 0,
                product_id: 0,
                padding: 0,
                button_mask: 0,
                axis_mask: 0,
                name: controllername.withCString { $0 },
                userdata: nil,
                Update: { userdata in
                    // Update joystick state here
                },
                SetPlayerIndex: { userdata, playerIndex in
                    print("Player index set to \(playerIndex)")
                },
                Rumble: { userdata, lowFreq, highFreq in
                    print("Rumble with \(lowFreq), \(highFreq)")
                    VirtualController.rumble(lowFreq: Float(lowFreq), highFreq: Float(highFreq))
                    return 0
                },
                RumbleTriggers: { userdata, leftRumble, rightRumble in
                    print("Trigger rumble with \(leftRumble), \(rightRumble)")
                    return 0
                },
                SetLED: { userdata, red, green, blue in
                    print("Set LED to RGB(\(red), \(green), \(blue))")
                    return 0
                },
                SendEffect: { userdata, data, size in
                    print("Effect sent with size \(size)")
                    return 0
                }
            )
        
        instanceID = SDL_JoystickAttachVirtualEx(&joystickDesc)// SDL_JoystickAttachVirtual(SDL_JoystickType(SDL_JOYSTICK_TYPE_GAMECONTROLLER.rawValue), 6, 15, 1)
        if instanceID < 0 {
            print("Failed to create virtual joystick: \(String(cString: SDL_GetError()))")
            return
        }
        
        // Open a game controller for the virtual joystick
        let joystick = SDL_JoystickFromInstanceID(instanceID)
        controller = SDL_GameControllerOpen(Int32(instanceID))
        
        if controller == nil {
            print("Failed to create virtual controller: \(String(cString: SDL_GetError()))")
            return
        }
    }
    
    static func rumble(lowFreq: Float, highFreq: Float) {
        do {
            // Low-frequency haptic pattern
            let lowFreqPattern = try CHHapticPattern(events: [
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: lowFreq),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ], relativeTime: 0, duration: 0.2)
            ], parameters: [])

            // High-frequency haptic pattern
            let highFreqPattern = try CHHapticPattern(events: [
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: highFreq),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ], relativeTime: 0.2, duration: 0.2)
            ], parameters: [])

            // Create and start the haptic engine
            let engine = try CHHapticEngine()
            try engine.start()

            // Create and play the low-frequency player
            let lowFreqPlayer = try engine.makePlayer(with: lowFreqPattern)
            try lowFreqPlayer.start(atTime: 0)

            // Create and play the high-frequency player after a short delay
            let highFreqPlayer = try engine.makePlayer(with: highFreqPattern)
            try highFreqPlayer.start(atTime: 0.2)

        } catch {
            print("Error creating haptic patterns: \(error)")
        }
    }

    
    func updateAxisValue(value: Sint16, forAxis axis: SDL_GameControllerAxis) {
        guard controller != nil else { return }
        let joystick = SDL_JoystickFromInstanceID(instanceID)
        SDL_JoystickSetVirtualAxis(joystick, axis.rawValue, value)
    }
    
    func thumbstickMoved(_ stick: ThumbstickType, x: Double, y: Double) {
        // Convert float values (-1.0 to 1.0) to SDL axis values (-32768 to 32767)
        var scaleFactor = 32767.0
        if UIDevice.current.systemName.contains("iPadOS") {
            scaleFactor /= (160 * 1.2)
        } else {
            scaleFactor /= 160
        }
        let scaledX = Int16(min(32767.0, max(-32768.0, x * scaleFactor)))
        let scaledY = Int16(min(32767.0, max(-32768.0, y * scaleFactor)))
        
        if stick == .right {
            updateAxisValue(value: scaledX, forAxis: SDL_GameControllerAxis(SDL_CONTROLLER_AXIS_RIGHTX.rawValue))
            updateAxisValue(value: scaledY, forAxis: SDL_GameControllerAxis(SDL_CONTROLLER_AXIS_RIGHTY.rawValue))
        } else {  // ThumbstickType.left
            updateAxisValue(value: scaledX, forAxis: SDL_GameControllerAxis(SDL_CONTROLLER_AXIS_LEFTX.rawValue))
            updateAxisValue(value: scaledY, forAxis: SDL_GameControllerAxis(SDL_CONTROLLER_AXIS_LEFTY.rawValue))
        }
    }
    
    func setButtonState(_ state: Uint8, for button: VirtualControllerButton) {
        guard controller != nil else { return }
        
        print("Button: \(button.rawValue) {state: \(state)}")
        if (button == .leftTrigger || button == .rightTrigger) && (state == 1 || state == 0) {
            let axis: SDL_GameControllerAxis = (button == .leftTrigger) ? SDL_CONTROLLER_AXIS_TRIGGERLEFT : SDL_CONTROLLER_AXIS_TRIGGERRIGHT
            let value: Int = (state == 1) ? 32767 : 0
            updateAxisValue(value: Sint16(value), forAxis: axis)
        } else {
            let joystick = SDL_JoystickFromInstanceID(instanceID)
            SDL_JoystickSetVirtualButton(joystick, Int32(button.rawValue), state)
        }
    }
    
    func cleanup() {
        if let controller = controller {
            SDL_GameControllerClose(controller)
            self.controller = nil
        }
    }
    
    deinit {
        cleanup()
    }
}

enum VirtualControllerButton: Int {
    case B
    case A
    case Y
    case X
    case back
    case guide
    case start
    case leftStick
    case rightStick
    case leftShoulder
    case rightShoulder
    case dPadUp
    case dPadDown
    case dPadLeft
    case dPadRight
    case leftTrigger
    case rightTrigger
}

enum ThumbstickType: Int {
    case left
    case right
}
