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
    @State private var virtualController: GCVirtualController?
    @State var game: URL? = nil
    
    init() {
        // Initialize SDL
        DispatchQueue.main.async {
            SDL_SetMainReady()
            SDL_iPhoneSetEventPump(SDL_TRUE)
            
            SDL_Init(SDL_INIT_VIDEO)
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
            GCInputButtonY,
            //GCInputDirectionPad
        ]
        
        let controller = GCVirtualController(configuration: configuration)
        self.virtualController = controller
        controller.connect()
    }
    
    var body: some View {
        
        
        
        if let game {
            SDLViewRepresentable {
                setupVirtualController()

                
                let config = Ryujinx.Configuration(gamepath: game.path, debuglogs: true, tracelogs: true, listinputids: false, inputids: ["1-47150005-05ac-0000-0100-00004f066d01"])
                // Starts the emulation
                do {
                    try Ryujinx().start(with: config)
                } catch {
                    print("Error \(error.localizedDescription)")
                }
            }
        } else {
            GameListView(startemu: $game)
        }
    }
}
