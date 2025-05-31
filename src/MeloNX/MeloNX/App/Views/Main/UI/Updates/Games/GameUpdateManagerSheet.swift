//
//  GameUpdateManagerSheet.swift
//  MeloNX
//
//  Created by Stossy11 on 16/02/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct UpdateManagerSheet: View {
    // MARK: - Properties
    @State private var updates: [UpdateItem] = []
    @Binding var game: Game?
    @State private var isSelectingGameUpdate = false
    @State private var jsonURL: URL? = nil
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Models
    class UpdateItem: Identifiable, ObservableObject {
        let id = UUID()
        let url: URL
        let filename: String
        let path: String

        @Published var isSelected: Bool = false

        init(url: URL, filename: String, path: String, isSelected: Bool = false) {
            self.url = url
            self.filename = filename
            self.path = path
            self.isSelected = isSelected
        }
    }
    
    // MARK: - Body
    var body: some View {
        iOSNav {
            List {
                if updates.isEmpty {
                    emptyStateView
                } else {
                    ForEach(updates) { update in
                        updateRow(update)
                    }
                    .onDelete(perform: removeUpdates)
                }
            }
            .navigationTitle("\(game?.titleName ?? "Game") Updates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isSelectingGameUpdate = true
                    } label: {
                        Label("Add Update", systemImage: "plus")
                    }
                }
            }
            .onAppear {
                loadData()
            }
        }
        .fileImporter(isPresented: $isSelectingGameUpdate, allowedContentTypes: [.item], onCompletion: handleFileImport)
    }
    
    // MARK: - Views
    private var emptyStateView: some View {
        Group {
            if #available(iOS 17, *) {
                ContentUnavailableView(
                    "No Updates Found",
                    systemImage: "arrow.down.circle",
                    description: Text("Tap the + button to add game updates.")
                )
            } else {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    Text("No Updates Found")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Tap the + button to add game updates.")
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
    
    private func updateRow(_ update: UpdateItem) -> some View {
        Group {
            if #available(iOS 15, *) {
                updateRowNew(update)
            } else {
                updateRowOld(update)
            }
        }
    }
    
    @available(iOS 15, *)
    private func updateRowNew(_ update: UpdateItem) -> some View {
        Button {
            toggleSelection(update)
        } label: {
            HStack {
                Text(update.filename)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: update.isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(update.isSelected ? .primary : .secondary)
                    .imageScale(.large)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                if let index = updates.firstIndex(where: { $0.path == update.path }) {
                    removeUpdate(at: IndexSet(integer: index))
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func updateRowOld(_ update: UpdateItem) -> some View {
        Button {
            toggleSelection(update)
        } label: {
            HStack {
                Text(update.filename)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: update.isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(update.isSelected ? .primary : .secondary)
                    .imageScale(.large)
            }
            .contentShape(Rectangle())
        }
        .contextMenu {
            Button {
                if let index = updates.firstIndex(where: { $0.path == update.path }) {
                    removeUpdate(at: IndexSet(integer: index))
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Functions
    private func loadData() {
        guard let game = game else { return }
        
        let documentsDirectory = URL.documentsDirectory
        jsonURL = documentsDirectory
            .appendingPathComponent("games")
            .appendingPathComponent(game.titleId)
            .appendingPathComponent("updates.json")
        
        loadJSON()
    }
    
    private func loadJSON() {
        guard let jsonURL = jsonURL else { return }
        
        do {
            if !FileManager.default.fileExists(atPath: jsonURL.path) {
                createDefaultJSON()
                return
            }
            
            let data = try Data(contentsOf: jsonURL)
            if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let paths = jsonDict["paths"] as? [String],
               let selected = jsonDict["selected"] as? String {
                
                let filteredPaths = paths.filter { relativePath in
                    let path = URL.documentsDirectory.appendingPathComponent(relativePath)
                    return FileManager.default.fileExists(atPath: path.path)
                }
                
                updates = filteredPaths.map { relativePath in
                    let url = URL.documentsDirectory.appendingPathComponent(relativePath)
                    return UpdateItem(
                        url: url,
                        filename: url.lastPathComponent,
                        path: relativePath,
                        isSelected: selected == relativePath
                    )
                }
            }
        } catch {
            print("Failed to read JSON: \(error)")
            createDefaultJSON()
        }
    }
    
    private func createDefaultJSON() {
        guard let jsonURL = jsonURL else { return }
        
        do {
            try FileManager.default.createDirectory(at: jsonURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            
            let defaultData: [String: Any] = ["selected": "", "paths": []]
            let newData = try JSONSerialization.data(withJSONObject: defaultData, options: .prettyPrinted)
            try newData.write(to: jsonURL)
            updates = []
        } catch {
            print("Failed to create default JSON: \(error)")
        }
    }
    
    private func handleFileImport(result: Result<URL, Error>) {
        switch result {
        case .success(let selectedURL):
            guard let game = game,
                  selectedURL.startAccessingSecurityScopedResource() else {
                print("Failed to access security-scoped resource")
                return
            }
            
            defer { selectedURL.stopAccessingSecurityScopedResource() }
            
            do {
                let fileManager = FileManager.default
                let updatesDirectory = URL.documentsDirectory.appendingPathComponent("updates")
                let gameUpdatesDirectory = updatesDirectory.appendingPathComponent(game.titleId)
                
                // Create directories if needed
                try fileManager.createDirectory(at: gameUpdatesDirectory, withIntermediateDirectories: true)
                
                // Copy the file
                let destinationURL = gameUpdatesDirectory.appendingPathComponent(selectedURL.lastPathComponent)
                try? fileManager.removeItem(at: destinationURL) // Remove if exists
                try fileManager.copyItem(at: selectedURL, to: destinationURL)
                
                // Add to updates
                let relativePath = "updates/\(game.titleId)/\(selectedURL.lastPathComponent)"
                let newUpdate = UpdateItem(
                    url: destinationURL,
                    filename: selectedURL.lastPathComponent,
                    path: relativePath
                )
                
                updates.append(newUpdate)
                toggleSelection(newUpdate)
                
                // Reload games
                Ryujinx.shared.games = Ryujinx.shared.loadGames()
            } catch {
                print("Error copying update file: \(error)")
            }
            
        case .failure(let error):
            print("File import failed: \(error.localizedDescription)")
        }
    }
    
    private func toggleSelection(_ update: UpdateItem) {
        print("toggle selection \(update.path)")
        
        updates = updates.map { item in
            item.isSelected = item.path == update.path && !update.isSelected
            // print(mutableItem.isSelected)
            // print(update.isSelected)
            return item
        }
        
        // print(updates)
        
        saveJSON()
    }
    
    private func removeUpdates(at offsets: IndexSet) {
        offsets.forEach { removeUpdate(at: IndexSet(integer: $0)) }
    }
    
    private func removeUpdate(at indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        
        let updateToRemove = updates[index]
        
        do {
            // Remove the file
            try FileManager.default.removeItem(at: updateToRemove.url)
            
            // Remove from updates array
            updates.remove(at: index)
            
            // Save changes
            saveJSON()
            
            // Reload games
            Ryujinx.shared.games = Ryujinx.shared.loadGames()
        } catch {
            print("Failed to remove update: \(error)")
        }
    }
    
    private func saveJSON() {
        guard let jsonURL = jsonURL else { return }
        
        do {
            let paths = updates.map { $0.path }
            let selected = updates.first(where: { $0.isSelected })?.path ?? ""
            
            let jsonDict = ["paths": paths, "selected": selected] as [String: Any]
            let newData = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
            try newData.write(to: jsonURL)
        } catch {
            print("Failed to update JSON: \(error)")
        }
    }
}
