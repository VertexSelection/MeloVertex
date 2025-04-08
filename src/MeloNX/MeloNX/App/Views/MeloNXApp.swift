//
//  MeloNXApp.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import SwiftUI
import UIKit
import CryptoKit
import UniformTypeIdentifiers

extension UIDocumentPickerViewController {
    @objc func fix_init(forOpeningContentTypes contentTypes: [UTType], asCopy: Bool) -> UIDocumentPickerViewController {
        return fix_init(forOpeningContentTypes: contentTypes, asCopy: true)
    }
}

@main
struct MeloNXApp: App {
    
    @State var showed = false
    @Environment(\.scenePhase) var scenePhase
    @State var alert: UIAlertController? = nil
    
    @State var showOutOfDateSheet = false
    @State var updateInfo: LatestVersionResponse? = nil
    
    @State var finished = false
    @AppStorage("hasbeenfinished") var finishedStorage: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if finishedStorage {
                ContentView()
                    .onAppear {
                        checkLatestVersion()
                    }
                    .sheet(isPresented: Binding(
                        get: { showOutOfDateSheet && updateInfo != nil },
                        set: { newValue in
                            if !newValue {
                                showOutOfDateSheet = false
                                updateInfo = nil
                            }
                        }
                    )) {
                        if let updateInfo = updateInfo {
                            MeloNXUpdateSheet(updateInfo: updateInfo, isPresented: $showOutOfDateSheet)
                        }
                    }
            } else {
                SetupView(finished: $finished)
                    .onChange(of: finished) { newValue in
                        withAnimation {
                            withAnimation {
                                finishedStorage = newValue
                            }
                        }
                    }
            }
        }
    }
    
    func checkLatestVersion() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        let strippedAppVersion = appVersion.replacingOccurrences(of: ".", with: "")
        
        #if DEBUG
        let urlString = "http://192.168.178.116:8000/api/latest_release"
        #else
        let urlString = "https://melonx.org/api/latest_release"
        #endif
        
        guard let url = URL(string: urlString) else {
            // print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                // print("Error checking for new version: \(error)")
                return
            }
            
            guard let data = data else {
                // print("No data received")
                return
            }
            
            do {
                let latestVersionResponse = try JSONDecoder().decode(LatestVersionResponse.self, from: data)
                let latestAPIVersionStripped = latestVersionResponse.version_number_stripped
                
                if Int(strippedAppVersion) ?? 0 > Int(latestAPIVersionStripped) ?? 0 {
                    DispatchQueue.main.async {
                        updateInfo = latestVersionResponse
                        showOutOfDateSheet = true
                    }
                }
            } catch {
                // print("Failed to decode response: \(error)")
            }
        }
        
        task.resume()
    }
}
