//
//  ContentView.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import SwiftUI
import SDL2
import GameController

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
    @State var onscreencontroller: Controller?
    
    // MARK: - Initialization
    init() {
        let defaultConfig = Ryujinx.Configuration(gamepath: "")
        _config = State(initialValue: defaultConfig)
        
        let defaultSettings: [MoltenVKSettings] = [
            MoltenVKSettings(string: "MVK_CONFIG_MAX_ACTIVE_METAL_COMMAND_BUFFERS_PER_QUEUE", value: "1024"),
            MoltenVKSettings(string: "MVK_CONFIG_USE_METAL_ARGUMENT_BUFFERS", value: "1"),
            MoltenVKSettings(string: "MVK_CONFIG_RESUME_LOST_DEVICE", value: "1")
        ]
        _settings = State(initialValue: defaultSettings)
        
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
                }
            }
            
            Section("Controller") {
                Button("Refresh", action: refreshControllersList)
                Divider()
                ForEach(controllersList, id: \.self) { controller in
                    controllerRow(for: controller)
                }
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
        virtualController?.disconnect()
        
        if controllersList.first(where: { $0 == onscreencontroller}) != nil {
            controllerCallback = {
                DispatchQueue.main.async {
                    controllersList = Ryujinx.shared.getConnectedControllers()
                    
                    print(currentControllers)
                    start(displayid: 1)
                }
            }
            
            
            showVirtualController()
        } else {
            
            DispatchQueue.main.async {
                print(currentControllers)
                start(displayid: 1)
            }
        }
    }
    
    private func refreshControllersList() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            controllersList = Ryujinx.shared.getConnectedControllers()
            var controller = controllersList.first(where: { $0.name == "Apple Touch Controller" })
            
            controllersList.removeAll(where: { $0.name == "Apple Touch Controller" })
            
            controller?.name = "On-Screen Controller"
            
            onscreencontroller = controller
            
            controllersList.append(controller!)
            // controllersList.removeAll(where: { $0.name == "Apple Touch Controller" })
            if controllersList.count > 2 {
                let controller = controllersList[2]
                currentControllers.append(controller)
                
            } else if let controller = controllersList.first(where: { $0.id == controller?.id }), !controllersList.isEmpty {
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
    
    private func start(displayid: UInt32) {
        guard let game else { return }
        
        config.gamepath = game.path
        config.inputids = currentControllers.map(\.id)
        
        allocateMemory()
        
        do {
            try Ryujinx.shared.start(with: config)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private func allocateMemory() {
        let physicalMemory = ProcessInfo.processInfo.physicalMemory
        let totalMemoryInGB = Double(physicalMemory) / (1024 * 1024 * 1024)
        
        let pointer = UnsafeMutableRawPointer.allocate(
            byteCount: Int(totalMemoryInGB),
            alignment: MemoryLayout<UInt8>.alignment
        )
        pointer.initializeMemory(as: UInt8.self, repeating: 0, count: Int(totalMemoryInGB))
    }
    
    private func setMoltenVKSettings() {
        if let configs = loadSettings() {
            self.config = configs
        }
        
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
