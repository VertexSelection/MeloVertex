//
//  AspectRatio.swift
//  MeloNX
//
//  Created by Stossy11 on 16/02/2025.
//

import Foundation

public enum AspectRatio: String, Codable, CaseIterable {
    case fixed4x3 = "Fixed4x3"
    case fixed16x9 = "Fixed16x9"
    case fixed16x10 = "Fixed16x10"
    case fixed21x9 = "Fixed21x9"
    case fixed32x9 = "Fixed32x9"
    case stretched = "Stretched"

    var displayName: String {
        switch self {
        case .fixed4x3: return "4:3"
        case .fixed16x9: return "16:9 (Default)"
        case .fixed16x10: return "16:10"
        case .fixed21x9: return "21:9"
        case .fixed32x9: return "32:9"
        case .stretched: return "Stretched (Full Screen)"
        }
    }
}
