//
//  EnableJIT.swift
//  MeloNX
//
//  Created by Stossy11 on 10/02/2025.
//

import Foundation
import Network
import UIKit

func enableJITStik() {
    let bundleid = Bundle.main.bundleIdentifier ?? "Unknown"
    
    let address = URL(string: "stikjit://enable-jit?bundle-id=\(bundleid)")!
    var request = URLRequest(url: address)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            presentAlert(title: "Request Error", message: error.localizedDescription)
            return
        }
        
        DispatchQueue.main.async {
            if let data = data, let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                // JIT, wow
            } else {
                fatalError("Unable to get Window")
            }
        }
    }
    
    task.resume()
}
