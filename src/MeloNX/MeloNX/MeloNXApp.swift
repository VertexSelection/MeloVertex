//
//  MeloNXApp.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import SwiftUI
import UIKit
import CryptoKit



@main
struct MeloNXApp: App {
    
    @State var showed = false
    @Environment(\.scenePhase) var scenePhase
    @State var alert: UIAlertController? = nil
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showed || DRM != 1 {
                    ContentView()
                } else {
                    Group {
                        VStack {
                            Spacer()
                            
                            HStack {
                                Text("Loading...")
                                ProgressView()
                            }
                            Spacer()
                            
                            Text(UIDevice.current.identifierForVendor?.uuidString ?? "")
                        }
                    }
                    .onAppear {
                        initR()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(1))
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    func initR() {
        if DRM == 1 {
            DispatchQueue.main.async { [self] in
                // drmcheck()
                InitializeRyujinx() { bool in
                    if bool {
                        print("Ryujinx Files Initialized Successfully")
                        DispatchQueue.main.async { [self] in
                            withAnimation {
                                showed = true
                            }
                            
                            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                InitializeRyujinx() { bool in
                                    if !bool, (scenePhase != .background || scenePhase == .inactive) {
                                        withAnimation {
                                            showed = false
                                        }
                                        if !(alert?.isViewLoaded ?? false) {
                                            alert = showDMCAAlert()
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            alert?.dismiss(animated: true)
                                            showed = true
                                        }
                                    }
                                }
                            }
                            
                        }
                        
                    } else {
                        showDMCAAlert()
                    }
                    
                }
                
            }
            
        }

    }

    
    func showAlert() -> UIAlertController? {
        // Create the alert controller
        if let mainWindow = UIApplication.shared.windows.last {
            let alertController = UIAlertController(title: "Enter license", message: "Enter license key:", preferredStyle: .alert)
            
            // Add a text field to the alert
            alertController.addTextField { textField in
                textField.placeholder = "Enter key here"
            }
            
            // Add the "OK" action
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                // Get the text entered in the text field
                if let textField = alertController.textFields?.first, let enteredText = textField.text {
                    print("Entered text: \(enteredText)")
                    UserDefaults.standard.set(enteredText, forKey: "MeloDRMID")
                    // drmcheck() { bool in
                        // if bool {
                            // showed = true
                        // } else {
                            // exit(0)
                        // }
                    // }
                }
            }
            alertController.addAction(okAction)
            
            // Add a "Cancel" action
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            // Present the alert
            mainWindow.rootViewController!.present(alertController, animated: true, completion: nil)
            
            return alertController
        } else {
            return nil
        }
    }
    
    
}

func showDMCAAlert() -> UIAlertController? {
    if let mainWindow = UIApplication.shared.windows.first {
        let alertController = UIAlertController(title: "Unauthorized Copy Notice", message: "This app was illegally leaked. Please report the download on the MeloNX Discord. In the meantime, check out Pomelo! \n -Stossy11", preferredStyle: .alert)
        
        DispatchQueue.main.async {
            mainWindow.rootViewController!.present(alertController, animated: true, completion: nil)
        }
        
        return alertController
    } else {
        // uhoh
        return nil
    }
}

/*
func drmcheck(completion: @escaping (Bool) -> Void) {
    if let deviceid = UIDevice.current.identifierForVendor?.uuidString, let base64device = deviceid.data(using: .utf8)?.base64EncodedString() {
        if let value = UserDefaults.standard.string(forKey: "MeloDRMID") {
            if let url = URL(string: "https://mx.stossy11.com/auth/\(value)/\(base64device)") {
                print(url)
                // Create a URLSession
                let session = URLSession.shared
                
                // Create a data task
                let task = session.dataTask(with: url) { data, response, error in
                    // Handle errors
                    if let error = error {
                        exit(0)
                    }
                    
                    // Check response and data
                    if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                        print("Successfully Recieved API Data")
                        completion(true)
                    } else if let response = response as? HTTPURLResponse, response.statusCode == 201 {
                        print("Successfully Created Auth UUID")
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
                
                // Start the task
                task.resume()
            }
        } else {
            completion(false)
        }
    } else {
        completion(false)
    }
    
}
*/

func InitializeRyujinx(completion: @escaping (Bool) -> Void) {
    let path = "aHR0cHM6Ly9teC5zdG9zc3kxMS5jb20v"
    
    guard let value = Bundle.main.object(forInfoDictionaryKey: "MeloID") as? String, !value.isEmpty else {
        completion(false)
        return
    }
    
    
    
    if (detectRoms(path: path) != value) {
        completion(false)
    }
    
    let configuration = URLSessionConfiguration.default
    configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    configuration.urlCache = nil
    
    let session = URLSession(configuration: configuration)
    
    guard let url = URL(string: addFolders(path)!) else {
        completion(false)
        return
    }
    
    let task = session.dataTask(with: url) { data, response, error in
        if error != nil {
            completion(false)
        }
        
        
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(false)
            return
        }
        
        if httpResponse.statusCode == 200 {
            completion(true)
        } else {
            completion(false)
        }
        return
    }
    task.resume()
}

func detectRoms(path string: String) -> String {
    let inputData = Data(string.utf8)
    let romHash = SHA256.hash(data: inputData)
    return romHash.compactMap { String(format: "%02x", $0) }.joined()
}



func addFolders(_ folderPath: String) -> String? {
    let fileManager = FileManager.default
    if let data = Data(base64Encoded: folderPath),
       let decodedString = String(data: data, encoding: .utf8), let fileURL = UIDevice.current.identifierForVendor?.uuidString {
        return decodedString + "auth/" + fileURL + "/"
    }
    return nil
}

extension String {
    
    func print() {
        Swift.print(self)
    }
}
