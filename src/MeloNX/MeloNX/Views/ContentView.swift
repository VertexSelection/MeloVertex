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
    @State public var theWindow: UIWindow? = nil
    @State private var virtualController: GCVirtualController?
    @State var game: URL? = nil
    @State var controllersList: [Controller] = []
    @State var currentControllers: [Controller] = []
    @State var config: Ryujinx.Configuration = Ryujinx.Configuration(gamepath: "")
    
    @State var settings: [MoltenVKSettings] = [
        // MoltenVKSettings(string: "MVK_CONFIG_SYNCHRONOUS_QUEUE_SUBMITS", value: ""),
        // MoltenVKSettings(string: "MVK_CONFIG_PREFILL_METAL_COMMAND_BUFFERS", value: "1"),
        MoltenVKSettings(string: "MVK_CONFIG_MAX_ACTIVE_METAL_COMMAND_BUFFERS_PER_QUEUE", value: "1024"),
        MoltenVKSettings(string: "MVK_CONFIG_USE_METAL_ARGUMENT_BUFFERS", value: "1"),
        MoltenVKSettings(string: "MVK_CONFIG_RESUME_LOST_DEVICE", value: "1")
    ]
    
    init() {
        // Initialize SDL
        DispatchQueue.main.async { [self] in
            setMoltenVKSettings()
            SDL_SetMainReady()
            SDL_iPhoneSetEventPump(SDL_TRUE)
            SDL_Init(SDL_INIT_VIDEO)
            patchMakeKeyAndVisible()
        }
    }
    
    func setupVirtualController() {
        let configuration = GCVirtualController.Configuration()
        configuration.elements = [
            GCInputLeftThumbstick,
            GCInputRightThumbstick,
            GCInputButtonA,
            GCInputButtonB,
            GCInputButtonX,
            GCInputButtonY
        ]
        
        let controller = GCVirtualController(configuration: configuration)
        self.virtualController = controller
        self.virtualController?.connect()
    }
    
    var body: some View {
        iOSNav {
            
            if let game {
                ZStack {

                }
                .onAppear {
                    start(displayid: 0)
                }
            } else {
                HStack {
                    GameListView(startemu: $game)
                        .onAppear() {
                            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                                controllersList = Ryujinx.shared.getConnectedControllers()
                                controllersList.removeAll(where: { $0.id == "0" })
                            }
                        }
                    
                    List {
                        Section("Settings") {
                            NavigationLink {
                                SettingsView(config: $config, MoltenVKSettings: $settings)
                            } label: {
                                Text("Config")
                            }
                        }
                        Section("Controller") {
                            Button {
                                controllersList = Ryujinx.shared.getConnectedControllers()
                                controllersList.removeAll(where: { $0.id == "0" })
                            } label: {
                                Text("Refresh")
                            }
                            ForEach(controllersList, id: \.self) { controller in
                                HStack {
                                    Button {
                                        if currentControllers.contains(where: { $0.id == controller.id }) {
                                            currentControllers.removeAll(where: { $0.id == controller.id })
                                        } else {
                                            currentControllers.append(controller)
                                        }
                                    } label: {
                                        Text(controller.name)
                                    }
                                    Spacer()
                                    if currentControllers.contains(where: { $0.id == controller.id }) {
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    func start(displayid: UInt32) {
        
        if let game {
            self.config.gamepath = game.path
            
            self.config.inputids = currentControllers.map(\.id)
            
            allocateSixGB()
            
            // Start the emulation
            
            print("Is MetalHud Enabled? " + (MTLHud.shared.isEnabled ? "yeah" : "nope"))
            do {
                setupVirtualController()
                
                try Ryujinx.shared.start(with: config)
                
                
            } catch {
                print("Error \(error.localizedDescription)")
            }
        } else {
            
        }
        
    }
    
    func allocateSixGB() -> UnsafeMutableRawPointer? {

        let physicalMemory = ProcessInfo.processInfo.physicalMemory
        let totalMemoryInGB = Double(physicalMemory) / (1024 * 1024 * 1024)
        let mem = totalMemoryInGB
        print(mem)
        // Allocate memory
        let pointer = UnsafeMutableRawPointer.allocate(byteCount: Int(mem), alignment: MemoryLayout<UInt8>.alignment)

        // Optionally initialize the memory
        pointer.initializeMemory(as: UInt8.self, repeating: 0, count: Int(mem))

        print("Successfully allocated 6GB of memory.")
        return pointer
    }
    
    func patchMakeKeyAndVisible() {
        let uiwindowClass = UIWindow.self
        if let m1 = class_getInstanceMethod(uiwindowClass, #selector(UIWindow.makeKeyAndVisible)),
           let m2 = class_getInstanceMethod(uiwindowClass, #selector(UIWindow.wdb_makeKeyAndVisible)) {
            method_exchangeImplementations(m1, m2)
        }
    }
    
    
    private func setMoltenVKSettings() {
        
        if let configs = loadSettings() {
            self.config = configs
            print(configs)
        }
        
        settings.forEach { setting in
            setenv(setting.string, setting.value, 1)
        }
    }
    
}
func loadSettings() -> Ryujinx.Configuration? {
    guard let jsonString = UserDefaults.standard.string(forKey: "config") else {
        return nil
    }
    
    do {
        let decoder = JSONDecoder()
        if let data = jsonString.data(using: .utf8) {
            return try decoder.decode(Ryujinx.Configuration.self, from: data)
        }
    } catch {
        print("Failed to load settings: \(error)")
    }
    return nil
}

extension UIWindow {
    @objc func wdb_makeKeyAndVisible() {
        print("Making window key and visible...")
        
        self.windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        
        self.wdb_makeKeyAndVisible()
    }
}

