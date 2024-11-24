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
    var value: String
}

struct ContentView: View {
    @State public var theWindow: UIWindow? = nil
    @State private var virtualController: GCVirtualController?
    @State var game: URL? = nil
    @State var controllerss: [Controller] = []
    
    @State private var settings: [MoltenVKSettings] = [
        MoltenVKSettings(string: "MVK_CONFIG_SYNCHRONOUS_QUEUE_SUBMITS", value: "0"),
        MoltenVKSettings(string: "MVK_CONFIG_PREFILL_METAL_COMMAND_BUFFERS", value: "0"),
        MoltenVKSettings(string: "MVK_CONFIG_MAX_ACTIVE_METAL_COMMAND_BUFFERS_PER_QUEUE", value: "1024"),
        MoltenVKSettings(string: "MVK_CONFIG_USE_METAL_ARGUMENT_BUFFERS", value: "0"),
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
        
        
        if let game {
            ZStack {
                SDLViewRepresentable { displayid in
                    start(displayid: 0)
                }
                Text("Loading...")
                    .onAppear {
                       // start(displayid: 0)
                    }
            }
        } else {
            HStack {
                GameListView(startemu: $game)
                    .onAppear() {
                        Ryujinx().getConnectedControllers()
                    }
                
                List {
                    ForEach($settings, id: \.self) { $setting in
                        HStack {
                            Text(setting.string)
                                .padding()
                            TextField("Value", text: $setting.value)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: setting.value) { newValue in
                                    setenv(setting.string, newValue, 1)
                                }
                        }
                    }
                 
                }
                 
            }
        }
    }
    
    func start(displayid: UInt32) {
        
        let config = Ryujinx.Configuration(
            gamepath: game!.path,
            additionalArgs: [
                // "--display-id", String(displayid)
            ],
            debuglogs: false,
            tracelogs: false,
            listinputids: false,
            inputids: ["1-1fd70005-057e-0000-0920-0000ff870000"], // "2-1fd70005-057e-0000-0920-0000ff870000"],
            ryufullscreen: true
            
        )
        
        
        // Start the emulation
        do {
            setupVirtualController()
            
            try Ryujinx().start(with: config)
            
            
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
    
    func patchMakeKeyAndVisible() {
        let uiwindowClass = UIWindow.self
        if let m1 = class_getInstanceMethod(uiwindowClass, #selector(UIWindow.makeKeyAndVisible)),
           let m2 = class_getInstanceMethod(uiwindowClass, #selector(UIWindow.wdb_makeKeyAndVisible)) {
            method_exchangeImplementations(m1, m2)
        }
    }
    
    
    private func setMoltenVKSettings() {
        settings.forEach { setting in
            setenv(setting.string, setting.value, 1)
        }
    }
}

extension UIWindow {
    @objc func wdb_makeKeyAndVisible() {
        print("Making window key and visible...")
        
        self.windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        
        self.wdb_makeKeyAndVisible()
    }
}

