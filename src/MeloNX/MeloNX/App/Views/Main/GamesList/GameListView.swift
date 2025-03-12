//
//  GameListView.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let nsp = UTType(exportedAs: "com.nintendo.switch-package")
    static let xci = UTType(exportedAs: "com.nintendo.switch-cartridge")
}

struct GameLibraryView: View {
    @Binding var startemu: Game?
    // @State var importDLCs = false
    @State private var searchText = ""
    @State private var isSearching = false
    @AppStorage("recentGames") private var recentGamesData: Data = Data()
    @State private var recentGames: [Game] = []
    @Environment(\.colorScheme) var colorScheme
    @State var firmwareInstaller = false
    @State var firmwareversion = "0"
    @State var isImporting: Bool = false
    @State var startgame = false
    @State var isSelectingGameFile = false
    @State var isViewingGameInfo: Bool = false
    @State var isSelectingGameUpdate: Bool = false
    @State var isSelectingGameDLC: Bool = false
    @State var gameInfo: Game?
    var games: Binding<[Game]> {
        Binding(
            get: { Ryujinx.shared.games },
            set: { Ryujinx.shared.games = $0 }
        )
    }
    
    var filteredGames: [Game] {
        if searchText.isEmpty {
            return Ryujinx.shared.games.filter { game in
                !realRecentGames.contains(where: { $0.fileURL == game.fileURL })
            }
        }
        return Ryujinx.shared.games.filter {
            $0.titleName.localizedCaseInsensitiveContains(searchText) ||
            $0.developer.localizedCaseInsensitiveContains(searchText)
        }
    }

    var realRecentGames: [Game] {
        let games = Ryujinx.shared.games
        return recentGames.compactMap { recentGame in
            games.first(where: { $0.fileURL == recentGame.fileURL })
        }
    }

    var body: some View {
        iOSNav {
            List {
                if Ryujinx.shared.games.isEmpty {
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
                    if !isSearching && !realRecentGames.isEmpty {
                        Section {
                            ForEach(realRecentGames) { game in
                                GameListRow(game: game, startemu: $startemu, games: games, isViewingGameInfo: $isViewingGameInfo, isSelectingGameUpdate: $isSelectingGameUpdate, isSelectingGameDLC: $isSelectingGameDLC, gameInfo: $gameInfo)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            removeFromRecentGames(game)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        } header: {
                            Text("Recent")
                        }

                        Section {
                            ForEach(filteredGames) { game in
                                GameListRow(game: game, startemu: $startemu, games: games, isViewingGameInfo: $isViewingGameInfo, isSelectingGameUpdate: $isSelectingGameUpdate, isSelectingGameDLC: $isSelectingGameDLC, gameInfo: $gameInfo)
                            }
                        } header: {
                            Text("Others")
                        }
                    } else {
                        ForEach(filteredGames) { game in
                            GameListRow(game: game, startemu: $startemu, games: games, isViewingGameInfo: $isViewingGameInfo, isSelectingGameUpdate: $isSelectingGameUpdate, isSelectingGameDLC: $isSelectingGameDLC, gameInfo: $gameInfo)
                        }
                    }
                }
            }
            .navigationTitle("Games")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadRecentGames()
                    
                let firmware = Ryujinx.shared.fetchFirmwareVersion()
                firmwareversion = (firmware == "" ? "0" : firmware)
            }
            .fileImporter(isPresented: $firmwareInstaller, allowedContentTypes: [.item]) { result in
                switch result {
                case .success(let url):
                    do {
                        let fun = url.startAccessingSecurityScopedResource()
                        let path = url.path
                            
                        Ryujinx.shared.installFirmware(firmwarePath: path)
                            
                        firmwareversion = (Ryujinx.shared.fetchFirmwareVersion() == "" ? "0" : Ryujinx.shared.fetchFirmwareVersion())
                        if fun {
                            url.stopAccessingSecurityScopedResource()
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isSelectingGameFile = true
                        
                        isImporting = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Text("Firmware Version: \(firmwareversion)")
                            .tint(.white)
                        
                        if firmwareversion == "0" {
                            Button {
                                DispatchQueue.main.async {
                                    firmwareInstaller.toggle()
                                }
                            } label: {
                                Text("Install Firmware")
                            }
                            
                        } else {
                            Menu("Firmware") {
                                Button {
                                    Ryujinx.shared.removeFirmware()
                                    let firmware = Ryujinx.shared.fetchFirmwareVersion()
                                    firmwareversion = (firmware == "" ? "0" : firmware)
                                } label: {
                                    Text("Remove Firmware")
                                }
                                
                                Button {
                                    let game = Game(containerFolder: URL(string: "none")!, fileType: .item, fileURL: URL(string: "MiiMaker")!, titleName: "Mii Maker", titleId: "0", developer: "Nintendo", version: firmwareversion)
                                    
                                    self.startemu = game
                                } label: {
                                    Text("Mii Maker")
                                }
                            }
                        }
                        
                        Button {
                            isSelectingGameFile = false
                            
                            isImporting = true
                        } label: {
                            Text("Open Game")
                        }
                        
                        Button {
                            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            var sharedurl = documentsUrl.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
                            if ProcessInfo.processInfo.isiOSAppOnMac {
                                sharedurl = documentsUrl.absoluteString
                            }
                            print(sharedurl)
                            let furl = URL(string: sharedurl)!
                            if UIApplication.shared.canOpenURL(furl) {
                                UIApplication.shared.open(furl, options: [:])
                            }
                        } label: {
                            Text("Show MeloNX Folder")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
            .onChange(of: startemu) { game in
                guard let game else { return }
                addToRecentGames(game)
            }
        }
        .searchable(text: $searchText)
        .animation(.easeInOut, value: searchText)
        .onChange(of: searchText) { _ in
            isSearching = !searchText.isEmpty
        }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.folder, .nsp, .xci, .zip, .item]) { result in
            if isSelectingGameFile {
                switch result {
                case .success(let url):
                    guard url.startAccessingSecurityScopedResource() else {
                        print("Failed to access security-scoped resource")
                        return
                    }
                    defer { url.stopAccessingSecurityScopedResource() }
                    
                    do {
                        let fileManager = FileManager.default
                        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let romsDirectory = documentsDirectory.appendingPathComponent("roms")
                        
                        if !fileManager.fileExists(atPath: romsDirectory.path) {
                            try fileManager.createDirectory(at: romsDirectory, withIntermediateDirectories: true, attributes: nil)
                        }
                        
                        let destinationURL = romsDirectory.appendingPathComponent(url.lastPathComponent)
                        try fileManager.copyItem(at: url, to: destinationURL)
                        
                        Ryujinx.shared.games = Ryujinx.shared.loadGames()
                    } catch {
                        print("Error copying game file: \(error)")
                    }
                case .failure(let err):
                    print("File import failed: \(err.localizedDescription)")
                }
                
            } else {
                
                switch result {
                case .success(let url):
                    guard url.startAccessingSecurityScopedResource() else {
                        print("Failed to access security-scoped resource")
                        return
                    }
                    
                    do {
                        let handle = try FileHandle(forReadingFrom: url)
                        let fileExtension = (url.pathExtension as NSString).utf8String
                        let extensionPtr = UnsafeMutablePointer<CChar>(mutating: fileExtension)
                        
                        let gameInfo = get_game_info(handle.fileDescriptor, extensionPtr)
                        
                        let game = Game.convertGameInfoToGame(gameInfo: gameInfo, url: url)
                        
                        DispatchQueue.main.async {
                            startemu = game
                        }
                    } catch {
                        print(error)
                    }
                    
                case .failure(let err):
                    print("File import failed: \(err.localizedDescription)")
                }
            }
        }
        .sheet(isPresented: $isSelectingGameUpdate) {
            UpdateManagerSheet(game: $gameInfo)
        }
        .sheet(isPresented: $isSelectingGameDLC) {
            DLCManagerSheet(game: $gameInfo)
        }
        .sheet(isPresented: Binding(
            get: { isViewingGameInfo && gameInfo != nil },
            set: { newValue in
                if !newValue {
                    isViewingGameInfo = false
                    gameInfo = nil
                }
            }
        )) {
            if let game = gameInfo {
                GameInfoSheet(game: game)
            }
        }
    }
    
    private func addToRecentGames(_ game: Game) {
        recentGames.removeAll { $0.titleId == game.titleId }

        recentGames.insert(game, at: 0)
        
        if recentGames.count > 5 {
            recentGames = Array(recentGames.prefix(5))
        }
        
        saveRecentGames()
    }

    private func removeFromRecentGames(_ game: Game) {
        recentGames.removeAll { $0.titleId == game.titleId }
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

    // MARK: - Delete Game Function
    func deleteGame(game: Game) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: game.fileURL)
            Ryujinx.shared.games.removeAll { $0.id == game.id }
            Ryujinx.shared.games = Ryujinx.shared.loadGames()
        } catch {
            print("Error deleting game: \(error)")
        }
    }
}

// MARK: - Game Model
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

// MARK: - Game List Item
struct GameListRow: View {
    let game: Game
    @Binding var startemu: Game?
    @Binding var games: [Game] // Add this binding
    @Binding var isViewingGameInfo: Bool
    @Binding var isSelectingGameUpdate: Bool
    @Binding var isSelectingGameDLC: Bool
    @Binding var gameInfo: Game?
    @State var gametoDelete: Game?
    @State var showGameDeleteConfirmation: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("portal") var gamepo = false
    
    var body: some View {
        Button(action: {
            startemu = game
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
        }
        .contextMenu {
            Section {
                Button {
                    startemu = game
                } label: {
                    Label("Play Now", systemImage: "play.fill")
                }

                Button {
                    gameInfo = game
                    isViewingGameInfo.toggle()
                    
                    if game.titleName.lowercased() == "portal" {
                        gamepo = true
                    } else if game.titleName.lowercased() == "portal 2" {
                        gamepo = true
                    }
                } label: {
                    Label("Game Info", systemImage: "info.circle")
                }
            }

            Section {
                Button {
                    gameInfo = game
                    isSelectingGameUpdate.toggle()
                } label: {
                    Label("Game Update Manager", systemImage: "chevron.up.circle")
                }

                Button {
                    gameInfo = game
                    isSelectingGameDLC.toggle()
                } label: {
                    Label("Game DLC Manager", systemImage: "plus.viewfinder")
                }
            }

            Section {
                Button(role: .destructive) {
                    gametoDelete = game
                    showGameDeleteConfirmation.toggle()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .confirmationDialog("Are you sure you want to delete this game?", isPresented: $showGameDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if let game = gametoDelete {
                    deleteGame(game: game)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \(gametoDelete?.titleName ?? "this game")?")
        }
    }
    
    private func deleteGame(game: Game) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: game.fileURL)
            games.removeAll { $0.id == game.id }
        } catch {
            print("Error deleting game: \(error)")
        }
    }
}
