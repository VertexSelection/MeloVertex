//
//  MeloMTKView.swift
//  MeloNX
//
//  Created by Stossy11 on 03/03/2025.
//

import MetalKit
import UIKit

class MeloMTKView: MTKView {

    private var activeTouches: [UITouch] = []
    private var ignoredTouches: Set<UITouch> = []
    
    private let baseWidth: CGFloat = 1280
    private let baseHeight: CGFloat = 720
    private var aspectRatio: AspectRatio = .fixed16x9

    func setAspectRatio(_ ratio: AspectRatio) {
        self.aspectRatio = ratio
    }

    private func scaleToTargetResolution(_ location: CGPoint) -> CGPoint? {
        let viewWidth = self.frame.width
        let viewHeight = self.frame.height
        
        var scaleX: CGFloat
        var scaleY: CGFloat
        var offsetX: CGFloat = 0
        var offsetY: CGFloat = 0
        
        var targetAspect: CGFloat
        
        switch aspectRatio {
        case .fixed4x3:
            targetAspect = 4.0 / 3.0
        case .fixed16x9:
            targetAspect = 16.0 / 9.0
        case .fixed16x10:
            targetAspect = 16.0 / 10.0
        case .fixed21x9:
            targetAspect = 21.0 / 9.0
        case .fixed32x9:
            targetAspect = 32.0 / 9.0
        case .stretched:
            scaleX = baseWidth / viewWidth
            scaleY = baseHeight / viewHeight
            
            let adjustedX = location.x
            let adjustedY = location.y
            
            let scaledX = max(0, min(adjustedX * scaleX, baseWidth))
            let scaledY = max(0, min(adjustedY * scaleY, baseHeight))
            
            return CGPoint(x: scaledX, y: scaledY)
        }
        
        let viewAspect = viewWidth / viewHeight
        
        if viewAspect > targetAspect {
            let scaledWidth = viewHeight * targetAspect
            offsetX = (viewWidth - scaledWidth) / 2
            scaleX = baseWidth / scaledWidth
            scaleY = baseHeight / viewHeight
        } else {
            let scaledHeight = viewWidth / targetAspect
            offsetY = (viewHeight - scaledHeight) / 2
            scaleX = baseWidth / viewWidth
            scaleY = baseHeight / scaledHeight
        }
        
        if location.x < offsetX || location.x > (viewWidth - offsetX) ||
           location.y < offsetY || location.y > (viewHeight - offsetY) {
            return nil
        }
        
        let adjustedX = location.x - offsetX
        let adjustedY = location.y - offsetY
        
        let scaledX = max(0, min(adjustedX * scaleX, baseWidth))
        let scaledY = max(0, min(adjustedY * scaleY, baseHeight))

        return CGPoint(x: scaledX, y: scaledY)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        setAspectRatio(Ryujinx.shared.config?.aspectRatio ?? .fixed16x9)
        
        for touch in touches {
            let location = touch.location(in: self)
            if scaleToTargetResolution(location) == nil {
                ignoredTouches.insert(touch)
                continue
            }

            activeTouches.append(touch)
            let index = activeTouches.firstIndex(of: touch)!
            
            let scaledLocation = scaleToTargetResolution(location)!
            // // print("Touch began at: \(scaledLocation) and \(self.aspectRatio)")
            touch_began(Float(scaledLocation.x), Float(scaledLocation.y), Int32(index))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        setAspectRatio(Ryujinx.shared.config?.aspectRatio ?? .fixed16x9)
        
        for touch in touches {
            if ignoredTouches.contains(touch) {
                ignoredTouches.remove(touch)
                continue
            }

            if let index = activeTouches.firstIndex(of: touch) {
                activeTouches.remove(at: index)
                
                // // print("Touch ended for index \(index)")
                touch_ended(Int32(index))
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        setAspectRatio(Ryujinx.shared.config?.aspectRatio ?? .fixed16x9)
        
        for touch in touches {
            if ignoredTouches.contains(touch) {
                continue
            }

            let location = touch.location(in: self)
            guard let scaledLocation = scaleToTargetResolution(location) else {
                if let index = activeTouches.firstIndex(of: touch) {
                    activeTouches.remove(at: index)
                    // // print("Touch left active area, removed index \(index)")
                    touch_ended(Int32(index))
                }
                continue
            }
            
            if let index = activeTouches.firstIndex(of: touch) {
                // // print("Touch moved to: \(scaledLocation)")
                touch_moved(Float(scaledLocation.x), Float(scaledLocation.y), Int32(index))
            }
        }
    }
}
