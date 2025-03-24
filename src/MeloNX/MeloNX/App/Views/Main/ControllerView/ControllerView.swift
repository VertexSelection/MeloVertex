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
                        ButtonView(button: .start)
                    }
                    
                    HStack {
                        ButtonView(button: .back)
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
    @State private var width: CGFloat = 45
    @State private var height: CGFloat = 45
    @State private var isPressed = false
    @AppStorage("onscreenhandheld") var onscreenjoy: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("On-ScreenControllerScale") var controllerScale: Double = 1.0
    @State private var debounceTimer: Timer?
    
    var body: some View {
        Image(systemName: buttonText)
            .resizable()
            .scaledToFit()
            .frame(width: width, height: height)
            .foregroundColor(true ? Color.white.opacity(0.5) : Color.black.opacity(0.5))
            .background(
                Group {
                    if !button.isTrigger && button != .leftStick && button != .rightStick {
                        Circle()
                            .fill(true ? Color.gray.opacity(0.4) : Color.gray.opacity(0.3))
                            .frame(width: width * 1.25, height: height * 1.25)
                    } else if button == .leftStick || button == .rightStick {
                        Image(systemName: buttonText)
                            .resizable()
                            .scaledToFit()
                            .frame(width: width * 1.25, height: height * 1.25)
                            .foregroundColor(true ? Color.gray.opacity(0.4) : Color.gray.opacity(0.3))
                    } else if button.isTrigger {
                        Image(systemName: "" + String(turntobutton(buttonText)))
                            .resizable()
                            .scaledToFit()
                            .frame(width: width * 1.25, height: height * 1.25)
                            .foregroundColor(true ? Color.gray.opacity(0.4) : Color.gray.opacity(0.3))
                    }
                }
            )
            .opacity(isPressed ? 0.6 : 1.0)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        handleButtonPress()
                    }
                    .onEnded { _ in
                        handleButtonRelease()
                    }
            )
            .onAppear {
                print(String(buttonText.dropFirst(2)))
                configureSizeForButton()
            }
    }
    
    private func turntobutton(_ string: String) -> String {
        var sting = string
        if string.hasPrefix("zl") || string.hasPrefix("zr") {
            sting = String(string.dropFirst(3))
        } else {
            sting = String(string.dropFirst(2))
        }
        sting = sting.replacingOccurrences(of: "rectangle", with: "button")
        sting = sting.replacingOccurrences(of: ".fill", with: ".horizontal.fill")
        
        return sting
    }
    
    private func handleButtonPress() {
        if !isPressed {
            isPressed = true
            
            debounceTimer?.invalidate()
            
            Ryujinx.shared.virtualController.setButtonState(1, for: button)
            
            Haptics.shared.play(.medium)
        }
    }
    
    private func handleButtonRelease() {
        if isPressed {
            isPressed = false
            
            debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { _ in
                Ryujinx.shared.virtualController.setButtonState(0, for: button)
            }
        }
    }
    
    private func configureSizeForButton() {
        if button.isTrigger {
            width = 70
            height = 40
        } else if button.isSmall {
            width = 35
            height = 35
        }
        
        // Adjust for iPad
        if UIDevice.current.systemName.contains("iPadOS") {
            width *= 1.2
            height *= 1.2
        }
        
        width *= CGFloat(controllerScale)
        height *= CGFloat(controllerScale)
    }
    
    private var buttonText: String {
        switch button {
        case .A:
            return "a.circle.fill"
        case .B:
            return "b.circle.fill"
        case .X:
            return "x.circle.fill"
        case .Y:
            return "y.circle.fill"
        case .leftStick:
            return "l.joystick.press.down.fill"
        case .rightStick:
            return "r.joystick.press.down.fill"
        case .dPadUp:
            return "arrowtriangle.up.circle.fill"
        case .dPadDown:
            return "arrowtriangle.down.circle.fill"
        case .dPadLeft:
            return "arrowtriangle.left.circle.fill"
        case .dPadRight:
            return "arrowtriangle.right.circle.fill"
        case .leftTrigger:
            return "zl.rectangle.roundedtop.fill"
        case .rightTrigger:
            return "zr.rectangle.roundedtop.fill"
        case .leftShoulder:
            return "l.rectangle.roundedbottom.fill"
        case .rightShoulder:
            return "r.rectangle.roundedbottom.fill"
        case .start:
            return "plus.circle.fill"
        case .back:
            return "minus.circle.fill"
        case .guide:
            return "house.circle.fill"
        }
    }
}
