//
//  ContentView.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import SwiftUI
// import SDL2
import GameController
import Darwin
import UIKit
import MetalKit
// import SDL
import SoftwareKeyboard

struct MoltenVKSettings: Codable, Hashable {
    let string: String
    var value: String
}

struct ContentView: View {
    // MARK: - Properties
    @State private var theWindow: UIWindow?
    @State private var virtualController: GCVirtualController?
    @State private var game: URL?
    @State private var controllersList: [Controller] = []
    @State private var currentControllers: [Controller] = []
    @State private var config: Ryujinx.Configuration
    @State private var settings: [MoltenVKSettings]
    @State private var isVirtualControllerActive: Bool = false
    @AppStorage("isVirtualController") var isVCA: Bool = true
    @State var onscreencontroller: Controller = Controller(id: "", name: "")
    @AppStorage("JIT") var isJITEnabled: Bool = false
    
    @AppStorage("quit") var quit: Bool = false
    
    @State var quits: Bool = false
    
    // MARK: - Initialization
    init() {
        let defaultConfig = loadSettings() ?? Ryujinx.Configuration(gamepath: "")
        _config = State(initialValue: defaultConfig)
        
        let defaultSettings: [MoltenVKSettings] = [
            MoltenVKSettings(string: "MVK_CONFIG_PREFILL_METAL_COMMAND_BUFFERS", value: "2"),
            MoltenVKSettings(string: "MVK_CONFIG_USE_METAL_PRIVATE_API", value: "1")
        ]
        
        _settings = State(initialValue: defaultSettings)
        
        print("JIT Enabled: \(isJITEnabled)")
        
        initializeSDL()
    }
    
    // MARK: - Body
    var body: some View {
        if let game, quits == false {
            emulationView
                .onAppear() {
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                        print(quit)
                        
                        quits = quit
                        
                        if quits {
                            quit = false
                            timer.invalidate()
                        }
                    }
                }
        } else {
            mainMenuView
                .onAppear() {
                    quits = false
                }
        }
    }
    
    // MARK: - View Components
    private var emulationView: some View {
        ZStack {}
            .onAppear {
                setupEmulation()
            }
    }
    
    private var mainMenuView: some View {
        MainTabView(startemu: $game, config: $config, MVKconfig: $settings, controllersList: $controllersList, currentControllers: $currentControllers, onscreencontroller: $onscreencontroller)
            .onAppear() {
                refreshControllersList()
            }
    }
    
    // MARK: - Helper Methods
    var SdlInitFlags: uint = SDL_INIT_EVENTS | SDL_INIT_GAMECONTROLLER | SDL_INIT_JOYSTICK | SDL_INIT_AUDIO | SDL_INIT_VIDEO;
    private func initializeSDL() {
        setMoltenVKSettings()
        SDL_SetMainReady()
        SDL_iPhoneSetEventPump(SDL_TRUE)
        SDL_Init(SdlInitFlags)
        initialize()
    }
    
    private func setupEmulation() {
        virtualController?.disconnect()
        patchMakeKeyAndVisible()
        
        if (currentControllers.first(where: { $0 == onscreencontroller }) != nil) {
            
            isVCA = true
            
            DispatchQueue.main.async {
                start(displayid: 1)
            }
            
            
        } else {
            isVCA = false
            
            DispatchQueue.main.async {
                start(displayid: 1)
            }
            
            
        }
    }
    
    private func refreshControllersList() {
        controllersList = Ryujinx.shared.getConnectedControllers()
        
        if let onscreen = controllersList.first(where: { $0.name == Ryujinx.shared.virtualController.controllername }) {
            self.onscreencontroller = onscreen
        }
        
        controllersList.removeAll(where: { $0.id == "0"})
        
        if controllersList.count > 2 {
            let controller =  controllersList[2]
            currentControllers.append(controller)
        } else if let controller = controllersList.first(where: { $0.id == onscreencontroller.id }), !controllersList.isEmpty {
            currentControllers.append(controller)
        }
    }

    func showAlert(title: String, message: String, showOk: Bool, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            if let mainWindow = UIApplication.shared.windows.last {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                if showOk {
                    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                        completion(true)
                    }

                    alert.addAction(okAction)
                } else {
                    completion(false)
                }
                
                mainWindow.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }

    
    private func start(displayid: UInt32) {
        guard let game else { return }
        
        config.gamepath = game.path
        config.inputids = Array(Set(currentControllers.map(\.id)))
        
        if config.inputids.isEmpty {
            config.inputids.append("0")
        }
        
        do {
            try Ryujinx.shared.start(with: config)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

    
    private func setMoltenVKSettings() {
        
        settings.forEach { setting in
            setenv(setting.string, setting.value, 1)
        }
    }
}

// MARK: - Helper Functions
func loadSettings() -> Ryujinx.Configuration? {
    guard let jsonString = UserDefaults.standard.string(forKey: "config"),
          let data = jsonString.data(using: .utf8) else {
        return nil
    }
    
    do {
        return try JSONDecoder().decode(Ryujinx.Configuration.self, from: data)
    } catch {
        print("Failed to load settings: \(error)")
        return nil
    }
}

