//
//  ControllerView.swift
//  Pomelo-V2
//
//  Created by Stossy11 on 16/7/2024.
//

import SwiftUI
import GameController
import CoreMotion

struct ControllerView: View {
    // MARK: - Properties
    @AppStorage("On-ScreenControllerScale") private var controllerScale: Double = 1.0
    @AppStorage("stick-button") private var stickButton = false
    @State private var isPortrait = true
    @State var hideDpad = false
    @State var hideABXY = false
    @Environment(\.verticalSizeClass) var verticalSizeClass

    
    // MARK: - Body
    var body: some View {
        Group {
            let isPad =  UIDevice.current.userInterfaceIdiom == .pad
            
            if isPortrait && !isPad {
                portraitLayout
            } else {
                landscapeLayout
            }
        }
        .padding()
        .onChange(of: verticalSizeClass) { _ in
            updateOrientation()
        }
        .onAppear(perform: updateOrientation)
    }
    
    // MARK: - Layouts
    private var portraitLayout: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                HStack(spacing: 30) {
                    VStack(spacing: 15) {
                        ShoulderButtonsViewLeft()
                        ZStack {
                            JoystickController(showBackground: $hideDpad)
                            if !hideDpad {
                                DPadView()
                                    .animation(.easeInOut(duration: 0.2), value: hideDpad)
                            }
                        }
                    }
                    
                    VStack(spacing: 15) {
                        ShoulderButtonsViewRight()
                        ZStack {
                            JoystickController(iscool: true, showBackground: $hideABXY)
                            if !hideABXY {
                                ABXYView()
                                    .animation(.easeInOut(duration: 0.2), value: hideABXY)
                            }
                        }
                    }
                }
                
                HStack(spacing: 60) {
                    HStack {
                        ButtonView(button: .leftStick)
                            .padding()
                        ButtonView(button: .back)
                    }
                    
                    HStack {
                        ButtonView(button: .start)
                        ButtonView(button: .rightStick)
                            .padding()
                    }
                }
            }
        }
    }
    
    private var landscapeLayout: some View {
        VStack {
            Spacer()
            
            HStack {
                VStack(spacing: 20) {
                    ShoulderButtonsViewLeft()
                    ZStack {
                        JoystickController(showBackground: $hideDpad)
                        if !hideDpad {
                            DPadView()
                                .animation(.easeInOut(duration: 0.2), value: hideDpad)
                        }
                    }
                }
                
                Spacer()
                
                centerButtons
                
                Spacer()
                
                VStack(spacing: 20) {
                    ShoulderButtonsViewRight()
                    ZStack {
                        JoystickController(iscool: true, showBackground: $hideABXY)
                        if !hideABXY {
                            ABXYView()
                                .animation(.easeInOut(duration: 0.2), value: hideABXY)
                        }
                    }
                }
            }
        }
    }
    
    private var centerButtons: some View {
        Group {
            if stickButton {
                VStack {
                    HStack(spacing: 50) {
                        ButtonView(button: .leftStick)
                            .padding()
                        Spacer()
                        ButtonView(button: .rightStick)
                            .padding()
                    }
                    .padding(.top, 30)
                    
                    HStack(spacing: 50) {
                        ButtonView(button: .back)
                        Spacer()
                        ButtonView(button: .start)
                    }
                }
                .padding(.bottom, 20)
            } else {
                HStack(spacing: 50) {
                    ButtonView(button: .back)
                    Spacer()
                    ButtonView(button: .start)
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Methods
    
    private func updateOrientation() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            isPortrait = window.bounds.size.height > window.bounds.size.width
        }
    }
}


struct ShoulderButtonsViewLeft: View {
    @State private var width: CGFloat = 160
    @State private var height: CGFloat = 20
    @AppStorage("On-ScreenControllerScale") var controllerScale: Double = 1.0
    
    var body: some View {
        HStack(spacing: 20) {
            ButtonView(button: .leftTrigger)
            ButtonView(button: .leftShoulder)
        }
        .frame(width: width, height: height)
        .onAppear {
            if UIDevice.current.systemName.contains("iPadOS") {
                width *= 1.2
                height *= 1.2
            }
            
            width *= CGFloat(controllerScale)
            height *= CGFloat(controllerScale)
        }
    }
}

struct ShoulderButtonsViewRight: View {
    @State private var width: CGFloat = 160
    @State private var height: CGFloat = 20
    @AppStorage("On-ScreenControllerScale") var controllerScale: Double = 1.0
    
    var body: some View {
        HStack(spacing: 20) {
            ButtonView(button: .rightShoulder)
            ButtonView(button: .rightTrigger)
        }
        .frame(width: width, height: height)
        .onAppear {
            if UIDevice.current.systemName.contains("iPadOS") {
                width *= 1.2
                height *= 1.2
            }
            
            width *= CGFloat(controllerScale)
            height *= CGFloat(controllerScale)
        }
    }
}

struct DPadView: View {
    @State private var size: CGFloat = 145
    @AppStorage("On-ScreenControllerScale") var controllerScale: Double = 1.0
    
    var body: some View {
        VStack(spacing: 7) {
            ButtonView(button: .dPadUp)
            HStack(spacing: 22) {
                ButtonView(button: .dPadLeft)
                Spacer(minLength: 22)
                ButtonView(button: .dPadRight)
            }
            ButtonView(button: .dPadDown)
        }
        .frame(width: size, height: size)
        .onAppear {
            if UIDevice.current.systemName.contains("iPadOS") {
                size *= 1.2
            }
            
            size *= CGFloat(controllerScale)
        }
    }
}

struct ABXYView: View {
    @State private var size: CGFloat = 145
    @AppStorage("On-ScreenControllerScale") var controllerScale: Double = 1.0
    
    var body: some View {
        VStack(spacing: 7) {
            ButtonView(button: .X)
            HStack(spacing: 22) {
                ButtonView(button: .Y)
                Spacer(minLength: 22)
                ButtonView(button: .A)
            }
            ButtonView(button: .B)
        }
        .frame(width: size, height: size)
        .onAppear {
            if UIDevice.current.systemName.contains("iPadOS") {
                size *= 1.2
            }
            
            size *= CGFloat(controllerScale)
        }
    }
}


struct ButtonView: View {
    var button: VirtualControllerButton
    
    @AppStorage("onscreenhandheld") var onscreenjoy: Bool = false
    @AppStorage("On-ScreenControllerScale") var controllerScale: Double = 1.0
    @Environment(\.presentationMode) var presentationMode
    
    @AppCodableStorage("toggleButtons") var toggleButtons = ToggleButtonsState()
    @State private var istoggle = false
    
    @State private var isPressed = false
    @State private var toggleState = false
    
    @State private var size: CGSize = .zero
    
    var body: some View {
        Circle()
            .foregroundStyle(.clear.opacity(0))
            .overlay {
                Image(systemName: buttonConfig.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width, height: size.height)
                    .foregroundStyle(.white)
                    .opacity(isPressed ? 0.6 : 1.0)
                    .allowsHitTesting(false)
            }
            .frame(width: size.width, height: size.height)
            .background(
                buttonBackground
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in handleButtonPress() }
                    .onEnded { _ in handleButtonRelease() }
            )
            .onAppear {
                istoggle = (toggleButtons.toggle1 && button == .A) || (toggleButtons.toggle2 && button == .B) || (toggleButtons.toggle3 && button == .X) || (toggleButtons.toggle4 && button == .Y)
                size = calculateButtonSize()
            }
            .onChange(of: controllerScale) { _ in
                size = calculateButtonSize()
            }
    }
    
    private var buttonBackground: some View {
        Group {
            if !button.isTrigger && button != .leftStick && button != .rightStick {
                Circle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: size.width * 1.25, height: size.height * 1.25)
            } else if button == .leftStick || button == .rightStick {
                Image(systemName: buttonConfig.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width * 1.25, height: size.height * 1.25)
                    .foregroundColor(Color.gray.opacity(0.4))
            } else if button.isTrigger {
                Image(systemName: convertTriggerIconToButton(buttonConfig.iconName))
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.width * 1.25, height: size.height * 1.25)
                    .foregroundColor(Color.gray.opacity(0.4))
            }
        }
    }
    
    private func convertTriggerIconToButton(_ iconName: String) -> String {
        if iconName.hasPrefix("zl") || iconName.hasPrefix("zr") {
            var converted = String(iconName.dropFirst(3))
            converted = converted.replacingOccurrences(of: "rectangle", with: "button")
            converted = converted.replacingOccurrences(of: ".fill", with: ".horizontal.fill")
            return converted
        } else {
            var converted = String(iconName.dropFirst(2))
            converted = converted.replacingOccurrences(of: "rectangle", with: "button")
            converted = converted.replacingOccurrences(of: ".fill", with: ".horizontal.fill")
            return converted
        }
    }
    
    private func handleButtonPress() {
        guard !isPressed || istoggle else { return }

        if istoggle {
            toggleState.toggle()
            isPressed = toggleState
            let value = toggleState ? 1 : 0
            Ryujinx.shared.virtualController.setButtonState(Uint8(value), for: button)
            Haptics.shared.play(.medium)
        } else {
            isPressed = true
            Ryujinx.shared.virtualController.setButtonState(1, for: button)
            Haptics.shared.play(.medium)
        }
    }
    
    private func handleButtonRelease() {
        if istoggle { return }

        guard isPressed else { return }

        isPressed = false
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.05) {
            Ryujinx.shared.virtualController.setButtonState(0, for: button)
        }
    }
    
    private func calculateButtonSize() -> CGSize {
        let baseWidth: CGFloat
        let baseHeight: CGFloat
        
        if button.isTrigger {
            baseWidth = 70
            baseHeight = 40
        } else if button.isSmall {
            baseWidth = 35
            baseHeight = 35
        } else {
            baseWidth = 45
            baseHeight = 45
        }
        
        let deviceMultiplier = UIDevice.current.userInterfaceIdiom == .pad ? 1.2 : 1.0
        let scaleMultiplier = CGFloat(controllerScale)
        
        return CGSize(
            width: baseWidth * deviceMultiplier * scaleMultiplier,
            height: baseHeight * deviceMultiplier * scaleMultiplier
        )
    }
    
    // Centralized button configuration
    private var buttonConfig: ButtonConfiguration {
        switch button {
        case .A:
            return ButtonConfiguration(iconName: "a.circle.fill")
        case .B:
            return ButtonConfiguration(iconName: "b.circle.fill")
        case .X:
            return ButtonConfiguration(iconName: "x.circle.fill")
        case .Y:
            return ButtonConfiguration(iconName: "y.circle.fill")
        case .leftStick:
            return ButtonConfiguration(iconName: "l.joystick.press.down.fill")
        case .rightStick:
            return ButtonConfiguration(iconName: "r.joystick.press.down.fill")
        case .dPadUp:
            return ButtonConfiguration(iconName: "arrowtriangle.up.circle.fill")
        case .dPadDown:
            return ButtonConfiguration(iconName: "arrowtriangle.down.circle.fill")
        case .dPadLeft:
            return ButtonConfiguration(iconName: "arrowtriangle.left.circle.fill")
        case .dPadRight:
            return ButtonConfiguration(iconName: "arrowtriangle.right.circle.fill")
        case .leftTrigger:
            return ButtonConfiguration(iconName: "zl.rectangle.roundedtop.fill")
        case .rightTrigger:
            return ButtonConfiguration(iconName: "zr.rectangle.roundedtop.fill")
        case .leftShoulder:
            return ButtonConfiguration(iconName: "l.rectangle.roundedbottom.fill")
        case .rightShoulder:
            return ButtonConfiguration(iconName: "r.rectangle.roundedbottom.fill")
        case .start:
            return ButtonConfiguration(iconName: "plus.circle.fill")
        case .back:
            return ButtonConfiguration(iconName: "minus.circle.fill")
        case .guide:
            return ButtonConfiguration(iconName: "house.circle.fill")
        }
    }
    
    struct ButtonConfiguration {
        let iconName: String
    }
}
