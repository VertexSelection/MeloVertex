//
//  GameInfoSheet.swift
//  MeloNX
//
//  Created by Bella on 08/02/2025.
//

import SwiftUI

struct GameInfoSheet: View {
    let game: Game
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        iOSNav {
            VStack {
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
                
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("**\(game.titleName)** | \(game.titleId.capitalized)")
                        Text(game.developer)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 3)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Information")
                            .font(.title2)
                            .bold()
                        
                        Text("**Version:** \(game.version)")
                        Text("**Title ID:** \(game.titleId)")
                            .contextMenu {
                                Button {
                                    UIPasteboard.general.string = game.titleId
                                } label: {
                                    Text("Copy Title ID")
                                }
                            }
                        Text("**Game Size:** \(fetchFileSize(for: game.fileURL) ?? 0) bytes")
                        Text("**File Type:** .\(getFileType(game.fileURL))")
                        Text("**Game URL:** \(trimGameURL(game.fileURL))")
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 5)
            .navigationTitle(game.titleName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
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
            print("Error getting file size: \(error)")
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
        let path = url.path
        if let range = path.range(of: ".") {
            return String(path[range.upperBound...])
        }
        return "Unknown"
    }
}
