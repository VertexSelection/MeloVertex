//
//  Language.swift
//  MeloNX
//
//  Created by Stossy11 on 16/02/2025.
//

import Foundation

public enum SystemLanguage: String, Codable, CaseIterable {
    case japanese = "Japanese"
    case americanEnglish = "AmericanEnglish"
    case french = "French"
    case german = "German"
    case italian = "Italian"
    case spanish = "Spanish"
    case chinese = "Chinese"
    case korean = "Korean"
    case dutch = "Dutch"
    case portuguese = "Portuguese"
    case russian = "Russian"
    case taiwanese = "Taiwanese"
    case britishEnglish = "BritishEnglish"
    case canadianFrench = "CanadianFrench"
    case latinAmericanSpanish = "LatinAmericanSpanish"
    case simplifiedChinese = "SimplifiedChinese"
    case traditionalChinese = "TraditionalChinese"
    case brazilianPortuguese = "BrazilianPortuguese"

    var displayName: String {
        switch self {
        case .japanese: return "Japanese"
        case .americanEnglish: return "American English"
        case .french: return "French"
        case .german: return "German"
        case .italian: return "Italian"
        case .spanish: return "Spanish"
        case .chinese: return "Chinese"
        case .korean: return "Korean"
        case .dutch: return "Dutch"
        case .portuguese: return "Portuguese"
        case .russian: return "Russian"
        case .taiwanese: return "Taiwanese"
        case .britishEnglish: return "British English"
        case .canadianFrench: return "Canadian French"
        case .latinAmericanSpanish: return "Latin American Spanish"
        case .simplifiedChinese: return "Simplified Chinese"
        case .traditionalChinese: return "Traditional Chinese"
        case .brazilianPortuguese: return "Brazilian Portuguese"
        }
    }
}
