//
//  NativeController.swift
//  MeloNX
//
//  Created by XITRIX on 15/02/2025.
//

import CoreHaptics
import GameController

class NativeController: Hashable {
    private var instanceID: SDL_JoystickID = -1
    private var controller: OpaquePointer?
    private var nativeController: GCController
    private let controllerHaptics: CHHapticEngine?

    public var controllername: String { "GC - \(nativeController.vendorName ?? "Unknown")" }

    init(_ controller: GCController) {
        nativeController = controller
        controllerHaptics = nativeController.haptics?.createEngine(withLocality: .default)
        try? controllerHaptics?.start()
        setupHandheldController()
    }

    deinit {
        cleanup()
    }

    private func setupHandheldController() {
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
                name: (controllername as NSString).utf8String,
                userdata: Unmanaged.passUnretained(self).toOpaque(),
                Update: { userdata in
                    // Update joystick state here
                },
                SetPlayerIndex: { userdata, playerIndex in
                    // print("Player index set to \(playerIndex)")
                },
                Rumble: { userdata, lowFreq, highFreq in
                    // print("Rumble with \(lowFreq), \(highFreq)")
                    guard let userdata else { return 0 }
                    let _self = Unmanaged<NativeController>.fromOpaque(userdata).takeUnretainedValue()
                    VirtualController.rumble(lowFreq: Float(lowFreq), highFreq: Float(highFreq), engine: _self.controllerHaptics)
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

        if #available(iOS 16, *) {
            guard let gamepad = nativeController.extendedGamepad
            else { return }
            
            setupButtonChangeListener(gamepad.buttonA, for: UserDefaults.standard.bool(forKey: "swapBandA") ? .B : .A)
            setupButtonChangeListener(gamepad.buttonB, for: UserDefaults.standard.bool(forKey: "swapBandA") ? .A : .B)
            setupButtonChangeListener(gamepad.buttonX, for: UserDefaults.standard.bool(forKey: "swapBandA") ? .Y : .X)
            setupButtonChangeListener(gamepad.buttonY, for: UserDefaults.standard.bool(forKey: "swapBandA") ? .X : .Y)

            setupButtonChangeListener(gamepad.dpad.up, for: .dPadUp)
            setupButtonChangeListener(gamepad.dpad.down, for: .dPadDown)
            setupButtonChangeListener(gamepad.dpad.left, for: .dPadLeft)
            setupButtonChangeListener(gamepad.dpad.right, for: .dPadRight)

            setupButtonChangeListener(gamepad.leftShoulder, for: .leftShoulder)
            setupButtonChangeListener(gamepad.rightShoulder, for: .rightShoulder)
            gamepad.leftThumbstickButton.map { setupButtonChangeListener($0, for: .leftStick) }
            gamepad.rightThumbstickButton.map { setupButtonChangeListener($0, for: .rightStick) }

            setupButtonChangeListener(gamepad.buttonMenu, for: .start)
            gamepad.buttonOptions.map { setupButtonChangeListener($0, for: .back) }

            setupStickChangeListener(gamepad.leftThumbstick, for: .left)
            setupStickChangeListener(gamepad.rightThumbstick, for: .right)

            setupTriggerChangeListener(gamepad.leftTrigger, for: .left)
            setupTriggerChangeListener(gamepad.rightTrigger, for: .right)
        }
    }

    func setupButtonChangeListener(_ button: GCControllerButtonInput, for key: VirtualControllerButton) {
        button.valueChangedHandler = { [unowned self] _, _, pressed in
            setButtonState(pressed ? 1 : 0, for: key)
        }
    }

    func setupStickChangeListener(_ button: GCControllerDirectionPad, for key: ThumbstickType) {
        button.valueChangedHandler = { [unowned self] _, xValue, yValue in
            let scaledX = Sint16(xValue * 32767.0)
            let scaledY = -Sint16(yValue * 32767.0)

            switch key {
            case .left:
                updateAxisValue(value: scaledX, forAxis: SDL_GameControllerAxis(SDL_CONTROLLER_AXIS_LEFTX.rawValue))
                updateAxisValue(value: scaledY, forAxis: SDL_GameControllerAxis(SDL_CONTROLLER_AXIS_LEFTY.rawValue))
            case .right:
                updateAxisValue(value: scaledX, forAxis: SDL_GameControllerAxis(SDL_CONTROLLER_AXIS_RIGHTX.rawValue))
                updateAxisValue(value: scaledY, forAxis: SDL_GameControllerAxis(SDL_CONTROLLER_AXIS_RIGHTY.rawValue))
            }
        }
    }

    func setupTriggerChangeListener(_ button: GCControllerButtonInput, for key: ThumbstickType) {
        button.valueChangedHandler = { [unowned self] _, value, pressed in
//            // print("Value: \(value), Is pressed: \(pressed)")
            let axis: SDL_GameControllerAxis = (key == .left) ? SDL_CONTROLLER_AXIS_TRIGGERLEFT : SDL_CONTROLLER_AXIS_TRIGGERRIGHT
            let scaledValue = Sint16(value * 32767.0)
            updateAxisValue(value: scaledValue, forAxis: axis)
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
            // print("Error creating haptic patterns: \(error)")
        }
    }


    func updateAxisValue(value: Sint16, forAxis axis: SDL_GameControllerAxis) {
        guard controller != nil else { return }
        let joystick = SDL_JoystickFromInstanceID(instanceID)
        SDL_JoystickSetVirtualAxis(joystick, axis.rawValue, value)
    }

    func thumbstickMoved(_ stick: ThumbstickType, x: Double, y: Double) {
        let scaleFactor = 32767.0 / 160

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

//        // print("Button: \(button.rawValue) {state: \(state)}")
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
        if let controller {
            SDL_JoystickDetachVirtual(instanceID)
            SDL_GameControllerClose(controller)
            self.controller = nil
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(nativeController)
    }

    static func == (lhs: NativeController, rhs: NativeController) -> Bool {
        lhs.nativeController == rhs.nativeController
    }
}
