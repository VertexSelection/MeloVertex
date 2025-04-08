//
//  LaunchGameIntentDef.swift
//  MeloNX
//
//  Created by Stossy11 on 10/02/2025.
//


import Foundation
import SwiftUI
import Intents
import AppIntents

@available(iOS 16.0, *)
struct LaunchGameIntentDef: AppIntent {
    
    static let title: LocalizedStringResource = "Launch Game"
    
    static var description = IntentDescription("Launches the Selected Game.")

    @Parameter(title: "Game", optionsProvider: GameOptionsProvider())
    var gameName: String

    static var parameterSummary: some ParameterSummary {
        Summary("Launch \(\.$gameName)")
    }
    
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        
        let ryujinx = Ryujinx.shared.games
        
        let name = findClosestGameName(input: gameName, games: ryujinx.compactMap(\.titleName))
        
        let urlString = "melonx://game?name=\(name ?? gameName)"
        // print(urlString)
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        return .result()
    }
    
    func levenshteinDistance(_ a: String, _ b: String) -> Int {
        let aCount = a.count
        let bCount = b.count
        var matrix = [[Int]](repeating: [Int](repeating: 0, count: bCount + 1), count: aCount + 1)
        
        for i in 0...aCount {
            matrix[i][0] = i
        }
        
        for j in 0...bCount {
            matrix[0][j] = j
        }
        
        for i in 1...aCount {
            for j in 1...bCount {
                let cost = a[a.index(a.startIndex, offsetBy: i - 1)] == b[b.index(b.startIndex, offsetBy: j - 1)] ? 0 : 1
                matrix[i][j] = min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost)
            }
        }
        
        return matrix[aCount][bCount]
    }

    func findClosestGameName(input: String, games: [String]) -> String? {
        let closestGame = games.min { a, b in
            let distanceA = levenshteinDistance(input, a)
            let distanceB = levenshteinDistance(input, b)
            return distanceA < distanceB
        }
        return closestGame
    }
}

@available(iOS 16.0, *)
struct GameOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [String] {
        let dynamicGames = Ryujinx.shared.loadGames()
        
        return dynamicGames.map { $0.titleName }
    }
}
