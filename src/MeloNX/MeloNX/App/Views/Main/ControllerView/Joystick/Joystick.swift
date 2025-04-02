//
//  Joystick.swift
//  MeloNX
//
//  Created by Stossy11 on 21/03/2025.
//


import SwiftUI

struct Joystick: View {
    @Binding var position: CGPoint
    @State var joystickSize: CGFloat
    var boundarySize: CGFloat
    
    @State private var offset: CGSize = .zero
    @Binding var showBackground: Bool
    
    let sensitivity: CGFloat = 1.5

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation(.easeIn) {
                    showBackground = true
                }
                
                let translation = value.translation
                let distance = sqrt(translation.width * translation.width + translation.height * translation.height)
                let maxRadius = (boundarySize - joystickSize) / 2
                let extendedRadius = maxRadius + (joystickSize / 2)
                
                if distance <= extendedRadius {
                    offset = translation
                } else {
                    let angle = atan2(translation.height, translation.width)
                    offset = CGSize(width: cos(angle) * extendedRadius, height: sin(angle) * extendedRadius)
                }
                
                position = CGPoint(
                    x: max(-1, min(1, (offset.width / extendedRadius) * sensitivity)),
                    y: max(-1, min(1, (offset.height / extendedRadius) * sensitivity))
                )
            }
            .onEnded { _ in
                offset = .zero
                position = .zero
                withAnimation(.easeOut) {
                    showBackground = false
                }
            }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.clear.opacity(0))
                .frame(width: boundarySize, height: boundarySize)
            
            if showBackground {
                Circle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: boundarySize, height: boundarySize)
                    .animation(.easeInOut(duration: 0.05), value: showBackground)
                    .transition(.scale)
            }
            
            Circle()
                .fill(Color.white.opacity(0.5))
                .frame(width: joystickSize, height: joystickSize)
                .background(
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: joystickSize * 1.25, height: joystickSize * 1.25)
                )
                .offset(offset)
                .gesture(dragGesture)
        }
        .frame(width: boundarySize, height: boundarySize)
        .onChange(of: showBackground) { newValue in
            if newValue {
                joystickSize *= 1.4
            } else {
                joystickSize = (boundarySize * 0.2)
            }
        }
    }
}
