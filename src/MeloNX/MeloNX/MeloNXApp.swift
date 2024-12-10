//
//  MeloNXApp.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import SwiftUI
import UIKit

@main
struct MeloNXApp: App {
    
    @AppStorage("showeddrmcheck") var showed = true
    
    init() {
        DispatchQueue.main.async { [self] in
            // drmcheck()
            if showed {
                drmcheck() { bool in
                    if bool {
                        print("Yippee")
                    } else {
                       //  exit(0)
                    }
                }
            } else {
                showAlert()
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if showed {
                ContentView()
            } else {
                HStack {
                    Text("Loading...")
                    ProgressView()
                }
            }
        }
    }
    
    func showAlert() {
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
                    drmcheck() { bool in
                        if bool {
                            showed = true
                        } else {
                            exit(0)
                        }
                    }
                }
            }
            alertController.addAction(okAction)
            
            // Add a "Cancel" action
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            // Present the alert
            mainWindow.rootViewController!.present(alertController, animated: true, completion: nil)
        } else {
            exit(0)
        }
    }
}


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
