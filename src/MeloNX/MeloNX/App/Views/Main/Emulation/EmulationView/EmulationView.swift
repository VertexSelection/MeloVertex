//
//  EmulationView.swift
//  MeloNX
//
//  Created by Stossy11 on 09/02/2025.
//

import SwiftUI

// Emulation View
struct EmulationView: View {
    @AppStorage("performacehud") var performacehud: Bool = false
    @AppStorage("isVirtualController") var isVCA: Bool = true
    @AppStorage("showScreenShotButton") var ssb: Bool = false
    @AppStorage("showlogsgame") var showlogsgame: Bool = false
    
    @State var isPresentedThree: Bool = false
    @State var isAirplaying = Air.shared.connected
    @Binding var startgame: Game?
    
    @Environment(\.scenePhase) var scenePhase
    @State private var isInBackground = false
    @AppStorage("location-enabled") var locationenabled: Bool = false
    
    var body: some View {
        ZStack {
            if isAirplaying {
                TouchView()
                    .ignoresSafeArea()
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        Air.play(AnyView(MetalView().ignoresSafeArea().edgesIgnoringSafeArea(.all)))
                    }
            } else {
                MetalView() // The Emulation View
                    .ignoresSafeArea()
                    .edgesIgnoringSafeArea(.all)
            }
            
            // Above Emulation View
            
            if isVCA {
                ControllerView() // Virtual Controller
            }
            
            Group {
                VStack {
                    HStack {
                        if performacehud, !showlogsgame {
                            PerformanceOverlayView()
                        }
                        
                        Spacer()
                        
                        if performacehud, showlogsgame {
                            PerformanceOverlayView()
                        }
                    }
                    
                    HStack {
                        if showlogsgame, get_current_fps() != 0 {
                            LogFileView(isfps: false)
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    if ssb {
                        HStack {
                            
                            Button {
                                if let screenshot = Ryujinx.shared.emulationUIView?.screenshot() {
                                    UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil)
                                }
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                            }
                            .frame(width: UIDevice.current.systemName.contains("iPadOS") ? 60 * 1.2 : 45, height: UIDevice.current.systemName.contains("iPadOS") ? 60 * 1.2 : 45)
                            .padding()
                            
                            Spacer()
                            
                            
                            
                        }
                    }
                    
                }
            }
        }
        .onAppear {
            LocationManager.sharedInstance.startUpdatingLocation()
            Air.shared.connectionCallbacks.append { cool in
                DispatchQueue.main.async {
                    isAirplaying = cool
                    // print(cool)
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            // Detect when the app enters the background
            if newPhase == .background {
                stop_emulation(true)
                isInBackground = true
            } else if newPhase == .active {
                stop_emulation(false)
                isInBackground = false
            } else if newPhase == .inactive {
                stop_emulation(true)
                isInBackground = true
            }
        }
    }
}
