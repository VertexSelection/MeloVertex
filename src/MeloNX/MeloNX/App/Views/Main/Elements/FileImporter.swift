//
//  FileImporter.swift
//  MeloNX
//
//  Created by Stossy11 on 17/04/2025.
//


import SwiftUI
import UniformTypeIdentifiers

class FileImporterManager: ObservableObject {
    static let shared = FileImporterManager()
    
    private init() {}
    
    func importFiles(types: [UTType], allowMultiple: Bool = false, completion: @escaping (Result<[URL], Error>) -> Void) {
        let id = "\(Unmanaged.passUnretained(completion as AnyObject).toOpaque())"
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .importFiles,
                object: nil,
                userInfo: [
                    "id": id,
                    "types": types,
                    "allowMultiple": allowMultiple,
                    "completion": completion
                ]
            )
        }
    }
}

extension Notification.Name {
    static let importFiles = Notification.Name("importFiles")
}

struct FileImporterView: ViewModifier {
    @State private var isImporterPresented: [String: Bool] = [:]
    @State private var activeImporters: [String: ImporterConfig] = [:]
    
    struct ImporterConfig {
        let types: [UTType]
        let allowMultiple: Bool
        let completion: (Result<[URL], Error>) -> Void
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                ForEach(Array(activeImporters.keys), id: \.self) { id in
                    if let config = activeImporters[id] {
                        FileImporterWrapper(
                            isPresented: Binding(
                                get: { isImporterPresented[id] ?? false },
                                set: { isImporterPresented[id] = $0 }
                            ),
                            id: id,
                            config: config,
                            onCompletion: { success in
                                if success {
                                    DispatchQueue.main.async {
                                        activeImporters.removeValue(forKey: id)
                                    }
                                }
                            }
                        )
                    }
                }
            )
            .onReceive(NotificationCenter.default.publisher(for: .importFiles)) { notification in
                guard let userInfo = notification.userInfo,
                      let id = userInfo["id"] as? String,
                      let types = userInfo["types"] as? [UTType],
                      let allowMultiple = userInfo["allowMultiple"] as? Bool,
                      let completion = userInfo["completion"] as? ((Result<[URL], Error>) -> Void) else {
                    return
                }
                
                let config = ImporterConfig(
                    types: types,
                    allowMultiple: allowMultiple,
                    completion: completion
                )
                
                activeImporters[id] = config
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isImporterPresented[id] = true
                }
            }
    }
}

struct FileImporterWrapper: View {
    @Binding var isPresented: Bool
    let id: String
    let config: FileImporterView.ImporterConfig
    let onCompletion: (Bool) -> Void
    
    var body: some View {
        Text("wow")
            .hidden()
            .fileImporter(
                isPresented: $isPresented,
                allowedContentTypes: config.types,
                allowsMultipleSelection: config.allowMultiple
            ) { result in
                switch result {
                case .success(let urls):
                    config.completion(.success(urls))
                case .failure(let error):
                    config.completion(.failure(error))
                }
                onCompletion(true)
            }
    }
}

extension View {
    func withFileImporter() -> some View {
        self.modifier(FileImporterView())
    }
}
