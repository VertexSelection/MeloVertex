//
//  ControllerView.swift
//  Pomelo-V2
//
//  Created by Stossy11 on 16/7/2024.
//

import SwiftUI
import GameController
import SwiftUIJoystick
import CoreMotion

struct ControllerView: View {
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.height > geometry.size.width && UIDevice.current.userInterfaceIdiom != .pad {
                VStack {
                    Spacer()
                    VStack {
                        HStack {
                            VStack {
                                ShoulderButtonsViewLeft()
                                ZStack {
                                    Joystick()
                                    DPadView()
                                }
                            }
                            .padding()
                            VStack {
                                ShoulderButtonsViewRight()
                                ZStack {
                                    Joystick(iscool: true) // hope this works
                                    ABXYView()
                                }
                            }
                            .padding()
                        }
                        
                        HStack {
                            ButtonView(button: .start) // Adding the + button
                                .padding(.horizontal, 40)
                            ButtonView(button: .back) // Adding the - button
                                .padding(.horizontal, 40)
                        }
                    }
                    .padding(.bottom, geometry.size.height / 3.2) // very broken
                }
            } else {
                // could be landscape
                VStack {
                    Spacer()
                    VStack {
                        HStack {
                            
                            // gotta fuckin add + and - now
                            VStack {
                                ShoulderButtonsViewLeft()
                                ZStack {
                                    Joystick()
                                    DPadView()
                                }
                            }
                            HStack {
                                // Spacer()
                                VStack {
                                    // Spacer()
                                    ButtonView(button: .start) // Adding the + button
                                }
                                Spacer()
                                VStack {
                                    // Spacer()
                                    ButtonView(button: .back) // Adding the - button
                                }
                                // Spacer()
                            }
                            VStack {
                                ShoulderButtonsViewRight()
                                ZStack {
                                    Joystick(iscool: true) // hope this work s
                                    ABXYView()
                                }
                            }
                        }
                        
                    }
                    // .padding(.bottom, geometry.size.height / 11) // also extremally broken (
                }
            }
        }
        .padding()
    }
}

struct ShoulderButtonsViewLeft: View {
    @State var width: CGFloat = 160
    @State var height: CGFloat = 20
    var body: some View {
        HStack {
            ButtonView(button: .leftTrigger)
                .padding(.horizontal)
            ButtonView(button: .leftShoulder)
                .padding(.horizontal)
        }
        .frame(width: width, height: height)
        .onAppear() {
            if UIDevice.current.systemName.contains("iPadOS") {
                width *= 1.2
                height *= 1.2
            }
        }
    }
}

struct ShoulderButtonsViewRight: View {
    @State var width: CGFloat = 160
    @State var height: CGFloat = 20
    var body: some View {
        HStack {
            ButtonView(button: .rightShoulder)
                .padding(.horizontal)
            ButtonView(button: .rightTrigger)
                .padding(.horizontal)
        }
        .frame(width: width, height: height)
        .onAppear() {
            if UIDevice.current.systemName.contains("iPadOS") {
                width *= 1.2
                height *= 1.2
            }
        }
    }
}

struct DPadView: View {
    @State var size: CGFloat = 145
    var body: some View {
        VStack {
            ButtonView(button: .dPadUp)
            HStack {
                ButtonView(button: .dPadLeft)
                Spacer(minLength: 20)
                ButtonView(button: .dPadRight)
            }
            ButtonView(button: .dPadDown)
                .padding(.horizontal)
        }
        .frame(width: size, height: size)
        .onAppear() {
            if UIDevice.current.systemName.contains("iPadOS") {
                size *= 1.2
            }
        }
    }
}

struct ABXYView: View {
    @State var size: CGFloat = 145
    var body: some View {
        VStack {
            ButtonView(button: .X)
            HStack {
                ButtonView(button: .Y)
                Spacer(minLength: 20)
                ButtonView(button: .A)
            }
            ButtonView(button: .B)
                .padding(.horizontal)
        }
        .frame(width: size, height: size)
        .onAppear() {
            if UIDevice.current.systemName.contains("iPadOS") {
                size *= 1.2
            }
        }
    }
}

struct ButtonView: View {
    var button: VirtualControllerButton
    @State var width: CGFloat = 45
    @State var height: CGFloat = 45
    @State var isPressed = false
    @AppStorage("onscreenhandheld") var onscreenjoy: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    

    
    var body: some View {
        Image(systemName: buttonText)
            .resizable()
            .frame(width: width, height: height)
            .foregroundColor(colorScheme == .dark ? Color.gray : Color.gray)
            .opacity(isPressed ? 0.4 : 0.7)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !self.isPressed {
                            self.isPressed = true
                            Ryujinx.shared.virtualController.setButtonState(1, for: button)
                            Haptics.shared.play(.heavy)
                        }
                    }
                    .onEnded { _ in
                        self.isPressed = false
                        Ryujinx.shared.virtualController.setButtonState(0, for: button)
                    }
                )
            .onAppear() {
                if button == .leftTrigger || button == .rightTrigger || button == .leftShoulder || button == .rightShoulder {
                    width = 65
                }
            
                
                if button == .back || button == .start || button == .guide {
                    width = 35
                    height = 35
                }
                
                if UIDevice.current.systemName.contains("iPadOS") {
                    width *= 1.2
                    height *= 1.2
                }
            }
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
        case .dPadUp:
            return "arrowtriangle.up.circle.fill"
        case .dPadDown:
            return "arrowtriangle.down.circle.fill"
        case .dPadLeft:
            return "arrowtriangle.left.circle.fill"
        case .dPadRight:
            return "arrowtriangle.right.circle.fill"
        case .leftTrigger:
            return"zl.rectangle.roundedtop.fill"
        case .rightTrigger:
            return "zr.rectangle.roundedtop.fill"
        case .leftShoulder:
            return "l.rectangle.roundedbottom.fill"
        case .rightShoulder:
            return "r.rectangle.roundedbottom.fill"
        case .start:
            return "plus.circle.fill" // System symbol for +
        case .back:
            return "minus.circle.fill" // System symbol for -
        case .guide:
            return "house.circle.fill"
        // This should be all the cases
        default:
            return ""
        }
    }
}


