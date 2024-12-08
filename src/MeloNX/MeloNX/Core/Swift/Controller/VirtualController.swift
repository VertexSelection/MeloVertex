//
//  VirtualController.swift
//  MeloNX
//
//  Created by Stossy11 on 8/12/2024.
//

import Foundation

class VirtualController {
    private var instanceID: SDL_JoystickID = -1
    private var controller: OpaquePointer?
    
    init() {
        setupVirtualController()
    }
    
    private func setupVirtualController() {
        // Initialize SDL if not already initialized
        if SDL_WasInit(Uint32(SDL_INIT_GAMECONTROLLER)) == 0 {
            SDL_InitSubSystem(Uint32(SDL_INIT_GAMECONTROLLER))
        }
        
        // Create virtual controller
        instanceID = SDL_JoystickAttachVirtual(SDL_JoystickType(SDL_JOYSTICK_TYPE_GAMECONTROLLER.rawValue), 6, 15, 1)
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
    
    func updateAxisValue(value: Sint16, forAxis axis: SDL_GameControllerAxis) {
        guard controller != nil else { return }
        let joystick = SDL_JoystickFromInstanceID(instanceID)
        SDL_JoystickSetVirtualAxis(joystick, axis.rawValue, value)
    }
    
    func thumbstickMoved(_ stick: ThumbstickType, x: Float, y: Float) {
        // Convert float values (-1.0 to 1.0) to SDL axis values (-32768 to 32767)
        let scaledX = Sint16(x * 32767.0)
        let scaledY = Sint16(y * 32767.0)
        
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
