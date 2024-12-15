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
    
    @Binding var controllersList: [Controller]
    @Binding var currentControllers: [Controller]
    
    @Binding var onscreencontroller: Controller
    
    @AppStorage("ignoreJIT") var ignoreJIT: Bool = false
    
    var memoryManagerModes = [
        ("HostMapped", "Host (fast)"),
        ("HostMappedUnsafe", "Host Unchecked (fast, unstable / unsafe)"),
        ("SoftwarePageTable", "Software (slow)"),
    ]
    
    @AppStorage("RyuDemoControls") var ryuDemo: Bool = false
    @AppStorage("MTL_HUD_ENABLED") var metalHUDEnabled: Bool = false
    
    @State private var showResolutionInfo = false
    @State private var searchText = ""
    
    var filteredMemoryModes: [(String, String)] {
        guard !searchText.isEmpty else { return memoryManagerModes }
        return memoryManagerModes.filter { $0.1.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        iOSNav {
            List {
                // Graphics & Performance
                Section {
                    Toggle(isOn: $config.fullscreen) {
                        labelWithIcon("Fullscreen", iconName: "rectangle.expand.vertical")
                    }
                    .tint(.blue)

                    Toggle(isOn: $config.disableShaderCache) {
                        labelWithIcon("Disable Shader Cache", iconName: "memorychip")
                    }
                    .tint(.blue)

                    Toggle(isOn: $config.enableTextureRecompression) {
                        labelWithIcon("Texture Recompression", iconName: "rectangle.compress.vertical")
                    }
                    .tint(.blue)

                    Toggle(isOn: $config.disableDockedMode) {
                        labelWithIcon("Disable Docked Mode", iconName: "dock.rectangle")
                    }
                    .tint(.blue)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            labelWithIcon("Resolution Scale", iconName: "magnifyingglass")
                                .font(.headline)
                            Spacer()
                            Button {
                                showResolutionInfo.toggle()
                            } label: {
                                Image(systemName: "info.circle")
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                            .help("Learn more about Resolution Scale")
                            .alert(isPresented: $showResolutionInfo) {
                                Alert(
                                    title: Text("Resolution Scale"),
                                    message: Text("Adjust the internal rendering resolution. Higher values improve visuals but may reduce performance."),
                                    dismissButton: .default(Text("OK"))
                                )
                            }
                        }

                        Slider(value: $config.resscale, in: 0.1...3.0, step: 0.1) {
                            Text("Resolution Scale")
                        } minimumValueLabel: {
                            Text("0.1x")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        } maximumValueLabel: {
                            Text("3.0x")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        Text("\(config.resscale, specifier: "%.2f")x")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)

                    Toggle(isOn: $metalHUDEnabled) {
                        labelWithIcon("Metal HUD", iconName: "speedometer")
                    }
                    .tint(.blue)
                    .onChange(of: metalHUDEnabled) { newValue in
                        // Preserves original functionality
                        if newValue {
                            MTLHud.shared.enable()
                        } else {
                            MTLHud.shared.disable()
                        }
                    }
                } header: {
                    Text("Graphics & Performance")
                        .font(.title3.weight(.semibold))
                        .textCase(nil)
                        .headerProminence(.increased)
                } footer: {
                    Text("Fine-tune graphics and performance to suit your device and preferences.")
                }
                
                // Input Selector
                Section {
                    ForEach(controllersList) { controller in
                        var customBinding: Binding<Bool> {
                            Binding(
                                get: { currentControllers.contains(controller) },
                                set: { bool in
                                    if !bool {
                                        currentControllers.removeAll(where: { $0.id == controller.id })
                                    } else {
                                        currentControllers.append(controller)
                                    }
                                    // toggleController(controller)
                                }
                            )
                        }
                        
                        Toggle(isOn: customBinding) {
                            labelWithIcon(controller.name, iconName: "")
                        }
                        .tint(.blue)
                    }
                } header: {
                    Text("Input Selector")
                        .font(.title3.weight(.semibold))
                        .textCase(nil)
                        .headerProminence(.increased)
                } footer: {
                    Text("Select input devices and on-screen controls to play with.")
                }

                // Input Settings
                Section {
                    
                    Toggle(isOn: $config.listinputids) {
                        labelWithIcon("List Input IDs", iconName: "list.bullet")
                    }
                    .tint(.blue)

                    Toggle(isOn: $ryuDemo) {
                        labelWithIcon("On-Screen Controller (Demo)", iconName: "hand.draw")
                    }
                    .tint(.blue)
                    .disabled(true)
                } header: {
                    Text("Input Settings")
                        .font(.title3.weight(.semibold))
                        .textCase(nil)
                        .headerProminence(.increased)
                } footer: {
                    Text("Configure input devices and on-screen controls for easier navigation and play.")
                }

                // Logging
                Section {
                    Toggle(isOn: $config.debuglogs) {
                        labelWithIcon("Debug Logs", iconName: "exclamationmark.bubble")
                    }
                    .tint(.blue)

                    Toggle(isOn: $config.tracelogs) {
                        labelWithIcon("Trace Logs", iconName: "waveform.path")
                    }
                    .tint(.blue)
                } header: {
                    Text("Logging")
                        .font(.title3.weight(.semibold))
                        .textCase(nil)
                        .headerProminence(.increased)
                } footer: {
                    Text("Enable logs for troubleshooting or keep them off for a cleaner experience.")
                }

                // CPU Mode
                Section {
                    if filteredMemoryModes.isEmpty {
                        Text("No matches for \"\(searchText)\"")
                            .foregroundColor(.secondary)
                    } else {
                        Picker(selection: $config.memoryManagerMode) {
                            ForEach(filteredMemoryModes, id: \.0) { key, displayName in
                                Text(displayName).tag(key)
                            }
                        } label: {
                            labelWithIcon("Memory Manager Mode", iconName: "gearshape")
                        }
                    }
                } header: {
                    Text("CPU Mode")
                        .font(.title3.weight(.semibold))
                        .textCase(nil)
                        .headerProminence(.increased)
                } footer: {
                    Text("Select how memory is managed. 'Host (fast)' is best for most users.")
                }

                // Advanced
                Section {
                    DisclosureGroup {
                        HStack {
                            labelWithIcon("Page Size", iconName: "textformat.size")
                            Spacer()
                            Text("\(String(Int(getpagesize())))")
                                .foregroundColor(.secondary)
                        }

                        TextField("Additional Arguments", text: Binding(
                            get: {
                                config.additionalArgs.joined(separator: ", ")
                            },
                            set: { newValue in
                                config.additionalArgs = newValue
                                    .split(separator: ",")
                                    .map { $0.trimmingCharacters(in: .whitespaces) }
                            }
                        ))
                        .textInputAutocapitalization(.none)
                        .disableAutocorrection(true)
                    } label: {
                        Text("Advanced Options")
                    }
                } header: {
                    Text("Advanced")
                        .font(.title3.weight(.semibold))
                        .textCase(nil)
                        .headerProminence(.increased)
                } footer: {
                    Text("For advanced users. See page size or add custom arguments for experimental features. (Please don't touch this if you don't know what you're doing)")
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.insetGrouped)
            .onAppear {
                if let configs = loadSettings() {
                    self.config = configs
                }
            }
            .onChange(of: config) { _ in
                saveSettings()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func toggleController(_ controller: Controller) {
        if currentControllers.contains(where: { $0.id == controller.id }) {
            currentControllers.removeAll(where: { $0.id == controller.id })
        } else {
            currentControllers.append(controller)
        }
    }
    
    func saveSettings() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(config)
            let jsonString = String(data: data, encoding: .utf8)
            UserDefaults.standard.set(jsonString, forKey: "config")
        } catch {
            print("Failed to save settings: \(error)")
        }
    }
    
    // Original loadSettings function assumed to exist
    func loadSettings() -> Ryujinx.Configuration? {
        guard let jsonString = UserDefaults.standard.string(forKey: "config"),
              let data = jsonString.data(using: .utf8) else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            let configs = try decoder.decode(Ryujinx.Configuration.self, from: data)
            return configs
        } catch {
            print("Failed to load settings: \(error)")
            return nil
        }
    }
    
    @ViewBuilder
    private func labelWithIcon(_ text: String, iconName: String) -> some View {
        HStack(spacing: 8) {
            if !iconName.isEmpty {
                Image(systemName: iconName)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.blue)
            }
            Text(text)
        }
        .font(.body)
    }
}
