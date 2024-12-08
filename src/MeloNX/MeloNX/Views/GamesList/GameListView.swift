//
//  GameListView.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

// MARK: - This will most likely not be used in prod
import SwiftUI
import UniformTypeIdentifiers

public struct Game: Identifiable, Equatable {
    public var id = UUID()

    var containerFolder: URL
    var fileType: UTType
    
    var fileURL: URL

    var titleName: String
    var titleId: String
    var developer: String
    var version: String
    var icon: Image?
}

struct GameListView: View {
    @Binding var startemu: URL?
    @State private var games: [Game] = []

    var body: some View {
        List($games, id: \.id) { $game in
            Button {
                startemu = $game.wrappedValue.fileURL
            } label: {
                Text(game.titleName)
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
            
            files.forEach { fileURLCandidate in
                do {
                    let handle = try FileHandle(forReadingFrom: fileURLCandidate)
                    let fileExtension = (fileURLCandidate.pathExtension as NSString).utf8String
                    let extensionPtr = UnsafeMutablePointer<CChar>(mutating: fileExtension)
                    
                    var gameInfo = get_game_info(handle.fileDescriptor, extensionPtr)
                    
                    var game = Game(containerFolder: romsDirectory, fileType: .item, fileURL: fileURLCandidate, titleName: "", titleId: "", developer: "", version: "")
                    
                    game.titleName = withUnsafePointer(to: &gameInfo.TitleName) {
                         $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: $0)) {
                             String(cString: $0)
                         }
                     }

                    game.developer = withUnsafePointer(to: &gameInfo.Developer) {
                         $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: $0)) {
                             String(cString: $0)
                         }
                     }
                    
                    game.titleId = String(gameInfo.TitleId)
                    
                    
                    game.version = String(gameInfo.Version)
                    
                    
                    games.append(game)
                } catch {
                    print(error)
                }
            }
            
        } catch {
            print("Error loading games from roms folder: \(error)")
        }
    }
}
