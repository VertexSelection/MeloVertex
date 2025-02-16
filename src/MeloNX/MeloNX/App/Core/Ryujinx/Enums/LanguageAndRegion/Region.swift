//
//  Region.swift
//  MeloNX
//
//  Created by Stossy11 on 16/02/2025.
//

import Foundation

public enum SystemRegionCode: String, Codable, CaseIterable {
    case japan = "Japan"
    case usa = "USA"
    case europe = "Europe"
    case australia = "Australia"
    case china = "China"
    case korea = "Korea"
    case taiwan = "Taiwan"
    
    var displayName: String {
        switch self {
        case .japan: return "Japan"
        case .usa: return "United States"
        case .europe: return "Europe"
        case .australia: return "Australia"
        case .china: return "China"
        case .korea: return "Korea"
        case .taiwan: return "Taiwan"
        }
    }
}

