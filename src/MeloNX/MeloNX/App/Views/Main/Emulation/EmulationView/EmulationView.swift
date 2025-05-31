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
    
    @AppStorage("On-ScreenControllerOpacity") var controllerOpacity: Double = 1.0
    
    @AppStorage("disableTouch") var blackScreen = false
    
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
                
                Color.black
                    .ignoresSafeArea()
                    .edgesIgnoringSafeArea(.all)
                    .allowsHitTesting(false)
            } else {
                MetalView() // The Emulation View
                    .ignoresSafeArea()
                    .edgesIgnoringSafeArea(.all)
            }
            
            // Above Emulation View
            
            if isVCA {
                ControllerView() // Virtual Controller
                    .opacity(controllerOpacity)
                    .allowsHitTesting(true)
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
                    
                    
                    if ssb {
                        HStack {
                            
                            Image(systemName: "arrow.left.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .onTapGesture {
                                    startgame = nil
                                    stop_emulation()
                                    try? Ryujinx.shared.stop()
                                }
                                .padding()
                            
                            Spacer()
    
                        }
                    }
                    
                    Spacer()
                    
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
                pause_emulation(true)
                isInBackground = true
            } else if newPhase == .active {
                pause_emulation(false)
                isInBackground = false
            } else if newPhase == .inactive {
                pause_emulation(true)
                isInBackground = true
            }
        }
    }
}
