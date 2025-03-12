//
//  GameDLCManagerSheet.swift
//  MeloNX
//
//  Created by XITRIX on 16/02/2025.
//

import SwiftUI
import UniformTypeIdentifiers

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

struct DownloadableContentContainer: Codable, Hashable {
    var containerPath: String
    var downloadableContentNcaList: [DownloadableContentNca]

    enum CodingKeys: String, CodingKey {
        case containerPath = "path"
        case downloadableContentNcaList = "dlc_nca_list"
    }
}

struct DLCManagerSheet: View {
    @Binding var game: Game!
    @State private var isSelectingGameDLC = false
    @State private var dlcs: [DownloadableContentContainer] = []

    var body: some View {
        NavigationView {
            let withIndex = dlcs.enumerated().map { $0 }
            List(withIndex, id: \.element.containerPath) { index, dlc in
                Button(action: {
                    let toggle = dlcs[index].downloadableContentNcaList.first?.enabled ?? true
                    dlcs[index].downloadableContentNcaList.mutableForEach { $0.enabled = !toggle }
                    Self.saveDlcs(game, dlc: dlcs)
                }) {
                    HStack {
                        Text((dlc.containerPath as NSString).lastPathComponent)
                            .foregroundStyle(Color(uiColor: .label))
                        Spacer()
                        if dlc.downloadableContentNcaList.first?.enabled == true {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.accentColor)
                                .font(.system(size: 24))
                        } else {
                            Image(systemName: "circle")
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                                .font(.system(size: 24))
                        }
                    }
                }
                .contextMenu {
                    Button {
                        let path = URL.documentsDirectory.appendingPathComponent(dlc.containerPath)
                        try? FileManager.default.removeItem(atPath: path.path)
                        dlcs.remove(at: index)
                        Self.saveDlcs(game, dlc: dlcs)
                    } label: {
                        Text("Remove DLC")
                    }
                }
            }
            .navigationTitle("\(game.titleName) DLCs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Add", systemImage: "plus") {
                    isSelectingGameDLC = true
                }
            }
        }
        .onAppear {
            dlcs = Self.loadDlc(game)
        }
        .fileImporter(isPresented: $isSelectingGameDLC, allowedContentTypes: [.item], allowsMultipleSelection: true) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    guard url.startAccessingSecurityScopedResource() else {
                        print("Failed to access security-scoped resource")
                        return
                    }
                    defer { url.stopAccessingSecurityScopedResource() }

                    do {
                        let fileManager = FileManager.default
                        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let dlcDirectory = documentsDirectory.appendingPathComponent("dlc")
                        let romDlcDirectory = dlcDirectory.appendingPathComponent(game.titleId)

                        if !fileManager.fileExists(atPath: dlcDirectory.path) {
                            try fileManager.createDirectory(at: dlcDirectory, withIntermediateDirectories: true, attributes: nil)
                        }

                        if !fileManager.fileExists(atPath: romDlcDirectory.path) {
                            try fileManager.createDirectory(at: romDlcDirectory, withIntermediateDirectories: true, attributes: nil)
                        }

                        let dlcContent = Ryujinx.shared.getDlcNcaList(titleId: game.titleId, path: url.path)
                        guard !dlcContent.isEmpty else { return }

                        let destinationURL = romDlcDirectory.appendingPathComponent(url.lastPathComponent)
                        try? fileManager.copyItem(at: url, to: destinationURL)

                        let container = DownloadableContentContainer(
                            containerPath: Self.relativeDlcDirectoryPath(for: game, dlcPath: destinationURL),
                            downloadableContentNcaList: dlcContent
                        )
                        dlcs.append(container)

                        Self.saveDlcs(game, dlc: dlcs)
                    } catch {
                        print("Error copying game file: \(error)")
                    }
                }
            case .failure(let err):
                print("File import failed: \(err.localizedDescription)")
            }
        }
    }
}

private extension DLCManagerSheet {
    static func loadDlc(_ game: Game) -> [DownloadableContentContainer] {
        let jsonURL = dlcJsonPath(for: game)
        try? FileManager.default.createDirectory(at: jsonURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        guard let data = try? Data(contentsOf: jsonURL),
              var result = try? JSONDecoder().decode([DownloadableContentContainer].self, from: data)
        else { return [] }

        result = result.filter { container in
            let path = URL.documentsDirectory.appendingPathComponent(container.containerPath)
            return FileManager.default.fileExists(atPath: path.path)
        }

        return result
    }

    static func saveDlcs(_ game: Game, dlc: [DownloadableContentContainer]) {
        guard let data = try? JSONEncoder().encode(dlc) else { return }
        try? data.write(to: dlcJsonPath(for: game))
    }

    static func relativeDlcDirectoryPath(for game: Game, dlcPath: URL) -> String {
        "dlc/\(game.titleId)/\(dlcPath.lastPathComponent)"
    }

    static func dlcJsonPath(for game: Game) -> URL {
        URL.documentsDirectory.appendingPathComponent("games").appendingPathComponent(game.titleId).appendingPathComponent("dlc.json")
    }
}


extension URL {
    @available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use URL.documentsDirectory on iOS 16 and above")
    static var documentsDirectory: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory
    }
}
