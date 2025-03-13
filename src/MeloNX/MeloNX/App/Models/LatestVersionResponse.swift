//
//  LatestVersionResponse.swift
//  MeloNX
//
//  Created by Bella on 12/03/2025.
//


struct LatestVersionResponse: Codable {
    let version_number: String
    let version_number_stripped: String
    let changelog: String
    let download_link: String
    
    #if DEBUG
    static let example1 = LatestVersionResponse(
        version_number: "1.0.0",
        version_number_stripped: "100",
        changelog: """
            - Rewrite Display Code (SDL isn't used for display anymore)
            - Add New Onboarding / Setup
            - Better Performance
            - Remove "SDL Window" option in settings
            - Fix JIT Cache Regions
            - Fix how JIT is detected in Settings
            - Fix ABYX being swapped on controller.
            - Settings are now a config.json file
            - Fix Performance Overlay not showing when Virtual Controller is hidden
            - Add displaying logs when Loading or in-game
            - Fix Launching games from outside of the roms folder
            - Add Waiting for JIT popup
            - Fix spesific Games
            - Added Back Herobrine ("You were supposed to be the hero, Bryan")
        """,
        download_link: "https://example.com"
    )
    #endif
}