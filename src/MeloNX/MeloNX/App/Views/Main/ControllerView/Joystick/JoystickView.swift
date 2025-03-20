//
//  JoystickView.swift
//  Pomelo
//
//  Created by Stossy11 on 30/9/2024.
//  Copyright © 2024 Stossy11. All rights reserved.
//

import SwiftUI
import SwiftUIJoystick

public struct Joystick: View {
    @State var iscool: Bool? = nil
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject public var joystickMonitor = JoystickMonitor()
    @AppStorage("On-ScreenControllerScale") var controllerScale: Double = 1.0
    var dragDiameter: CGFloat {
        var selfs = CGFloat(160)
        selfs *= controllerScale
        if UIDevice.current.systemName.contains("iPadOS") {
            return selfs * 1.2
        }
        
        return selfs
    }
    private let shape: JoystickShape = .circle
    
    public var body: some View {
        VStack{
            JoystickBuilder(
                monitor: self.joystickMonitor,
                width: self.dragDiameter,
                shape: .circle,
                background: {
                    Text("")
                        .hidden()
                },
                foreground: {
                    Circle()
                        .fill(colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7))
                        .background(
                            Circle()
                                .fill(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2))
                                .frame(width: (dragDiameter / 4) * 1.2, height: (dragDiameter / 4) * 1.2)
                        )
                },
                locksInPlace: false)
            .onChange(of: self.joystickMonitor.xyPoint) { newValue in
                let scaledX = Float(newValue.x)
                let scaledY = Float(newValue.y) // my dumbass broke this by having -y instead of y :/
                print("Joystick Position: (\(scaledX), \(scaledY))")
                
                if iscool != nil {
                    Ryujinx.shared.virtualController.thumbstickMoved(.right, x: newValue.x, y: newValue.y)
                } else {
                    Ryujinx.shared.virtualController.thumbstickMoved(.left, x: newValue.x, y: newValue.y)
                }
            }
        }
    }
}
