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
    @StateObject var ryujinx = Ryujinx.shared
    @State var gameInfo: Game?
    @State var gameRequirements: [GameRequirements] = []
    @State private var showingOptions = false
    
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
            ZStack {
                // Background color
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with stats
                    if !Ryujinx.shared.games.isEmpty {
                        GameLibraryHeader(
                            totalGames: Ryujinx.shared.games.count,
                            recentGames: realRecentGames.count,
                            firmwareVersion: firmwareversion
                        )
                    }
                    
                    // Game list
                    if Ryujinx.shared.games.isEmpty {
                        EmptyGameLibraryView(isSelectingGameFile: $isSelectingGameFile)
                    } else {
                        gameListView
                            .animation(.easeInOut(duration: 0.3), value: searchText)
                    }
                }
            }
            .navigationTitle("Game Library")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadRecentGames()
                firmwareversion = (Ryujinx.shared.fetchFirmwareVersion() == "" ? "0" : Ryujinx.shared.fetchFirmwareVersion())
                
                pullGameCompatibility() { result in
                    switch result {
                    case .success(let success):
                        gameRequirements = success
                    case .failure(_):
                        print("Failed to load game compatibility data")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    
                    Button {
                        isSelectingGameFile = true
                        isImporting = true
                    } label: {
                        Label("Add Game", systemImage: "plus")
                            .labelStyle(.iconOnly)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    // .buttonStyle(.bordered)
                    .accentColor(.blue)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        firmwareSection
                        
                        Divider()
                        
                        Button {
                            isSelectingGameFile = false
                            isImporting = true
                        } label: {
                            Label("Open Game", systemImage: "square.and.arrow.down")
                        }
                        
                        Button {
                            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            var sharedurl = documentsUrl.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
                            if ProcessInfo.processInfo.isiOSAppOnMac {
                                sharedurl = documentsUrl.absoluteString
                            }
                            if UIApplication.shared.canOpenURL(URL(string: sharedurl)!) {
                                UIApplication.shared.open(URL(string: sharedurl)!, options: [:])
                            }
                        } label: {
                            Label("Show MeloNX Folder", systemImage: "folder")
                        }
                    } label: {
                        Label("Options", systemImage: "ellipsis.circle")
                            .labelStyle(.iconOnly)
                            .foregroundColor(.blue)
                    }
                }
            }
            .overlay(Group {
                if ryujinx.jitenabled {
                    VStack {
                        HStack {
                            Spacer()
                            Circle()
                                .frame(width: 12, height: 12)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .foregroundColor(Color.green)
                                .padding()
                        }
                        Spacer()
                    }
                }
            })
            .onChange(of: startemu) { game in
                guard let game else { return }
                addToRecentGames(game)
            }
            // .searchable(text: $searchText, placement: .toolbar, prompt: "Search games or developers")
            .onChange(of: searchText) { _ in
                isSearching = !searchText.isEmpty
            }
            .onChange(of: isImporting) { newValue in
                if newValue {
                    FileImporterManager.shared.importFiles(types: [.nsp, .xci, .item]) { result in
                        isImporting = false
                        handleRunningGame(result: result)
                    }
                }
            }
            .onChange(of: isSelectingGameFile) { newValue in
                if newValue {
                    FileImporterManager.shared.importFiles(types: [.nsp, .xci, .item]) { result in
                        isImporting = false
                        handleAddingGame(result: result)
                    }
                }
            }
            .onChange(of: firmwareInstaller) { newValue in
                if newValue {
                    FileImporterManager.shared.importFiles(types: [.folder, .zip]) { result in
                        isImporting = false
                        handleFirmwareImport(result: result)
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
    }
    
    // MARK: - Subviews
    
    private var gameListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if !isSearching && !realRecentGames.isEmpty {
                    // Recent Games Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Recent Games")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(realRecentGames) { game in
                                    GameCardView(
                                        game: game,
                                        startemu: $startemu,
                                        games: games,
                                        isViewingGameInfo: $isViewingGameInfo,
                                        isSelectingGameUpdate: $isSelectingGameUpdate,
                                        isSelectingGameDLC: $isSelectingGameDLC,
                                        gameRequirements: $gameRequirements,
                                        gameInfo: $gameInfo
                                    )
                                    .contextMenu {
                                        gameContextMenu(for: game)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    
                    // Library Section
                    if !filteredGames.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Library")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            ForEach(filteredGames) { game in
                                GameListRow(
                                    game: game,
                                    startemu: $startemu,
                                    games: games,
                                    isViewingGameInfo: $isViewingGameInfo,
                                    isSelectingGameUpdate: $isSelectingGameUpdate,
                                    isSelectingGameDLC: $isSelectingGameDLC,
                                    gameRequirements: $gameRequirements,
                                    gameInfo: $gameInfo
                                )
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }
                        }
                    }
                } else {
                    ForEach(filteredGames) { game in
                        GameListRow(
                            game: game,
                            startemu: $startemu,
                            games: games,
                            isViewingGameInfo: $isViewingGameInfo,
                            isSelectingGameUpdate: $isSelectingGameUpdate,
                            isSelectingGameDLC: $isSelectingGameDLC,
                            gameRequirements: $gameRequirements,
                            gameInfo: $gameInfo
                        )
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
                
                Spacer(minLength: 50)
            }
        }
    }
    
    private var firmwareSection: some View {
        Group {
            if firmwareversion == "0" {
                    Button {
                        DispatchQueue.main.async {
                            firmwareInstaller.toggle()
                        }
                    } label: {
                        Label("Install Firmware", systemImage: "square.and.arrow.down")
                    }
                
            } else {
                Menu("Applets") {
                    Button {
                        let game = Game(containerFolder: URL(string: "none")!, fileType: .item, fileURL: URL(string: "0x0100000000001009")!, titleName: "Mii Maker", titleId: "0", developer: "Nintendo", version: firmwareversion)
                        self.startemu = game
                    } label: {
                        Label("Launch Mii Maker", systemImage: "person.crop.circle")
                    }

                    Button {
                        let game = Game(containerFolder: URL(string: "none")!, fileType: .item, fileURL: URL(string: "0x0100000000001000")!, titleName: "Home Menu (Broken)", titleId: "0", developer: "Nintendo", version: firmwareversion)
                        self.startemu = game
                    } label: {
                        Label("Home Menu (Broken)", systemImage: "house.circle")
                    }
                    .foregroundStyle(.red)
                }
            }
        }
    }
    
    // MARK: - Game Management Functions
    
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
            // print("Error saving recent games: \(error)")
        }
    }
    
    private func loadRecentGames() {
        do {
            let decoder = JSONDecoder()
            recentGames = try decoder.decode([Game].self, from: recentGamesData)
        } catch {
            // print("Error loading recent games: \(error)")
            recentGames = []
        }
    }

    private func deleteGame(game: Game) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: game.fileURL)
            Ryujinx.shared.games.removeAll { $0.id == game.id }
            Ryujinx.shared.games = Ryujinx.shared.loadGames()
        } catch {
            // print("Error deleting game: \(error)")
        }
    }
    
    // MARK: - Import Handlers
    
    private func handleAddingGame(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first, url.startAccessingSecurityScopedResource() else {
                // print("Failed to access security-scoped resource")
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
                // print("Error copying game file: \(error)")
            }
        case .failure(let err):
            print("File import failed: \(err.localizedDescription)")
        }
    }
    
    private func handleRunningGame(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first, url.startAccessingSecurityScopedResource() else {
                // print("Failed to access security-scoped resource")
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
                // print(error)
            }
            
        case .failure(let err):
            print("File import failed: \(err.localizedDescription)")
        }
    }
    
    private func handleFirmwareImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let url):
            guard let url = url.first else {
                return
            }
            
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
    
    // MARK: - Context Menus
    
    private func gameContextMenu(for game: Game) -> some View {
        Group {
            Section {
                Button {
                    startemu = game
                } label: {
                    Label("Play Now", systemImage: "play.fill")
                }

                Button {
                    gameInfo = game
                    isViewingGameInfo.toggle()
                } label: {
                    Label("Game Info", systemImage: "info.circle")
                }
            }

            Section {
                Button {
                    gameInfo = game
                    isSelectingGameUpdate.toggle()
                } label: {
                    Label("Update Manager", systemImage: "arrow.up.circle")
                }

                Button {
                    gameInfo = game
                    isSelectingGameDLC.toggle()
                } label: {
                    Label("DLC Manager", systemImage: "plus.circle")
                }
            }

            Section {
                if #available(iOS 15, *) {
                    Button(role: .destructive) {
                        deleteGame(game: game)
                    } label: {
                        Label("Delete Game", systemImage: "trash")
                    }
                } else {
                    Button(action: {
                        deleteGame(game: game)
                    }) {
                        Label("Delete Game", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }

            }
        }
    }
}

extension Game: Codable {
    private enum CodingKeys: String, CodingKey {
        case titleName, titleId, developer, version, fileURL, containerFolder, fileType
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        titleName = try container.decode(String.self, forKey: .titleName)
        titleId = try container.decode(String.self, forKey: .titleId)
        developer = try container.decode(String.self, forKey: .developer)
        version = try container.decode(String.self, forKey: .version)
        fileURL = try container.decode(URL.self, forKey: .fileURL)
        containerFolder = try container.decode(URL.self, forKey: .containerFolder)
        fileType = try container.decode(UTType.self, forKey: .fileType)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(titleName, forKey: .titleName)
        try container.encode(titleId, forKey: .titleId)
        try container.encode(developer, forKey: .developer)
        try container.encode(version, forKey: .version)
        try container.encode(fileURL, forKey: .fileURL)
        try container.encode(containerFolder, forKey: .containerFolder)
        try container.encode(fileType, forKey: .fileType)
    }
}


// MARK: - Empty Library View
struct EmptyGameLibraryView: View {
    @Binding var isSelectingGameFile: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 70))
                .foregroundColor(.blue.opacity(0.7))
                .padding(.bottom)
            
            Text("No Games Found")
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            Text("Add ROM files to get started with your gaming experience")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                isSelectingGameFile = true
            } label: {
                Label("Add Game", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Library Header
struct GameLibraryHeader: View {
    let totalGames: Int
    let recentGames: Int
    let firmwareVersion: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Stats cards
            StatCard(
                icon: "gamecontroller.fill",
                title: "Total Games",
                value: "\(totalGames)",
                color: .blue
            )
            
            StatCard(
                icon: "clock.fill",
                title: "Recent",
                value: "\(recentGames)",
                color: .green
            )
            
            StatCard(
                icon: "cpu",
                title: "Firmware",
                value: firmwareVersion == "0" ? "None" : firmwareVersion,
                color: firmwareVersion == "0" ? .red : .orange
            )
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Game Card View
struct GameCardView: View {
    let game: Game
    @Binding var startemu: Game?
    @Binding var games: [Game]
    @Binding var isViewingGameInfo: Bool
    @Binding var isSelectingGameUpdate: Bool
    @Binding var isSelectingGameDLC: Bool
    @Binding var gameRequirements: [GameRequirements]
    @Binding var gameInfo: Game?
    @Environment(\.colorScheme) var colorScheme
    let totalMemory = ProcessInfo.processInfo.physicalMemory
    
    var gameRequirement: GameRequirements? {
        gameRequirements.first(where: { $0.game_id == game.titleId })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Game Icon
            ZStack {
                if let icon = game.icon {
                    Image(uiImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 130, height: 130)
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                        .frame(width: 130, height: 130)
                    
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                }
                
                // Play button overlay
                Button {
                    startemu = game
                } label: {
                    Circle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "play.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        )
                }
                .offset(x: 0, y: 0)
                .opacity(0.8)
            }
            
            // Game info
            VStack(alignment: .leading, spacing: 4) {
                Text(game.titleName)
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(game.developer)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // Compatibility tag
                if let req = gameRequirement {
                    HStack(spacing: 4) {
                        Text(req.compatibility)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(req.color)
                            .cornerRadius(4)
                        
                        Text(req.device_memory)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(req.memoryInt <= Int(String(format: "%.0f", Double(totalMemory) / 1_000_000_000)) ?? 0 ? Color.blue : Color.red)
                            .cornerRadius(4)
                    }
                } else {
                    HStack(spacing: 4) {
                        Text("0GB")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.clear)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.clear)
                            .cornerRadius(4)
                    }
                }
            }
            .frame(width: 130, alignment: .leading)
            .padding(.top, 8)
        }
        .onTapGesture {
            startemu = game
        }
    }
}

// MARK: - Game List Row
struct GameListRow: View {
    let game: Game
    @Binding var startemu: Game?
    @Binding var games: [Game]
    @Binding var isViewingGameInfo: Bool
    @Binding var isSelectingGameUpdate: Bool
    @Binding var isSelectingGameDLC: Bool
    @Binding var gameRequirements: [GameRequirements]
    @Binding var gameInfo: Game?
    @State var gametoDelete: Game?
    @State var showGameDeleteConfirmation: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    @AppStorage("portal") var gamepo = false
    
    var body: some View {
        if #available(iOS 15.0, *) {
            Button(action: {
                startemu = game
            }) {
                HStack(spacing: 16) {
                    // Game Icon
                    if let icon = game.icon {
                        Image(uiImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 55, height: 55)
                            .cornerRadius(10)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(colorScheme == .dark ?
                                      Color(.systemGray5) : Color(.systemGray6))
                                .frame(width: 55, height: 55)
                            
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Game Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(game.titleName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            Text(game.developer)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                            
                            if !game.version.isEmpty && game.version != "0" {
                                Divider().frame(width: 1, height: 15)
                                
                                Text("v\(game.version)")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        // Compatibility badges
                        HStack {
                            if let gameReq = gameRequirements.first(where: { $0.game_id == game.titleId }) {
                                let totalMemory = ProcessInfo.processInfo.physicalMemory
                                
                                HStack(spacing: 4) {
                                    Text(gameReq.device_memory)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(gameReq.memoryInt <= Int(String(format: "%.0f", Double(totalMemory) / 1_000_000_000)) ?? 0 ? Color.blue : Color.red)
                                        )
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .fixedSize(horizontal: true, vertical: false)
                                        .layoutPriority(1)

                                    Text(gameReq.compatibility)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(gameReq.color)
                                        )
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .fixedSize(horizontal: true, vertical: false)
                                        .layoutPriority(1)
                                }
                            }
                            
                            // Play button
                            Image(systemName: "play.circle.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .contentShape(Rectangle())
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
                        
                        if game.titleName.lowercased() == "portal" || game.titleName.lowercased() == "portal 2" {
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
                        Label("Update Manager", systemImage: "arrow.up.circle")
                    }
                    
                    Button {
                        gameInfo = game
                        isSelectingGameDLC.toggle()
                    } label: {
                        Label("DLC Manager", systemImage: "plus.circle")
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
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    gametoDelete = game
                    showGameDeleteConfirmation.toggle()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                
                Button {
                    gameInfo = game
                    isViewingGameInfo.toggle()
                } label: {
                    Label("Info", systemImage: "info.circle")
                }
                .tint(.blue)
            }
            .swipeActions(edge: .leading) {
                Button {
                    startemu = game
                } label: {
                    Label("Play", systemImage: "play.fill")
                }
                .tint(.green)
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
            .listRowInsets(EdgeInsets())
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6).opacity(0.5))
            )
        } else {
            Button(action: {
                startemu = game
            }) {
                HStack(spacing: 16) {
                    // Game Icon
                    if let icon = game.icon {
                        Image(uiImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 55, height: 55)
                            .cornerRadius(10)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(colorScheme == .dark ?
                                      Color(.systemGray5) : Color(.systemGray6))
                                .frame(width: 55, height: 55)
                            
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Game Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(game.titleName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            Text(game.developer)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                            
                            if !game.version.isEmpty && game.version != "0" {
                                Text("•")
                                    .foregroundColor(.secondary)
                                
                                Text("v\(game.version)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        // Compatibility badges
                        HStack {
                            if let gameReq = gameRequirements.first(where: { $0.game_id == game.titleId }) {
                                let totalMemory = ProcessInfo.processInfo.physicalMemory
                                
                                HStack(spacing: 4) {
                                    // Memory requirement badge
                                    Text(gameReq.device_memory)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(gameReq.memoryInt <= Int(String(format: "%.0f", Double(totalMemory) / 1_000_000_000)) ?? 0 ? Color.blue : Color.red)
                                        )
                                    
                                    // Compatibility badge
                                    Text(gameReq.compatibility)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(gameReq.color)
                                        )
                                }
                            }
                            
                            // Play button
                            Image(systemName: "play.circle.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .frame(width: .infinity, height: .infinity)
            }
            .contentShape(Rectangle())
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
                        
                        if game.titleName.lowercased() == "portal" || game.titleName.lowercased() == "portal 2" {
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
                        Label("Update Manager", systemImage: "arrow.up.circle")
                    }
                    
                    Button {
                        gameInfo = game
                        isSelectingGameDLC.toggle()
                    } label: {
                        Label("DLC Manager", systemImage: "plus.circle")
                    }
                }
                
                Section {
                    Button {
                        gametoDelete = game
                        showGameDeleteConfirmation.toggle()
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .alert(isPresented: $showGameDeleteConfirmation) {
                Alert(
                    title: Text("Are you sure you want to delete this game?"),
                    message: Text("Are you sure you want to delete \(gametoDelete?.titleName ?? "this game")?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let game = gametoDelete {
                            deleteGame(game: game)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .listRowInsets(EdgeInsets())
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6).opacity(0.5))
            )
        }
    }
    
    private func deleteGame(game: Game) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: game.fileURL)
            games.removeAll { $0.id == game.id }
        } catch {
            // print("Error deleting game: \(error)")
        }
    }
}

struct GameRequirements: Codable {
    var game_id: String
    var compatibility: String
    var device_memory: String
    var memoryInt: Int {
        var devicemem = device_memory
        devicemem.removeLast(2)
        // print(devicemem)
        return Int(devicemem) ?? 0
    }
    
    var color: Color {
        switch compatibility {
        case "Perfect":
            return .green
        case "Playable":
            return .yellow
        case "Menu":
            return .orange
        case "Boots":
            return .red
        case "Nothing":
            return .black
        default:
            return .clear
        }
    }
}

func pullGameCompatibility(completion: @escaping (Result<[GameRequirements], Error>) -> Void) {
    if let cachedData = GameCompatibiliryCache.shared.getCachedData() {
        completion(.success(cachedData))
        return
    }

    guard let url = URL(string: "https://melonx.net/api/game_entries") else {
        completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
            return
        }

        do {
            let decodedData = try JSONDecoder().decode([GameRequirements].self, from: data)
            GameCompatibiliryCache.shared.setCachedData(decodedData)
            completion(.success(decodedData))
        } catch {
            completion(.failure(error))
        }
    }

    task.resume()
}
