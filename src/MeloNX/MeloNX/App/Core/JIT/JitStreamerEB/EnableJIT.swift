//
//  EnableJIT.swift
//  MeloNX
//
//  Created by Stossy11 on 10/02/2025.
//

import Foundation
import Network
import UIKit

func enableJITEB() {
    if UserDefaults.standard.bool(forKey: "waitForVPN") {
        waitForVPNConnection { connected in
            if connected {
                enableJITEBRequest()
            }
        }
    } else {
        enableJITEBRequest()
    }
}

func enableJITEBRequest() {
    let pid = Int(getpid())
    print(pid)
    
    let address = URL(string: "http://[fd00::]:9172/attach/\(pid)")!
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
                showLaunchAppAlert(jsonData: data, in: windowScene.windows.last!.rootViewController!)
            } else {
                fatalError("Unable to get Window")
            }
        }
    }
    
    task.resume()
}

func waitForVPNConnection(timeout: TimeInterval = 30, interval: TimeInterval = 1, _ completion: @escaping (Bool) -> Void) {
    let startTime = Date()
    let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .background))
    
    timer.schedule(deadline: .now(), repeating: interval)
    
    timer.setEventHandler {
        pingSite { connected in
            if connected {
                timer.cancel()
                DispatchQueue.main.async {
                    completion(true)
                }
            } else if Date().timeIntervalSince(startTime) > timeout {
                timer.cancel()
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    timer.resume()
}

func pingSite(host: String = "http://[fd00::]:9172/hello", completion: @escaping (Bool) -> Void) {
    guard let url = URL(string: host) else {
        completion(false)
        return
    }
    
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 2.0
    config.timeoutIntervalForResource = 2.0
    
    let session = URLSession(configuration: config)
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let task = session.dataTask(with: request) { _, response, error in
        if let error = error {
            print("Ping failed: \(error.localizedDescription)")
            completion(false)
        } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            completion(true)
        } else {
            let httpResponse = response as? HTTPURLResponse
            completion(false)
        }
    }
    
    task.resume()
}


func presentAlert(title: String, message: String, completion: (() -> Void)? = nil) {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let lastWindow = windowScene.windows.last {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        
        DispatchQueue.main.async {
            lastWindow.rootViewController?.present(alert, animated: true)
        }
    }
}

struct LaunchApp: Codable {
    let success: Bool
    let message: String
}

func showLaunchAppAlert(jsonData: Data, in viewController: UIViewController) {
    do {
        let result = try JSONDecoder().decode(LaunchApp.self, from: jsonData)
        
        var message = ""
        
        if !result.success {
            message += "\n\(result.message)"
            
            
            let alert = UIAlertController(title: "JIT Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            DispatchQueue.main.async {
                viewController.present(alert, animated: true)
            }
        } else {
            print("Hopefully JIT is enabled now...")
            Ryujinx.shared.ryuIsJITEnabled()
        }
        
    } catch {
        print(String(data: jsonData, encoding: .utf8))
        let alert = UIAlertController(title: "Decoding Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }
}
