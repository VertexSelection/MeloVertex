//
//  EntitlementChecker.swift
//  MeloNX
//
//  Created by Stossy11 on 15/02/2025.
//

import Foundation
import Security

typealias SecTaskRef = OpaquePointer

@_silgen_name("SecTaskCopyValueForEntitlement")
func SecTaskCopyValueForEntitlement(
    _ task: SecTaskRef,
    _ entitlement: NSString,
    _ error: NSErrorPointer
) -> CFTypeRef?

@_silgen_name("SecTaskCreateFromSelf")
func SecTaskCreateFromSelf(
    _ allocator: CFAllocator?
) -> SecTaskRef?

@_silgen_name("SecTaskCopyValuesForEntitlements")
func SecTaskCopyValuesForEntitlements(
    _ task: SecTaskRef,
    _ entitlements: CFArray,
    _ error: UnsafeMutablePointer<Unmanaged<CFError>?>?
) -> CFDictionary?

func checkAppEntitlements(_ ents: [String]) -> [String: Any] {
    guard let task = SecTaskCreateFromSelf(nil) else {
        // print("Failed to create SecTask")
        return [:]
    }
    
    guard let entitlements = SecTaskCopyValuesForEntitlements(task, ents as CFArray, nil) else {
        // print("Failed to get entitlements")
        return [:]
    }
    
    return (entitlements as? [String: Any]) ?? [:]
}

func checkAppEntitlement(_ ent: String) -> Bool {
    guard let task = SecTaskCreateFromSelf(nil) else {
        // print("Failed to create SecTask")
        return false
    }
    
    guard let entitlements = SecTaskCopyValueForEntitlement(task, ent as NSString, nil) else {
        // print("Failed to get entitlements")
        return false
    }
    
    return entitlements.boolValue != nil && entitlements.boolValue
}
