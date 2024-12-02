//
//  ContentView.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import SwiftUI
import SDL2
import GameController
import Darwin
import UIKit

struct MoltenVKSettings: Codable, Hashable {
    let string: String
    var bool: Bool?
    var value: String?
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
    @State var onscreencontroller: Controller = Controller(id: "", name: "")
    @AppStorage("JIT") var isJITEnabled: Bool = false
    @AppStorage("ignoreJIT") var ignoreJIT: Bool = false
    
    // MARK: - Initialization
    init() {
        let defaultConfig = loadSettings() ?? Ryujinx.Configuration(gamepath: "")
        _config = State(initialValue: defaultConfig)
        
        let defaultSettings: [MoltenVKSettings] = [
            MoltenVKSettings(string: "MVK_CONFIG_MAX_ACTIVE_METAL_COMMAND_BUFFERS_PER_QUEUE", value: "2048"),
            MoltenVKSettings(string: "MVK_CONFIG_USE_METAL_ARGUMENT_BUFFERS", value: "1"),
            MoltenVKSettings(string: "MVK_CONFIG_RESUME_LOST_DEVICE", value: "1")
        ]
        
        _settings = State(initialValue: defaultSettings)
        
        print("JIT Enabled: \(isJITEnabled)")
        
        initializeSDL()
    }
    
    // MARK: - Body
    var body: some View {
        iOSNav {
            if let game {
                emulationView
            } else {
                mainMenuView
            }
        }
        .onChange(of: isVirtualControllerActive) { newValue in
            if newValue {
                createVirtualController()
            } else {
                destroyVirtualController()
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
        HStack {
            GameListView(startemu: $game)
                .onAppear {
                    createVirtualController()
                    refreshControllersList()
                }
            
            settingsListView
        }
    }
    
    private var settingsListView: some View {
        List {
            Section("Settings") {
                NavigationLink("Config") {
                    SettingsView(config: $config, MoltenVKSettings: $settings)
                        .onAppear() {
                            virtualController?.disconnect()
                        }
                }
            }
            
            
            Section {
                Button("Refresh", action: refreshControllersList)
                ForEach(controllersList, id: \.self) { controller in
                    controllerRow(for: controller)
                }
            } header: {
                Text("Controllers")
            } footer: {
                Text("If no controllers are selected, the keyboard will be used.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func controllerRow(for controller: Controller) -> some View {
        HStack {
            Button(controller.name) {
                toggleController(controller)
            }
            Spacer()
            if currentControllers.contains(where: { $0.id == controller.id }) {
                Image(systemName: "checkmark.circle.fill")
            }
        }
    }
    
    // MARK: - Controller Management
    private func createVirtualController() {
        let configuration = GCVirtualController.Configuration()
        configuration.elements = [
            /*
            GCInputLeftThumbstick,
            GCInputRightThumbstick,
            GCInputButtonA,
            GCInputButtonB,
            GCInputButtonX,
            GCInputButtonY,
             */
        ]
        
        virtualController = GCVirtualController(configuration: configuration)
        virtualController?.connect()
        
    }
    
    private func destroyVirtualController() {
        virtualController?.disconnect()
        virtualController = nil
    }
    
    // MARK: - Helper Methods
    private func initializeSDL() {
        DispatchQueue.main.async {
            setMoltenVKSettings()
            SDL_SetMainReady()
            SDL_iPhoneSetEventPump(SDL_TRUE)
            SDL_Init(SDL_INIT_VIDEO)
        }
    }
    
    private func setupEmulation() {
        if !isJITEnabled {
            virtualController?.disconnect()
        
            controllerCallback = {
                DispatchQueue.main.async {
                    controllersList = Ryujinx.shared.getConnectedControllers()
                    
                    print(currentControllers)
                    start(displayid: 1)
                }
            }
            
            
            showVirtualController()
        } else {
            showAlert(title: "JIT Not Enabled", message: "JIT is Required for Emulation. Please use a JIT enabler to Enable JIT", showOk: true) { pressedok in
                if pressedok, !ignoreJIT {
                    game = nil
                } else if pressedok, ignoreJIT {
                    virtualController?.disconnect()
                    controllerCallback = {
                        DispatchQueue.main.async {
                            controllersList = Ryujinx.shared.getConnectedControllers()
                            
                            print(currentControllers)
                            start(displayid: 1)
                        }
                    }
                    
                    
                    showVirtualController()
                }
            }
        }
    }
    
    private func refreshControllersList() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            controllersList = Ryujinx.shared.getConnectedControllers()
            
            if let onscreen = controllersList.first(where: { $0.name.hasPrefix("Apple")}) {
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
    }
    
    private func toggleController(_ controller: Controller) {
        if currentControllers.contains(where: { $0.id == controller.id }) {
            currentControllers.removeAll(where: { $0.id == controller.id })
        } else {
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

