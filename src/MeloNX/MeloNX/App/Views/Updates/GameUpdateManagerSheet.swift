//
//  GameUpdateManagerSheet.swift
//  MeloNX
//
//  Created by Stossy11 on 16/02/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct UpdateManagerSheet: View {
    @State private var items: [String] = []
    @State private var paths: [URL] = []
    @State private var selectedItem: String? = nil
    @Binding var game: Game?
    @State private var isSelectingGameUpdate = false
    @State private var jsonURL: URL? = nil

    var body: some View {
        NavigationView {
            List(paths, id: \..self, selection: $selectedItem) { item in
                Button(action: {
                    selectItem(item.lastPathComponent)
                }) {
                    HStack {
                        Text(item.lastPathComponent)
                            .foregroundStyle(Color(uiColor: .label))
                        Spacer()
                        if selectedItem == "\(game!.titleId)/\(item.lastPathComponent)" {
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
                        removeUpdate(item)
                    } label: {
                        Text("Remove Update")
                    }
                }
            }
            .onAppear {
                print(URL.documentsDirectory.appendingPathComponent("games").appendingPathComponent(game!.titleId).appendingPathComponent("updates.json"))
                
                loadJSON(URL.documentsDirectory.appendingPathComponent("games").appendingPathComponent(game!.titleId).appendingPathComponent("updates.json"))
            }
            .navigationTitle("\(game!.titleName) Updates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Add", systemImage: "plus") {
                    isSelectingGameUpdate = true
                }
            }
        }
        .fileImporter(isPresented: $isSelectingGameUpdate, allowedContentTypes: [.item]) { result in
            switch result {
            case .success(let url):
                guard url.startAccessingSecurityScopedResource() else {
                    print("Failed to access security-scoped resource")
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }
                
                let gameInfo = game!
                
                do {
                    let fileManager = FileManager.default
                    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let updatedDirectory = documentsDirectory.appendingPathComponent("updates")
                    let romUpdatedDirectory = updatedDirectory.appendingPathComponent(gameInfo.titleId)
                    
                    if !fileManager.fileExists(atPath: updatedDirectory.path) {
                        try fileManager.createDirectory(at: updatedDirectory, withIntermediateDirectories: true, attributes: nil)
                    }

                    if !fileManager.fileExists(atPath: romUpdatedDirectory.path) {
                        try fileManager.createDirectory(at: romUpdatedDirectory, withIntermediateDirectories: true, attributes: nil)
                    }

                    let destinationURL = romUpdatedDirectory.appendingPathComponent(url.lastPathComponent)
                    try? fileManager.copyItem(at: url, to: destinationURL)

                    items.append(gameInfo.titleId + "/" + url.lastPathComponent)
                    selectItem(url.lastPathComponent)
                    Ryujinx.shared.games = Ryujinx.shared.loadGames()
                    loadJSON(jsonURL!)
                } catch {
                    print("Error copying game file: \(error)")
                }
            case .failure(let err):
                print("File import failed: \(err.localizedDescription)")
            }
        }
    }
    
    func removeUpdate(_ game: URL) {
        let gameString = "\(self.game!.titleId)/\(game.lastPathComponent)"
        paths.removeAll { $0 == game }
        items.removeAll { $0 == gameString }
        
        if selectedItem == gameString {
            selectedItem = nil
        }
        
        do {
            try FileManager.default.removeItem(at: game)
        } catch {
            print(error)
        }
        
        saveJSON(selectedItem: selectedItem ?? "")
        Ryujinx.shared.games = Ryujinx.shared.loadGames()
    }
    
    func saveJSON(selectedItem: String) {
        guard let jsonURL = jsonURL else { return }
        do {
            let jsonDict = ["paths": items, "selected": selectedItem] as [String: Any]
            let newData = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
            try newData.write(to: jsonURL)
        } catch {
            print("Failed to update JSON: \(error)")
        }
    }
    
    func loadJSON(_ json: URL) {
        self.jsonURL = json
        print("Failed to read JSO")
        
        guard let jsonURL = jsonURL else { return }
        print("Failed to read JSOK")
        
        do {
            let data = try Data(contentsOf: jsonURL)
            if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let list = jsonDict["paths"] as? [String]
            {
                var urls: [URL] = []
                
                for path in list {
                    urls.append(URL.documentsDirectory.appendingPathComponent("updates").appendingPathComponent(path))
                }
                
                items = list
                paths = urls
                selectedItem = jsonDict["selected"] as? String
            }
        } catch {
            print("Failed to read JSON: \(error)")
            createDefaultJSON()
        }
    }
    
    func createDefaultJSON() {
        guard let jsonURL = jsonURL else { return }
        let defaultData: [String: Any] = ["selected": "", "paths": []]
        do {
            let newData = try JSONSerialization.data(withJSONObject: defaultData, options: .prettyPrinted)
            try newData.write(to: jsonURL)
            items = []
            selectedItem = ""
        } catch {
            print("Failed to create default JSON: \(error)")
        }
    }
    
    func selectItem(_ item: String) {
        let newSelection = "\(game!.titleId)/\(item)"
        
        guard let jsonURL = jsonURL else { return }
        
        do {
            let data = try Data(contentsOf: jsonURL)
            var jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
            
            if let currentSelected = jsonDict["selected"] as? String, currentSelected == newSelection {
                jsonDict["selected"] = ""
                selectedItem = ""
            } else {
                jsonDict["selected"] = newSelection
                selectedItem = newSelection
            }
            
            jsonDict["paths"] = items
            
            let newData = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
            try newData.write(to: jsonURL)
            Ryujinx.shared.games = Ryujinx.shared.loadGames()
        } catch {
            print("Failed to update JSON: \(error)")
        }
    }
}
