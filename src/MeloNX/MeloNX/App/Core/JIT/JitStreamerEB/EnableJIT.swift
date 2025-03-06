//
//  EnableJIT.swift
//  MeloNX
//
//  Created by Stossy11 on 10/02/2025.
//

import Foundation

func enableJITEB()  {
    guard let bundleID = Bundle.main.bundleIdentifier else {
        return
    }
    
    let address = URL(string: "http://[fd00::]:9172/launch_app/\(bundleID)")!
    
    let task = URLSession.shared.dataTask(with: address) { data, response, error in
        if error != nil {
            return
        }
        
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return
        }
        DispatchQueue.main.async {
            showLaunchAppAlert(jsonData: data!, in: UIApplication.shared.windows.last!.rootViewController!)
        }
        
        return
    }
    
    task.resume()
}

struct LaunchApp: Codable {
    let ok: Bool
    let error: String?
    let launching: Bool
    let position: Int?
    let mounting: Bool
}

func showLaunchAppAlert(jsonData: Data, in viewController: UIViewController) {
    do {
        let result = try JSONDecoder().decode(LaunchApp.self, from: jsonData)
        
        var message = ""
        
        if let error = result.error {
            message = "Error: \(error)"
        } else if result.mounting {
            message = "App is mounting..."
        } else if result.launching {
            message = "App is launching..."
        } else {
            message = "App launch status unknown."
        }
        
        if let position = result.position {
            message += "\nPosition: \(position)"
        }
        
        let alert = UIAlertController(title: "Launch Status", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
        
    } catch {
        let alert = UIAlertController(title: "Decoding Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }
}
