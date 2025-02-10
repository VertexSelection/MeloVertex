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
        
        let urlString = "melonx://game?\(ryujinx.contains(where: { $0.titleName.localizedCaseInsensitiveContains(gameName) }) ? "name" : "id")=\(gameName)"
        print(urlString)
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        return .result()
    }
}

@available(iOS 16.0, *)
struct GameOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [String] {
        Ryujinx.shared.games = Ryujinx.shared.loadGames()
        
        let dynamicGames = Ryujinx.shared.games
        
        return dynamicGames.map { $0.titleName }
    }
}
