//
//  ContentView.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import SwiftUI
import SDL2
import GameController

struct ContentView: View {
    @State public var theWindow: UIWindow? = nil
    @State private var virtualController: GCVirtualController?
    @State var game: URL? = nil
    @State var controllerss: [Controller] = []
    
    init() {
        setMoltenVKSettings()
        // Initialize SDL
        DispatchQueue.main.async { [self] in
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
                /*
                List {
                    ForEach(Ryujinx().controllerMap) { controllers in
                        Button {
                            if controllerss.contains(where: { $0.id == controllers.id }) {
                                controllerss.removeAll(where: { $0.id == controllers.id })
                            } else {
                                controllerss.append(controllers)
                            }
                        } label: {
                            if controllerss.contains(where: { $0.id == controllers.id }) {
                                HStack {
                                    Text(controllers.name)
                                    Spacer()
                                    Text("enabled")
                                }
                            } else {
                                Text(controllers.name)
                            }
                        }
                    }
                 
                }
                 */
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
            inputids: [], //"1-1fd70005-057e-0000-0920-0000ff870000"], // "2-1fd70005-057e-0000-0920-0000ff870000"],
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
        
        
        let settings: [String: String] = [
            "MVK_DEBUG": "1",
            "MVK_CONFIG_DEBUG": "1",
            "MVK_CONFIG_PREALLOCATE_DESCRIPTORS": "1",
            "MVK_CONFIG_TEXTURE_1D_AS_2D": "0",
            "MVK_CONFIG_SYNCHRONOUS_QUEUE_SUBMITS": "0",
            "MVK_CONFIG_PREFILL_METAL_COMMAND_BUFFERS": "3",
            "MVK_CONFIG_MAX_ACTIVE_METAL_COMMAND_BUFFERS_PER_QUEUE": "512",
            "MVK_CONFIG_USE_METAL_ARGUMENT_BUFFERS": "1",
            "MVK_USE_METAL_PRIVATE_API": "1",
            "MVK_CONFIG_RESUME_LOST_DEVICE": "1",
            "MVK_CONFIG_USE_METAL_PRIVATE_API": "1",
            // "MVK_CONFIG_ALLOW_METAL_NON_STANDARD_IMAGE_COPIES": "1"
        ]
        
        settings.forEach { strins in
           setenv(strins.key, strins.value, 1)
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

