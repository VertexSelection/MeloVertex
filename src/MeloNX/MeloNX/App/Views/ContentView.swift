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

struct MoltenVKSettings: Codable, Hashable {
    let string: String
    var value: String
}

struct ContentView: View {
    // Games
    @State private var game: Game?
    
    // Controllers
    @State private var controllersList: [Controller] = []
    @State private var currentControllers: [Controller] = []
    @State var onscreencontroller: Controller = Controller(id: "", name: "")
    @State var nativeControllers: [GCController: NativeController] = [:]
    @State private var isVirtualControllerActive: Bool = false
    @AppStorage("isVirtualController") var isVCA: Bool = true
    
    // Settings and Configuration
    @State private var config: Ryujinx.Configuration
    @State var settings: [MoltenVKSettings]
    @AppStorage("useTrollStore") var useTrollStore: Bool = false
    
    // JIT
    @AppStorage("jitStreamerEB") var jitStreamerEB: Bool = false
    
    // Other Configuration
    @State var isMK8: Bool = false
    @AppStorage("quit") var quit: Bool = false
    @State var quits: Bool = false
    @AppStorage("MVK_CONFIG_PREFILL_METAL_COMMAND_BUFFERS") var mVKPreFillBuffer: Bool = true
    @AppStorage("MVK_CONFIG_SYNCHRONOUS_QUEUE_SUBMITS") var syncqsubmits: Bool = true
    
    // Loading Animation
    @State private var clumpOffset: CGFloat = -100
    private let clumpWidth: CGFloat = 100
    private let animationDuration: Double = 1.0
    @State private var isAnimating = false
    @State var isLoading = true

    // MARK: - Initialization
    init() {
        let defaultConfig = loadSettings() ?? Ryujinx.Configuration(gamepath: "")
        _config = State(initialValue: defaultConfig)
        
        let defaultSettings: [MoltenVKSettings] = [ // Default MoltenVK Settings.
            MoltenVKSettings(string: "MVK_USE_METAL_PRIVATE_API", value: "1"),
            MoltenVKSettings(string: "MVK_CONFIG_USE_METAL_PRIVATE_API", value: "1"),
            MoltenVKSettings(string: "MVK_DEBUG", value: "0"),
            MoltenVKSettings(string: "MVK_CONFIG_SYNCHRONOUS_QUEUE_SUBMITS", value: "0"),
            // Uses more ram but makes performance higher, may add an option in settings to change or enable / disable this value (default 64)
            MoltenVKSettings(string: "MVK_CONFIG_MAX_ACTIVE_METAL_COMMAND_BUFFERS_PER_QUEUE", value: "128"),
        ]
        
        _settings = State(initialValue: defaultSettings)
        
        initializeSDL()
    }
    
    // MARK: - Body
    var body: some View {
        if game != nil, quits == false {
            if isLoading {
                if Air.shared.connected {
                    Text("")
                        .onAppear() {
                            Air.play(AnyView(emulationView))
                        }
                } else {
                    ZStack {
                        emulationView
                    }
                }
            } else {
                // This is when the game starts to stop the animation
                if #available(iOS 16, *) {
                    EmulationView()
                        .persistentSystemOverlays(.hidden)
                        .onAppear() {
                            isAnimating = false
                        }
                } else {
                    EmulationView()
                        .persistentSystemOverlays(.hidden)
                        .onAppear() {
                            isAnimating = false
                        }
                }
            }
        } else {
            // This is the main menu view that includes the Settings and the Game Selector
            mainMenuView
                .onAppear() {
                    quits = false

                    initControllerObservers() // This initializes the Controller Observers that refreshes the controller list when a new controller connecvts.
                }
                .onOpenURL() { url in
                    if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                       components.host == "game" {
                        if let text = components.queryItems?.first(where: { $0.name == "id" })?.value {

                            game = Ryujinx.shared.games.first(where: { $0.titleId == text })
                        } else if let text = components.queryItems?.first(where: { $0.name == "name" })?.value {
                            game = Ryujinx.shared.games.first(where: { $0.titleName == text })
                        }
                    }
                }
        }
        
    }
    
    
    private func initControllerObservers() {
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main) { notification in
                if let controller = notification.object as? GCController {
                    print("Controller connected: \(controller.productCategory)")
                    nativeControllers[controller] = .init(controller)
                    refreshControllersList()
                }
        }
        
        
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidDisconnect,
            object: nil,
            queue: .main) { notification in
                if let controller = notification.object as? GCController {
                    print("Controller disconnected: \(controller.productCategory)")
                    nativeControllers[controller]?.cleanup()
                    nativeControllers[controller] = nil
                    refreshControllersList()
                }
        }
    }
        
    // MARK: - View Components
    private var emulationView: some View {
        GeometryReader { screenGeometry in
            ZStack {
                HStack(spacing: screenGeometry.size.width * 0.04) {
                    if let icon = game?.icon {
                        Image(uiImage: icon)
                            .resizable()
                            .frame(
                                width: min(screenGeometry.size.width * 0.25, 250),
                                height: min(screenGeometry.size.width * 0.25, 250)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    
                    VStack(alignment: .leading, spacing: screenGeometry.size.height * 0.015) {
                        Text("Loading \(game?.titleName ?? "Game")")
                            .font(.system(size: min(screenGeometry.size.width * 0.04, 32)))
                            .foregroundColor(.white)
                        
                        GeometryReader { geometry in
                            let containerWidth = min(screenGeometry.size.width * 0.35, 350)
                            
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .cornerRadius(10)
                                    .frame(width: containerWidth, height: min(screenGeometry.size.height * 0.015, 12))
                                    .foregroundColor(.gray.opacity(0.3))
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                
                                Rectangle()
                                    .cornerRadius(10)
                                    .frame(width: clumpWidth, height: min(screenGeometry.size.height * 0.015, 12))
                                    .foregroundColor(.blue)
                                    .shadow(color: .blue.opacity(0.5), radius: 4, x: 0, y: 2)
                                    .offset(x: isAnimating ? containerWidth : -clumpWidth)
                                    .animation(
                                        Animation.linear(duration: 1.0)
                                            .repeatForever(autoreverses: false),
                                        value: isAnimating
                                    )
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .onAppear {
                                isAnimating = true
                                
                                setupEmulation()
                                
                                
                                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                                    if get_current_fps() != 0 {
                                        withAnimation {
                                            isLoading = false
                                        }
                                        
                                        isAnimating = false
                                        timer.invalidate()
                                    }
                                    print(get_current_fps())
                                }
                            }
                        }
                        .frame(height: min(screenGeometry.size.height * 0.015, 12))
                        .frame(width: min(screenGeometry.size.width * 0.35, 350))
                    }
                }
                .padding(.horizontal, screenGeometry.size.width * 0.06)
                .padding(.vertical, screenGeometry.size.height * 0.05)
                .position(
                    x: screenGeometry.size.width / 2,
                    y: screenGeometry.size.height * 0.5
                )
            }
        }
    }

    private var mainMenuView: some View {
        MainTabView(startemu: $game, config: $config, MVKconfig: $settings, controllersList: $controllersList, currentControllers: $currentControllers, onscreencontroller: $onscreencontroller)
            .onAppear() {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
                    refreshControllersList()
                }
                
                Air.play(AnyView(
                    VStack {
                        Image(systemName: "gamecontroller")
                            .font(.system(size: 300))
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)
                        
                        Text("Select Game")
                            .font(.system(size: 150))
                            .bold()
                    }
                ))
                
                let isJIT = isJITEnabled()
                if !isJIT {
                    useTrollStore ? askForJIT() : enableJITEB()
                }
            }
    }
    
    // MARK: - Helper Methods
    var SdlInitFlags: uint = SDL_INIT_EVENTS | SDL_INIT_GAMECONTROLLER | SDL_INIT_JOYSTICK | SDL_INIT_AUDIO | SDL_INIT_VIDEO; // Initialises SDL2 for Events, Game Controller, Joystick, Audio and Video.
    private func initializeSDL() {
        setMoltenVKSettings()
        SDL_SetMainReady() // Sets SDL Ready
        SDL_iPhoneSetEventPump(SDL_TRUE) // Set iOS Event Pump to true
        SDL_Init(SdlInitFlags) // Initialises SDL2
        initialize()
    }
    
    private func setupEmulation() {
        patchMakeKeyAndVisible()
        isVCA = (currentControllers.first(where: { $0 == onscreencontroller }) != nil)
        
        DispatchQueue.main.async {
            start(displayid: 1)
        }
    }
    
    private func refreshControllersList() {
        controllersList = Ryujinx.shared.getConnectedControllers()
        
        if let onscreen = controllersList.first(where: { $0.name == Ryujinx.shared.virtualController.controllername }) {
            self.onscreencontroller = onscreen
        }
        
        controllersList.removeAll(where: { $0.id == "0" || (!$0.name.starts(with: "GC - ") && $0 != onscreencontroller) })
        controllersList.mutableForEach { $0.name = $0.name.replacingOccurrences(of: "GC - ", with: "") }

        currentControllers = []
        
        if controllersList.count == 1 {
            let controller = controllersList[0]
            currentControllers.append(controller)
        } else if (controllersList.count - 1) >= 1 {
            for controller in controllersList {
                if controller.id != onscreencontroller.id && !currentControllers.contains(where: { $0.id == controller.id }) {
                    currentControllers.append(controller)
                }
            }
        }
    }
    

    
    private func start(displayid: UInt32) {
        guard let game else { return }
        
        config.gamepath = game.fileURL.path
        config.inputids = Array(Set(currentControllers.map(\.id)))
        
        if mVKPreFillBuffer {
            let setting = MoltenVKSettings(string: "MVK_CONFIG_PREFILL_METAL_COMMAND_BUFFERS", value: "2")
            setenv(setting.string, setting.value, 1)
        }
        
        if syncqsubmits {
            let setting = MoltenVKSettings(string: "MVK_CONFIG_SYNCHRONOUS_QUEUE_SUBMITS", value: "2")
            setenv(setting.string, setting.value, 1)
        }
        
        if config.inputids.isEmpty {
            config.inputids.append("0")
        }
        
        do {
            try Ryujinx.shared.start(with: config)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    

    // Sets MoltenVK Environment Variables
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

extension Array {
    @inlinable public mutating func mutableForEach(_ body: (inout Element) throws -> Void) rethrows {
        for index in self.indices {
            try body(&self[index])
        }
    }
}
