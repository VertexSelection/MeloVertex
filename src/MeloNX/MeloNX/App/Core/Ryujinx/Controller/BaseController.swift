//
//  BaseController.swift
//  MeloNX
//
//  Created by MediaMoots on 5/17/2025.
//

//──────────────────────────────────────────────────────────────────────── MARK:- Base Controller Protocol

/// One motion source == one DSU *slot* (0-7).
protocol BaseController: AnyObject {
    func tryRegisterMotion(slot: UInt8)
    func tryGetMotionProvider() -> DSUMotionProvider?
}
