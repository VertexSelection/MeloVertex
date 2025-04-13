//
//  GameInfoSheet.swift
//  MeloNX
//
//  Created by Bella on 08/02/2025.
//

import SwiftUI

struct GameInfoSheet: View {
    let game: Game
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        iOSNav {
            List {
                Section {}
                header: {
                    VStack(alignment: .center) {
                        if let icon = game.icon {
                            Image(uiImage: icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 250, height: 250)
                                .cornerRadius(10)
                                .padding()
                                .contextMenu {
                                    Button {
                                        UIImageWriteToSavedPhotosAlbum(icon, nil, nil, nil)
                                    } label: {
                                        Label("Save to Photos", systemImage: "square.and.arrow.down")
                                    }
                                }
                        } else {
                            Image(systemName: "questionmark.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150, height: 150)
                                .padding()
                        }
                        VStack(alignment: .center) {
                            Text("**\(game.titleName)** | \(game.titleId.capitalized)")
                                .multilineTextAlignment(.center)
                            Text(game.developer)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 3)
                    }
                    .frame(maxWidth: .infinity)
                }

                Section {
                    HStack {
                        Text("**Version**")
                        Spacer()
                        Text(game.version)
                            .foregroundColor(Color.secondary)
                    }
                    HStack {
                        Text("**Title ID**")
                            .contextMenu {
                                Button {
                                    UIPasteboard.general.string = game.titleId
                                } label: {
                                    Text("Copy Title ID")
                                }
                            }
                        Spacer()
                        Text(game.titleId)
                            .foregroundColor(Color.secondary)
                    }
                    HStack {
                        Text("**Game Size**")
                        Spacer()
                        Text("\(fetchFileSize(for: game.fileURL) ?? 0) bytes")
                            .foregroundColor(Color.secondary)
                    }
                    HStack {
                        Text("**File Type**")
                        Spacer()
                        Text(getFileType(game.fileURL))
                            .foregroundColor(Color.secondary)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("**Game URL**")
                        Text(trimGameURL(game.fileURL))
                            .foregroundColor(Color.secondary)
                    }
                } header: {
                    Text("Information")
                }
                // .headerProminence(.increased)
            }
            .navigationTitle(game.titleName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    func fetchFileSize(for gamePath: URL) -> UInt64? {
        let fileManager = FileManager.default
        do {
            let attributes = try fileManager.attributesOfItem(atPath: gamePath.path)
            if let size = attributes[FileAttributeKey.size] as? UInt64 {
                return size
            }
        } catch {
            // print("Error getting file size: \(error)")
        }
        return nil
    }

    func trimGameURL(_ url: URL) -> String {
        let path = url.path
        if let range = path.range(of: "/roms/") {
            return String(path[range.lowerBound...])
        }
        return path
    }
    
    func getFileType(_ url: URL) -> String {
        url.pathExtension
    }
}
