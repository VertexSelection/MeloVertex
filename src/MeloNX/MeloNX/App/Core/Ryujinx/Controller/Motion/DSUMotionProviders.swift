//
//  DSUMotionProviders.swift
//
//  Multi-source Cemuhook-compatible DSU server.
//  Created by MediaMoots on 5/17/2025.
//
//

import CoreMotion
import GameController           // GCController

//──────────────────────────────────────────────────────────────────────── MARK:- Providers

/// iPhone / iPad IMU
final class DeviceMotionProvider: DSUMotionProvider {

    // ───── DSUMotionProvider conformance
    let slot: UInt8
    let mac:  [UInt8] = [0xAB,0x12,0xCD,0x34,0xEF,0x56]
    let connectionType: UInt8 = 2
    let batteryLevel:   UInt8 = 5
    let motionRate:     Double = 60.0          // 60 Hz

    // ───── Internals
    private let mm = CMMotionManager()
    
    // Thread Safety
    private let dataLock = NSLock()
    private var _latest: CMDeviceMotion?
    private var latest: CMDeviceMotion? {
        get { dataLock.lock(); defer { dataLock.unlock() }; return _latest }
        set { dataLock.lock(); _latest = newValue; dataLock.unlock() }
    }

    private var orientation: UIDeviceOrientation =
        UIDevice.current.orientation == .unknown ? .landscapeLeft : UIDevice.current.orientation

    init(slot: UInt8) {
        precondition(slot < 8, "DSU only supports slots 0…7")
        self.slot = slot

        // ── start Core Motion
        mm.deviceMotionUpdateInterval = 1.0 / motionRate
        mm.startDeviceMotionUpdates(to: .main) { [weak self] m, _ in
            guard let self = self, let m = m else { return }
            self.latest = m
            if let sample = self.nextSample() {
                DSUServer.shared.pushSample(sample, from: self)
            }
        }

        // ── track orientation changes (ignore flat)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    @objc private func orientationDidChange() {
        let o = UIDevice.current.orientation
        if o.isFlat { return }          // ignore face-up / face-down
        orientation = o
    }

    func nextSample() -> DSUMotionSample? {
        guard let m = latest else { return nil }

        // Raw values
        let gx = Float(m.rotationRate.x)
        let gy = Float(m.rotationRate.y)
        let gz = Float(m.rotationRate.z)
        let ax = Float(m.gravity.x + m.userAcceleration.x)
        let ay = Float(m.gravity.y + m.userAcceleration.y)
        let az = Float(m.gravity.z + m.userAcceleration.z)

        // Rotate axes to match Cemuhook's "landscape-left as neutral" convention
        let a: SIMD3<Float>
        let g: SIMD3<Float>

        switch orientation {
        case .portrait:
            a = SIMD3(  ax,  az, -ay)
            g = SIMD3(  gx, -gz,  gy)
        case .landscapeRight:
            a = SIMD3(  ay,  az,  ax)
            g = SIMD3(  gy, -gz, -gx)
        case .portraitUpsideDown:
            a = SIMD3( -ax,  az,  ay)
            g = SIMD3( -gx, -gz, -gy)
        case .landscapeLeft, .unknown, .faceUp, .faceDown:
            a = SIMD3( -ay,  az, -ax)
            g = SIMD3( -gy, -gz,  gx)
        @unknown default:
            return nil
        }

        // Convert gyro rad/s → °/s here so the server doesn't have to.
        let gDeg = g * (180 / .pi)

        return DSUMotionSample(timestampUS: currentUS(),
                               accel: a,
                               gyroDeg: gDeg)
    }
}

// Any Switch Pro / DualSense controller that exposes `GCMotion`
final class ControllerMotionProvider: DSUMotionProvider {

    // DSUMotionProvider
    let slot: UInt8
    let mac:  [UInt8] = [0xAB,0x12,0xCD,0x34,0xEF,0x56]
    let connectionType: UInt8 = 2
    var batteryLevel: UInt8 {
        UInt8((pad.battery?.batteryLevel ?? 0.3) * 5).clamped(to: 0...5)
    }

    private let pad: GCController
    
    // Thread Safety
    private let dataLock = NSLock()
    private var _latest: GCMotion?
    private var latest: GCMotion? {
        get { dataLock.lock(); defer { dataLock.unlock() }; return _latest }
        set { dataLock.lock(); _latest = newValue; dataLock.unlock() }
    }

    init(controller: GCController, slot: UInt8) {
        self.pad  = controller
        self.slot = slot
        pad.motion?.sensorsActive = true
        pad.motion?.valueChangedHandler = { [weak self] motion in
            guard let self = self else { return }
            self.latest = motion
            if let sample = self.nextSample() {
                DSUServer.shared.pushSample(sample, from: self)
            }
        }
    }

    func nextSample() -> DSUMotionSample? {
        guard let m = latest else { return nil }

        // Extract and convert acceleration to SIMD3<Float>
        let a = SIMD3<Float>(
            Float(m.acceleration.x),
            Float(m.acceleration.z),
            -Float(m.acceleration.y)
        )

        // Extract, transform, and convert rotation rate to SIMD3<Float> (in radians/s)
        let g = SIMD3<Float>(
            Float(m.rotationRate.x),
            -Float(m.rotationRate.z),
            Float(m.rotationRate.y)
        )

        // Convert gyro rotation rate from rad/s to degrees/s
        let gDeg = g *  (180 / .pi)

        return DSUMotionSample(
            timestampUS: currentUS(),
            accel: a,
            gyroDeg: gDeg
        )
    }
}

//──────────────────────────────────────────────────────────────────────── MARK:- Helper funcs / ext

private func uint64US(_ time: TimeInterval) -> UInt64 { UInt64(time * 1_000_000) }
private func currentUS() -> UInt64 { uint64US(CACurrentMediaTime()) }

private extension Comparable {
    func clamped(to r: ClosedRange<Self>) -> Self { min(max(self, r.lowerBound), r.upperBound) }
}
