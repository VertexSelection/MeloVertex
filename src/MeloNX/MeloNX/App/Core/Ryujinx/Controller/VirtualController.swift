//
//  VirtualController.swift
//  MeloNX
//
//  Created by Stossy11 on 8/12/2024.
//

import Foundation
import CoreHaptics
import UIKit

class VirtualController : BaseController {
    private var instanceID: SDL_JoystickID = -1
    private var controller: OpaquePointer?
    private let hapticEngine: CHHapticEngine?
    private let rumbleController: RumbleController?
    private var deviceMotionProvider: DeviceMotionProvider?
    
    public let controllername = "MeloNX Touch Controller"
    
    init() {
        // Setup Haptics
        hapticEngine = try? CHHapticEngine()
        if let hapticsEngine = hapticEngine {
            do {
                try hapticsEngine.start()
                rumbleController = RumbleController(engine: hapticsEngine, rumbleMultiplier: 2.0)
                
                // print("CHHapticEngine started and RumbleController initialized.")
            } catch {
                // print("Error starting CHHapticEngine: \(error.localizedDescription)")
                rumbleController = nil
            }
        } else {
            // print("CHHapticEngine is nil. Cannot initialize RumbleController.")
            rumbleController = nil
        }
        setupVirtualController()
    }
    
    internal func tryRegisterMotion(slot: UInt8) {
        // Setup Motion
        let dsuServer = DSUServer.shared
        
        deviceMotionProvider = DeviceMotionProvider(slot: slot)
        if let provider = deviceMotionProvider {
            dsuServer.register(provider)
        }
    }
    
    internal func tryGetMotionProvider() -> DSUMotionProvider? {
        return deviceMotionProvider
    }
    
    private func setupVirtualController() {
        if SDL_WasInit(Uint32(SDL_INIT_GAMECONTROLLER)) == 0 {
            SDL_InitSubSystem(Uint32(SDL_INIT_GAMECONTROLLER))
        }
        
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
                    // print("Player index set to \(playerIndex)")
                },
                Rumble: { userdata, lowFreq, highFreq in
                    // print("Rumble with \(lowFreq), \(highFreq)")
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        guard let userdata else { return 0 }
                        let _self = Unmanaged<VirtualController>.fromOpaque(userdata).takeUnretainedValue()
                        _self.rumbleController?.rumble(lowFreq: Float(lowFreq), highFreq: Float(highFreq))
                    }
                    return 0
                },
                RumbleTriggers: { userdata, leftRumble, rightRumble in
                    // print("Trigger rumble with \(leftRumble), \(rightRumble)")
                    return 0
                },
                SetLED: { userdata, red, green, blue in
                    // print("Set LED to RGB(\(red), \(green), \(blue))")
                    return 0
                },
                SendEffect: { userdata, data, size in
                    // print("Effect sent with size \(size)")
                    return 0
                }
            )
        
        instanceID = SDL_JoystickAttachVirtualEx(&joystickDesc)// SDL_JoystickAttachVirtual(SDL_JoystickType(SDL_JOYSTICK_TYPE_GAMECONTROLLER.rawValue), 6, 15, 1)
        if instanceID < 0 {
            // print("Failed to create virtual joystick: \(String(cString: SDL_GetError()))")
            return
        }
        
        controller = SDL_GameControllerOpen(Int32(instanceID))
        
        if controller == nil {
            // print("Failed to create virtual controller: \(String(cString: SDL_GetError()))")
            return
        }
    }
    
    func updateAxisValue(value: Sint16, forAxis axis: SDL_GameControllerAxis) {
        guard controller != nil else { return }
        let joystick = SDL_JoystickFromInstanceID(instanceID)
        SDL_JoystickSetVirtualAxis(joystick, axis.rawValue, value)
    }
    
    func thumbstickMoved(_ stick: ThumbstickType, x: Double, y: Double) {
        let scaledX = Int16(min(32767.0, max(-32768.0, x * 32767.0)))
        let scaledY = Int16(min(32767.0, max(-32768.0, y * 32767.0)))
        
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
        
        // // print("Button: \(button.rawValue) {state: \(state)}")
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
    case A
    case B
    case X
    case Y
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
    
    var isTrigger: Bool {
        switch self {
        case .leftTrigger, .rightTrigger, .leftShoulder, .rightShoulder:
            return true
        default:
            return false
        }
    }
    
    var isSmall: Bool {
        switch self {
        case .back, .start, .guide:
            return true
        default:
            return false
        }
    }
}

enum ThumbstickType: Int {
    case left
    case right
}
