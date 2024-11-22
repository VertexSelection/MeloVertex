//
//  GameListView.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

// MARK: - This will most likely not be used in prod
import SwiftUI

struct GameListView: View {
    @Binding var startemu: URL?
    @State private var games: [URL] = []

    var body: some View {
        List(games, id: \.self) { game in
            Button {
                startemu = game
            } label: {
                Text(game.lastPathComponent)
            }
        }
        .navigationTitle("Games")
        .onAppear(perform: loadGames)
    }

    private func loadGames() {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let romsDirectory = documentsDirectory.appendingPathComponent("roms")
        
        // Check if "roms" folder exists; if not, create it
        if !fileManager.fileExists(atPath: romsDirectory.path) {
            do {
                try fileManager.createDirectory(at: romsDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create roms directory: \(error)")
            }
        }

        // Load games only from "roms" folder
        do {
            let files = try fileManager.contentsOfDirectory(at: romsDirectory, includingPropertiesForKeys: nil)
            games = files
        } catch {
            print("Error loading games from roms folder: \(error)")
        }
    }
}
