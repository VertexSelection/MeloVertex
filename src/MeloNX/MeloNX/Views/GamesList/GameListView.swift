//
//  GameListView.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import SwiftUI
import UniformTypeIdentifiers


struct GameLibraryView: View {
    @Binding var startemu: URL?
    @State private var games: [Game] = []
    @State private var searchText = ""
    @State private var isSearching = false
    @AppStorage("recentGames") private var recentGamesData: Data = Data()
    @State private var recentGames: [Game] = []
    @Environment(\.colorScheme) var colorScheme
    @State var firmwareInstaller = false
    @State var firmwareversion = "0"
    @State var isImporting: Bool = false
    @State var startgame = false
    
    
    var filteredGames: [Game] {
        if searchText.isEmpty {
            return games
        }
        return games.filter {
            $0.titleName.localizedCaseInsensitiveContains(searchText) ||
            $0.developer.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        iOSNav {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    if !isSearching {
                        Text("Games")
                            .font(.system(size: 34, weight: .bold))
                            .padding(.horizontal)
                            .padding(.top, 12)
                    }
                    
                    if games.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.secondary.opacity(0.7))
                                .padding(.top, 60)
                            Text("No Games Found")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                            Text("Add ROM, Keys and Firmware to get started")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else {
                        if !isSearching && !recentGames.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent")
                                    .font(.title2.bold())
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 16) {
                                        ForEach(recentGames) { game in
                                            RecentGameCard(game: game, startemu: $startemu)
                                                .onTapGesture {
                                                    addToRecentGames(game)
                                                    startemu = game.fileURL
                                                }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("All Games")
                                    .font(.title2.bold())
                                    .padding(.horizontal)
                                
                                LazyVStack(spacing: 2) {
                                    ForEach(filteredGames) { game in
                                        GameListRow(game: game, startemu: $startemu)
                                            .onTapGesture {
                                                addToRecentGames(game)
                                            }
                                    }
                                }
                            }
                        } else {
                            LazyVStack(spacing: 2) {
                                ForEach(filteredGames) { game in
                                    GameListRow(game: game, startemu: $startemu)
                                        .onTapGesture {
                                            addToRecentGames(game)
                                        }
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    loadGames()
                    loadRecentGames()
                    
                    
                    let firmware = Ryujinx.shared.fetchFirmwareVersion()
                    firmwareversion = (firmware == "" ? "0" : firmware)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        
                        Text("Firmware Version: \(firmwareversion)")
                            .tint(.white)
                        
                        if firmwareversion == "0" {
                            Button {
                                firmwareInstaller.toggle()
                            } label: {
                                Text("Install Firmware")
                            }
                            
                        } else {
                            Button {
                                Ryujinx.shared.removeFirmware()
                                let firmware = Ryujinx.shared.fetchFirmwareVersion()
                                firmwareversion = (firmware == "" ? "0" : firmware)
                            } label: {
                                Text("Remove Firmware")
                            }
                            
                            
                            Button {
                                self.startemu = URL(string: "MiiMaker")
                            } label: {
                                Text("Mii Maker")
                            }
                            Button {
                                
                                isImporting.toggle()
                            } label: {
                                Text("Open game from system")
                            }
                        }
                        
                        Button {
                            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let sharedurl = documentsUrl.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
                            let furl = URL(string: sharedurl)!
                            if UIApplication.shared.canOpenURL(furl) {
                                UIApplication.shared.open(furl, options: [:])
                            }
                        } label: {
                            Text("Show MeloNX Folder")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.blue)
                    }
                    
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .searchable(text: $searchText)
        .onChange(of: searchText) { _ in
            isSearching = !searchText.isEmpty
        }
        .fileImporter(isPresented: $firmwareInstaller, allowedContentTypes: [.item]) { result in
            switch result {
                
            case .success(let url):
                
                do {
                    
                    let fun = url.startAccessingSecurityScopedResource()
                    let path = url.path
                    
                    Ryujinx.shared.installFirmware(firmwarePath: path)
                    
                    firmwareversion = (Ryujinx.shared.fetchFirmwareVersion() == "" ? "0" : Ryujinx.shared.fetchFirmwareVersion())
                    if fun  {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.zip, .data]) { result in
            switch result {
            case .success(let url):
                guard url.startAccessingSecurityScopedResource() else {
                    print("Failed to access security-scoped resource")
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }
                
                
                startemu = url

            case .failure(let err):
                print("File import failed: \(err.localizedDescription)")
            }
        }


    }
    
    
    private func addToRecentGames(_ game: Game) {
        recentGames.removeAll { $0.id == game.id }
        
        recentGames.insert(game, at: 0)
        
        if recentGames.count > 5 {
            recentGames = Array(recentGames.prefix(5))
        }
        
        saveRecentGames()
    }
    
    private func saveRecentGames() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(recentGames)
            recentGamesData = data
        } catch {
            print("Error saving recent games: \(error)")
        }
    }
    
    private func loadRecentGames() {
        do {
            let decoder = JSONDecoder()
            recentGames = try decoder.decode([Game].self, from: recentGamesData)
        } catch {
            print("Error loading recent games: \(error)")
            recentGames = []
        }
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
        games = []
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
                    
                    game.icon = game.createImage(from: gameInfo)
            
                    
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

// Make sure your Game model conforms to Codable
extension Game: Codable {
    enum CodingKeys: String, CodingKey {
        case titleName, titleId, developer, version, fileURL
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        titleName = try container.decode(String.self, forKey: .titleName)
        titleId = try container.decode(String.self, forKey: .titleId)
        developer = try container.decode(String.self, forKey: .developer)
        version = try container.decode(String.self, forKey: .version)
        fileURL = try container.decode(URL.self, forKey: .fileURL)
        
        // Initialize other properties
        self.containerFolder = fileURL.deletingLastPathComponent()
        self.fileType = .item
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(titleName, forKey: .titleName)
        try container.encode(titleId, forKey: .titleId)
        try container.encode(developer, forKey: .developer)
        try container.encode(version, forKey: .version)
        try container.encode(fileURL, forKey: .fileURL)
    }
}

struct RecentGameCard: View {
    let game: Game
    @Binding var startemu: URL?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            startemu = game.fileURL
        }) {
            VStack(alignment: .leading, spacing: 8) {
                if let icon = game.icon {
                    Image(uiImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 140, height: 140)
                        .cornerRadius(12)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorScheme == .dark ?
                                  Color(.systemGray5) : Color(.systemGray6))
                            .frame(width: 140, height: 140)
                        
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(game.titleName)
                        .font(.subheadline.bold())
                        .lineLimit(1)
                    
                    Text(game.developer)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 4)
            }
        }
        .buttonStyle(.plain)
    }
}

struct GameListRow: View {
    let game: Game
    @Binding var startemu: URL?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            startemu = game.fileURL
        }) {
            HStack(spacing: 16) {
                // Game Icon
                if let icon = game.icon {
                    Image(uiImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 45, height: 45)
                        .cornerRadius(8)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(colorScheme == .dark ?
                                  Color(.systemGray5) : Color(.systemGray6))
                            .frame(width: 45, height: 45)
                        
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }
                }
                
                // Game Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(game.titleName)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text(game.developer)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .opacity(0.8)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .contextMenu {
                Button {
                    startemu = game.fileURL
                } label: {
                    Label("Play Now", systemImage: "play.fill")
                }
                
                Button {
                    // Add info action
                } label: {
                    Label("Game Info", systemImage: "info.circle")
                }
            }
        }
        .buttonStyle(.plain)
    }
}
