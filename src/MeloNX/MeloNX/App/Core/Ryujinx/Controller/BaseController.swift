//
//  BaseController.swift
//  MeloNX
//
//  Created by MediaMoots on 5/17/2025.
//

//──────────────────────────────────────────────────────────────────────── MARK:- Base Controller Protocol

/// Base Controller with motion related functions
protocol BaseController: AnyObject {
    func tryRegisterMotion(slot: UInt8)
    func tryGetMotionProvider() -> DSUMotionProvider?
}
