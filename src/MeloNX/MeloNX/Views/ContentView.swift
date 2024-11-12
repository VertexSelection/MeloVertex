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
    
    init() {
        // Initialize SDL
        DispatchQueue.main.async { [self] in
            SDL_SetMainReady()
            SDL_iPhoneSetEventPump(SDL_TRUE)
            SDL_Init(SDL_INIT_VIDEO)
            
            // Apply the window patch early
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
        controller.connect()
    }
    
    var body: some View {
        if let game {
            
            SDLViewRepresentable { displayid in
                start(displayid: displayid)
            }
        } else {
            GameListView(startemu: $game)
        }
    }
    
    func start(displayid: UInt32) {
        
        
        
        
        let config = Ryujinx.Configuration(
            gamepath: game!.path,
            additionalArgs: [
                "--display-id", String(displayid)
            ],
            debuglogs: true,
            tracelogs: true,
            listinputids: false,
            inputids: ["1-47150005-05ac-0000-0100-00004f066d01"],
            ryufullscreen: true
        )
        
        
        // Start the emulation
        do {
            if theWindow == nil {
                // Ensure theWindow is set
                theWindow = UIApplication.shared.windows.first
            }
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
}

extension UIWindow {
    @objc func wdb_makeKeyAndVisible() {
        print("Making window key and visible...")
        
        if #available(iOS 13.0, *) {
            self.windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        }
        
        self.wdb_makeKeyAndVisible()
        
        // Update ContentView's reference to this window instance
        if let rootView = self.rootViewController as? UIHostingController<ContentView> {
            rootView.rootView.theWindow = self
        }
    }
}

