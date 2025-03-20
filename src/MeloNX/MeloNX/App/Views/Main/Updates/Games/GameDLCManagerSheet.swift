//
//  GameDLCManagerSheet.swift
//  MeloNX
//
//  Created by XITRIX on 16/02/2025.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Models
struct DownloadableContentNca: Codable, Hashable {
    var fullPath: String
    var titleId: UInt
    var enabled: Bool

    enum CodingKeys: String, CodingKey {
        case fullPath = "path"
        case titleId = "title_id"
        case enabled = "is_enabled"
    }
}

struct DownloadableContentContainer: Codable, Hashable, Identifiable {
    var id: String { containerPath }
    var containerPath: String
    var downloadableContentNcaList: [DownloadableContentNca]
    
    var filename: String {
        (containerPath as NSString).lastPathComponent
    }
    
    var isEnabled: Bool {
        downloadableContentNcaList.first?.enabled == true
    }

    enum CodingKeys: String, CodingKey {
        case containerPath = "path"
        case downloadableContentNcaList = "dlc_nca_list"
    }
}

// MARK: - View
struct DLCManagerSheet: View {
    // MARK: - Properties
    @Binding var game: Game!
    @State private var isSelectingGameDLC = false
    @State private var dlcs: [DownloadableContentContainer] = []
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        iOSNav {
            List {
                if dlcs.isEmpty {
                    emptyStateView
                } else {
                    ForEach(dlcs) { dlc in
                        dlcRow(dlc)
                    }
                    .onDelete(perform: removeDLCs)
                }
            }
            .navigationTitle("\(game.titleName) DLCs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isSelectingGameDLC = true
                    } label: {
                        Label("Add DLC", systemImage: "plus")
                    }
                }
            }
            .onAppear {
                loadData()
            }
        }
        .fileImporter(
            isPresented: $isSelectingGameDLC,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true,
            onCompletion: handleFileImport
        )
    }
    
    // MARK: - Views
    private var emptyStateView: some View {
        Group {
            if #available(iOS 17, *) {
                ContentUnavailableView(
                    "No DLCs Found",
                    systemImage: "puzzlepiece.extension",
                    description: Text("Tap the + button to add game DLCs.")
                )
            } else {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "puzzlepiece.extension")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    Text("No DLCs Found")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Tap the + button to add game DLCs.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .listRowInsets(EdgeInsets())
            }
        }
    }
    
    
    private func dlcRow(_ dlc: DownloadableContentContainer) -> some View {
        Button {
            toggleDLC(dlc)
        } label: {
            HStack {
                Text(dlc.filename)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: dlc.isEnabled ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(dlc.isEnabled ? .primary : .secondary)
                    .imageScale(.large)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                if let index = dlcs.firstIndex(where: { $0.id == dlc.id }) {
                    removeDLC(at: IndexSet(integer: index))
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Functions
    private func loadData() {
        dlcs = Self.loadDlc(game)
    }
    
    private func toggleDLC(_ dlc: DownloadableContentContainer) {
        guard let index = dlcs.firstIndex(where: { $0.id == dlc.id }) else { return }
        
        let toggle = !dlcs[index].isEnabled
        dlcs[index].downloadableContentNcaList = dlcs[index].downloadableContentNcaList.map { nca in
            var mutableNca = nca
            mutableNca.enabled = toggle
            return mutableNca
        }
        
        Self.saveDlcs(game, dlc: dlcs)
    }
    
    private func removeDLCs(at offsets: IndexSet) {
        offsets.forEach { removeDLC(at: IndexSet(integer: $0)) }
    }
    
    private func removeDLC(at indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        
        let dlcToRemove = dlcs[index]
        let path = URL.documentsDirectory.appendingPathComponent(dlcToRemove.containerPath)
        
        do {
            try FileManager.default.removeItem(at: path)
            dlcs.remove(at: index)
            Self.saveDlcs(game, dlc: dlcs)
        } catch {
            print("Failed to remove DLC: \(error)")
        }
    }
    
    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                importDLC(from: url)
            }
        case .failure(let error):
            print("File import failed: \(error.localizedDescription)")
        }
    }
    
    private func importDLC(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            print("Failed to access security-scoped resource")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let fileManager = FileManager.default
            let dlcDirectory = URL.documentsDirectory.appendingPathComponent("dlc")
            let gameDlcDirectory = dlcDirectory.appendingPathComponent(game.titleId)
            
            try fileManager.createDirectory(at: gameDlcDirectory, withIntermediateDirectories: true)
            
            // Copy the DLC file
            let destinationURL = gameDlcDirectory.appendingPathComponent(url.lastPathComponent)
            try? fileManager.removeItem(at: destinationURL)
            try fileManager.copyItem(at: url, to: destinationURL)
            
            // Fetch DLC metadata from Ryujinx
            let dlcContent = Ryujinx.shared.getDlcNcaList(titleId: game.titleId, path: destinationURL.path)
            guard !dlcContent.isEmpty else {
                print("No valid DLC content found")
                return
            }
            
            let newDlcContainer = DownloadableContentContainer(
                containerPath: Self.relativeDlcDirectoryPath(for: game, dlcPath: destinationURL),
                downloadableContentNcaList: dlcContent
            )
            
            dlcs.append(newDlcContainer)
            Self.saveDlcs(game, dlc: dlcs)
            
        } catch {
            print("Error importing DLC: \(error)")
        }
    }
    
}

// MARK: - Helper Methods
private extension DLCManagerSheet {
    static func loadDlc(_ game: Game) -> [DownloadableContentContainer] {
        let jsonURL = dlcJsonPath(for: game)
        
        do {
            try FileManager.default.createDirectory(at: jsonURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            
            guard FileManager.default.fileExists(atPath: jsonURL.path),
                  let data = try? Data(contentsOf: jsonURL),
                  var result = try? JSONDecoder().decode([DownloadableContentContainer].self, from: data)
            else { return [] }
            
            result = result.filter { container in
                let path = URL.documentsDirectory.appendingPathComponent(container.containerPath)
                return FileManager.default.fileExists(atPath: path.path)
            }
            
            return result
        } catch {
            print("Error loading DLCs: \(error)")
            return []
        }
    }
    
    static func saveDlcs(_ game: Game, dlc: [DownloadableContentContainer]) {
        do {
            let data = try JSONEncoder().encode(dlc)
            try data.write(to: dlcJsonPath(for: game))
        } catch {
            print("Error saving DLCs: \(error)")
        }
    }
    
    static func relativeDlcDirectoryPath(for game: Game, dlcPath: URL) -> String {
        "dlc/\(game.titleId)/\(dlcPath.lastPathComponent)"
    }
    
    static func dlcJsonPath(for game: Game) -> URL {
        URL.documentsDirectory
            .appendingPathComponent("games")
            .appendingPathComponent(game.titleId)
            .appendingPathComponent("dlc.json")
    }
}

// MARK: - Array Extension
extension Array where Element: AnyObject {
    mutating func mutableForEach(_ body: (inout Element) -> Void) {
        for index in indices {
            var element = self[index]
            body(&element)
            self[index] = element
        }
    }
}

// MARK: - URL Extension
extension URL {
    @available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use URL.documentsDirectory on iOS 16 and above")
    static var documentsDirectory: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory
    }
}
