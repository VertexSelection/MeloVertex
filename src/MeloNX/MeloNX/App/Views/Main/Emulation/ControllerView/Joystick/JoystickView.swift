//
//  JoystickView.swift
//  Pomelo
//
//  Created by Stossy11 on 30/9/2024.
//  Copyright © 2024 Stossy11. All rights reserved.
//

import SwiftUI

struct JoystickController: View {
    @State var iscool: Bool? = nil
    @Environment(\.colorScheme) var colorScheme
    @Binding var showBackground: Bool
    @AppStorage("On-ScreenControllerScale") var controllerScale: Double = 1.0
    @State var position: CGPoint = CGPoint(x: 0, y: 0)
    var dragDiameter: CGFloat {
        var selfs = CGFloat(160)
        // selfs *= controllerScale
        if UIDevice.current.systemName.contains("iPadOS") {
            return selfs * 1.2
        }
        
        return selfs
    }
    
    public var body: some View {
        VStack {
            Joystick(position: $position, joystickSize: dragDiameter * 0.2, boundarySize: dragDiameter, showBackground: $showBackground)
                .onChange(of: position) { newValue in
                    if iscool != nil {
                        Ryujinx.shared.virtualController.thumbstickMoved(.right, x: newValue.x, y: newValue.y)
                    } else {
                        Ryujinx.shared.virtualController.thumbstickMoved(.left, x: newValue.x, y: newValue.y)
                    }
                }
        }
    }
}
