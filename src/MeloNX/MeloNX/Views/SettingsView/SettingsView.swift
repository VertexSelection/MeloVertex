//
//  SettingsView.swift
//  MeloNX
//
//  Created by Stossy11 on 25/11/2024.
//

import SwiftUI

struct SettingsView: View {
    @Binding var config: Ryujinx.Configuration
    @Binding var MoltenVKSettings: [MoltenVKSettings]
    
    var memoryManagerModes = [
        ("HostMapped", "Host (fast)"),
        ("HostMappedUnsafe", "Host Unchecked (fast, unstable / unsafe)"),
        ("SoftwarePageTable", "Software")
    ]
    
    var body: some View {
        Form {
            Section(header: Text("Graphics and Performance")) {
                Toggle("Ryujinx Fullscreen", isOn: $config.fullscreen)
                Toggle("Disable V-Sync", isOn: $config.disableVSync)
                Toggle("Disable Shader Cache", isOn: $config.disableShaderCache)
                Toggle("Enable Texture Recompression", isOn: $config.enableTextureRecompression)
            }
            
            Section(header: Text("Input Settings")) {
                Toggle("List Input IDs", isOn: $config.listinputids)
                // Toggle("Host Mapped Memory", isOn: $config.hostMappedMemory)
                Toggle("Disable Docked Mode", isOn: $config.disableDockedMode)
            }
            
            Section(header: Text("Logging Settings")) {
                Toggle("Enable Debug Logs", isOn: $config.debuglogs)
                Toggle("Enable Trace Logs", isOn: $config.tracelogs)
            }
            Section(header: Text("CPU Mode")) {
                Picker("Memory Manager Mode", selection: $config.memoryManagerMode) {
                    ForEach(memoryManagerModes, id: \.0) { key, displayName in
                        Text(displayName).tag(key)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // Dropdown style
            }
            
            Section(header: Text("Additional Settings")) {
                //TextField("Game Path", text: $config.gamepath)
                
                TextField("Additional Arguments", text: Binding(
                    get: {
                        config.additionalArgs.joined(separator: ", ")
                    },
                    set: { newValue in
                        config.additionalArgs = newValue.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
                    }
                ))
            }
        }
        .onAppear {
            if let configs = loadSettings() {
                self.config = configs
                print(configs)
            }
        }
        .navigationTitle("Settings")
        .navigationBarItems(trailing: Button("Save") {
            saveSettings()
        })
    }
    
    func saveSettings() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // Optional: Makes the JSON easier to read
            let data = try encoder.encode(config)
            let jsonString = String(data: data, encoding: .utf8)
            
            // Save to UserDefaults
            UserDefaults.standard.set(jsonString, forKey: "config")
            
            print("Settings saved successfully!")
        } catch {
            print("Failed to save settings: \(error)")
        }
    }
}
