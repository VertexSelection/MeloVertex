//
//  TabView.swift
//  MeloNX
//
//  Created by Stossy11 on 10/12/2024.
//

import SwiftUI
import UniformTypeIdentifiers


struct MainTabView: View {
    @Binding var startemu: Game?
    @Binding var MVKconfig: [MoltenVKSettings]
    @Binding var controllersList: [Controller]
    @Binding var currentControllers: [Controller]
    
    @Binding var onscreencontroller: Controller
    
    var body: some View {
        TabView {
            GameLibraryView(startemu: $startemu)
                .tabItem {
                    Label("Games", systemImage: "gamecontroller.fill")
                }
            
            // SettingsView(config: $config, MoltenVKSettings: $MVKconfig, controllersList: $controllersList, currentControllers: $currentControllers, onscreencontroller: $onscreencontroller)
            SettingsViewNew(MoltenVKSettings: $MVKconfig, controllersList: $controllersList, currentControllers: $currentControllers, onscreencontroller: $onscreencontroller)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
