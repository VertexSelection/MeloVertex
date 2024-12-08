//
//  MeloNXApp.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import SwiftUI

@main
struct MeloNXApp: App {
    
    init() {
        DispatchQueue.main.async {
            // drmcheck()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


func drmcheck() {
    if let deviceid = UIDevice.current.identifierForVendor?.uuidString, let base64device = deviceid.data(using: .utf8)?.base64EncodedString() {
        if let value = Bundle.main.infoDictionary?["MeloID"] as? String {
            if let url = URL(string: "https://950e-175-32-92-74.ngrok-free.app/auth/\(value)/\(base64device)") {
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
                    } else if let response = response as? HTTPURLResponse, response.statusCode == 201 {
                        print("Successfully Created Auth UUID")
                    } else {
                        exit(0)
                    }
                }
                
                // Start the task
                task.resume()
            }
        } else {
            exit(0)
        }
    } else {
        exit(0)
    }
    
}
