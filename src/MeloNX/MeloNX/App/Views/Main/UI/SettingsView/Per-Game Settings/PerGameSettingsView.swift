//
//  PerGameSettingsView.swift
//  MeloNX
//
//  Created by Stossy11 on 12/06/2025.
//

import SwiftUI

protocol PerGameSettingsManaging: ObservableObject {
    var config: [String: Ryujinx.Arguments] { get set }
    
    func debouncedSave()
    func saveSettings()
    func loadSettings()
    
    static func loadSettings() -> [String: Ryujinx.Arguments]?
}



class PerGameSettingsManager: PerGameSettingsManaging {
    @Published var config: [String: Ryujinx.Arguments] {
        didSet {
            debouncedSave()
        }
    }
    
    private var saveWorkItem: DispatchWorkItem?
    
    public static var shared = PerGameSettingsManager()
    
    private init() {
        self.config = PerGameSettingsManager.loadSettings() ?? [:]
    }
    
    func debouncedSave() {
        saveWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.saveSettings()
        }
        
        saveWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }
    
    func saveSettings() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(config)
            
            let fileURL = URL.documentsDirectory.appendingPathComponent("config-pergame.json")
            
            try data.write(to: fileURL)
            print("Settings saved successfully")
        } catch {
            print("Failed to save settings: \(error)")
        }
    }
    
    static func loadSettings() -> [String: Ryujinx.Arguments]? {
        do {
            let fileURL = URL.documentsDirectory.appendingPathComponent("config-pergame.json")
            
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                print("Config file does not exist, creating new config")
                return nil
            }
            
            let data = try Data(contentsOf: fileURL)
            
            let decoder = JSONDecoder()
            let configs = try decoder.decode([String: Ryujinx.Arguments].self, from: data)
            return configs
        } catch {
            print("Failed to load settings: \(error)")
            return nil
        }
    }
    
    func loadSettings() {
        self.config = PerGameSettingsManager.loadSettings() ?? [:]
    }
}


struct PerGameSettingsView: View {
    
    @StateObject private var settingsManager: PerGameSettingsManager
    
    var titleId: String

    init(titleId: String, manager: any PerGameSettingsManaging = PerGameSettingsManager.shared) {
        self._settingsManager = StateObject(wrappedValue: manager as! PerGameSettingsManager)
        self.titleId = titleId 
    }
    
    
    private var config: Binding<Ryujinx.Arguments> {
        return Binding<Ryujinx.Arguments> {
            return settingsManager.config[titleId] ?? Ryujinx.Arguments()
        } set: { newValue in
            settingsManager.config[titleId] = newValue
            settingsManager.debouncedSave()
        }
    }
    
    var memoryManagerModes = [
        ("HostMapped", "Host (fast)"),
        ("HostMappedUnsafe", "Host Unchecked (fast, unstable / unsafe)"),
        ("SoftwarePageTable", "Software (slow)"),
    ]
    
    
    let totalMemory = ProcessInfo.processInfo.physicalMemory
    
    @State private var showResolutionInfo = false
    @State private var showAnisotropicInfo = false
    @State private var showControllerInfo = false
    @State private var showAppIconSwitcher = false
    @State private var searchText = ""
    @StateObject var ryujinx = Ryujinx.shared
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    @State private var selectedCategory: PerSettingsCategory = .graphics
    
    @StateObject var metalHudEnabler = MTLHud.shared
    
    var filteredMemoryModes: [(String, String)] {
        guard !searchText.isEmpty else { return memoryManagerModes }
        return memoryManagerModes.filter { $0.1.localizedCaseInsensitiveContains(searchText) }
    }
    
    var appVersion: String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "Unknown"
        }
        return version
    }
    
    @FocusState private var isArgumentsKeyboardVisible: Bool
    
    
    @State private var selectedView = "Data Management"
    @State private var sidebar = true
    
    enum PerSettingsCategory: String, CaseIterable, Identifiable {
        case graphics = "Graphics"
        case system = "System"
        case advanced = "Advanced"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .graphics: return "paintbrush.fill"
            case .system: return "gearshape.fill"
            case .advanced: return "terminal.fill"
            }
        }
    }
    
    var body: some View {
        iOSNav {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(PerSettingsCategory.allCases, id: \.id) { category in
                                CategoryButton(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    
                    Divider()
                    
                    // Settings content
                    ScrollView {
                        VStack(spacing: 24) {
                            switch selectedCategory {
                            case .graphics:
                                graphicsSettings
                                    .padding(.top)
                            case .system:
                                systemSettings
                                    .padding(.top)
                            case .advanced:
                                advancedSettings
                                    .padding(.top)

                            }
                            
                            Spacer(minLength: 50)
                        }
                        .padding(.bottom)
                    }
                    .scrollDismissesKeyboardIfAvailable()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        settingsManager.debouncedSave()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        dismiss()
                        settingsManager.config[titleId] = nil
                        settingsManager.saveSettings()
                    }
                }
            }
            // .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .onAppear {
                
                // if let configs = SettingsManager.loadSettings() {
                // settingsManager.loadSettings()
                // } else {
                // settingsManager.saveSettings()
                //}
                
                print(titleId)
                
                if settingsManager.config[titleId] == nil {
                    settingsManager.config[titleId] = Ryujinx.Arguments()
                    settingsManager.debouncedSave()
                }
            }
        }
    }

    // MARK: - Graphics Settings
    
    private var graphicsSettings: some View {
        SettingsSection(title: "Graphics & Performance") {
            // Resolution scale card
            SettingsCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        labelWithIcon("Resolution Scale", iconName: "magnifyingglass")
                            .font(.headline)
                        Spacer()
                        Button {
                            showResolutionInfo.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        .alert(isPresented: $showResolutionInfo) {
                            Alert(
                                title: Text("Resolution Scale"),
                                message: Text("Adjust the internal rendering resolution. Higher values improve visuals but may reduce performance."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                    
                    VStack(spacing: 8) {
                        Slider(value: config.resscale, in: 0.1...3.0, step: 0.05)
                        
                        HStack {
                            Text("0.1x")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(config.resscale.wrappedValue, specifier: "%.2f")x")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Text("3.0x")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Anisotropic filtering card
            SettingsCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        labelWithIcon("Max Anisotropic Filtering", iconName: "magnifyingglass")
                            .font(.headline)
                        Spacer()
                        Button {
                            showAnisotropicInfo.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        .alert(isPresented: $showAnisotropicInfo) {
                            Alert(
                                title: Text("Max Anisotropic Filtering"),
                                message: Text("Adjust the internal Anisotropic filtering. Higher values improve texture quality at angles but may reduce performance. Default at 0 lets game decide."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                    
                    VStack(spacing: 8) {
                        Slider(value: config.maxAnisotropy, in: 0...16.0, step: 0.1)
                        
                        HStack {
                            Text("Off")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(config.maxAnisotropy.wrappedValue, specifier: "%.1f")x")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Text("16x")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Toggle options card
            SettingsCard {
                VStack(spacing: 4) {
                    PerSettingsToggle(isOn: config.disableShaderCache, icon: "memorychip", label: "Shader Cache")
                    
                    Divider()
                    
                    PerSettingsToggle(isOn: config.disablevsync, icon: "arrow.triangle.2.circlepath", label: "Disable VSync")
                    
                    Divider()
                    
                    PerSettingsToggle(isOn: config.enableTextureRecompression, icon: "rectangle.compress.vertical", label: "Texture Recompression")
                    
                    Divider()
                    
                    PerSettingsToggle(isOn: config.disableDockedMode, icon: "dock.rectangle", label: "Docked Mode")
                    
                    Divider()
                    
                    PerSettingsToggle(isOn: config.macroHLE, icon: "gearshape", label: "Macro HLE")
                }
            }
            
            // Aspect ratio card
            SettingsCard {
                VStack(alignment: .leading, spacing: 12) {
                    labelWithIcon("Aspect Ratio", iconName: "rectangle.expand.vertical")
                        .font(.headline)
                    
                    if (horizontalSizeClass == .regular && verticalSizeClass == .regular) || (horizontalSizeClass == .regular && verticalSizeClass == .compact) {
                        Picker(selection: config.aspectRatio) {
                            ForEach(AspectRatio.allCases, id: \.self) { ratio in
                                Text(ratio.displayName).tag(ratio)
                            }
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.segmented)
                    } else {
                        Picker(selection: config.aspectRatio) {
                            ForEach(AspectRatio.allCases, id: \.self) { ratio in
                                Text(ratio.displayName).tag(ratio)
                            }
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
    
    
    // MARK: - System Settings
    
    private var systemSettings: some View {
        SettingsSection(title: "System Configuration") {
            // Language and region card
            SettingsCard {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        labelWithIcon("System Language", iconName: "character.bubble")
                            .font(.headline)
                        
                        Picker(selection: config.language) {
                            ForEach(SystemLanguage.allCases, id: \.self) { language in
                                Text(language.displayName).tag(language)
                            }
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        labelWithIcon("Region", iconName: "globe")
                            .font(.headline)
                        
                        Picker(selection: config.regioncode) {
                            ForEach(SystemRegionCode.allCases, id: \.self) { region in
                                Text(region.displayName).tag(region)
                            }
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                    }
                }
            }
            
            // CPU options card
            SettingsCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("CPU Configuration")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Memory Manager Mode")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker(selection: config.memoryManagerMode) {
                            ForEach(filteredMemoryModes, id: \.0) { key, displayName in
                                Text(displayName).tag(key)
                            }
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Divider()
                    
                    PerSettingsToggle(isOn: config.disablePTC, icon: "cpu", label: "Disable PTC")
                    
                    if let gpuInfo = getGPUInfo(), gpuInfo.hasPrefix("Apple M") {
                        Divider()
                        
                        if #available(iOS 16.4, *) {
                            PerSettingsToggle(isOn: .constant(false), icon: "bolt", label: "Hypervisor")
                                .disabled(true)
                        } else if checkAppEntitlement("com.apple.private.hypervisor") {
                            PerSettingsToggle(isOn: config.hypervisor, icon: "bolt", label: "Hypervisor")
                        }
                    }
                }
            }
            
            // Controller options card
            SettingsCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Controller Configuration")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    PerSettingsToggle(isOn: config.handHeldController, icon: "formfitting.gamecontroller", label: "Player 1 to Handheld")
    
                }
            }
        }
    }
    
    // MARK: - Advanced Settings
    
    private var advancedSettings: some View {
        SettingsSection(title: "Advanced Options") {
            // Debug options card
            SettingsCard {
                VStack(spacing: 4) {
                    PerSettingsToggle(isOn: config.debuglogs, icon: "exclamationmark.bubble", label: "Debug Logs")
                    
                    Divider()
                    
                    PerSettingsToggle(isOn: config.tracelogs, icon: "waveform.path", label: "Trace Logs")
                }
            }
            
            // Advanced toggles card
            SettingsCard {
                VStack(spacing: 4) {
                    
                    PerSettingsToggle(isOn: config.dfsIntegrityChecks, icon: "checkmark.shield", label: "Disable FS Integrity Checks")
                        .accentColor(.red)
                    
                    Divider()
                    
                    PerSettingsToggle(isOn: config.expandRam, icon: "exclamationmark.bubble", label: "Expand Guest RAM")
                        .accentColor(.red)
                        .disabled(totalMemory < 5723)
                    
                    Divider()
                    
                    PerSettingsToggle(isOn: config.ignoreMissingServices, icon: "waveform.path", label: "Ignore Missing Services")
                        .accentColor(.red)
                }
            }
            
            // Additional args card
            SettingsCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Additional Arguments")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    let binding = Binding(
                        get: {
                            config.additionalArgs.wrappedValue.joined(separator: ", ")
                        },
                        set: { newValue in
                            let args = newValue
                                .split(separator: ",")
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                            config.additionalArgs.wrappedValue = args
                        }
                    )
                    
                    
                    if #available(iOS 15.0, *) {
                        TextField("Separate arguments with commas", text: binding)
                            .font(.system(.body, design: .monospaced))
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.vertical, 4)
                            .toolbar {
                                ToolbarItem(placement: .keyboard) {
                                    Button("Dismiss") {
                                        isArgumentsKeyboardVisible = false
                                    }
                                }
                            }
                            .focused($isArgumentsKeyboardVisible)
                    } else {
                        TextField("Separate arguments with commas", text: binding)
                            .font(.system(.body, design: .monospaced))
                            .textFieldStyle(.roundedBorder)
                            .disableAutocorrection(true)
                            .padding(.vertical, 4)
                    }
                }
            }
            
            // Page size info card
            SettingsCard {
                HStack {
                    labelWithIcon("Page Size", iconName: "textformat.size")
                    Spacer()
                    Text("\(String(Int(getpagesize())))")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Miscellaneous Settings
    
    private var miscSettings: some View {
        SettingsSection(title: "Miscellaneous Options") {
            SettingsCard {
                VStack(spacing: 4) {
                    PerSettingsToggle(isOn: config.handHeldController, icon: "formfitting.gamecontroller", label: "Player 1 to Handheld")
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    
    func getGPUInfo() -> String? {
        let device = MTLCreateSystemDefaultDevice()
        return device?.name
    }
    
    @ViewBuilder
    private func labelWithIcon(_ text: String, iconName: String, flipimage: Bool? = nil) -> some View {
        HStack(spacing: 8) {
            if iconName.hasSuffix(".svg") {
                if let flipimage, flipimage {
                    SVGView(svgName: iconName, color: .blue)
                        // .symbolRenderingMode(.hierarchical)
                        .frame(width: 20, height: 20)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                } else {
                    SVGView(svgName: iconName, color: .blue)
                        // .symbolRenderingMode(.hierarchical)
                        .frame(width: 20, height: 20)
                }
            } else if !iconName.isEmpty {
                Image(systemName: iconName)
                    // .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.blue)
            }
            Text(text)
        }
        .font(.body)
    }
}


// MARK: - Supporting Views

// PerSettingsToggle(isOn: config.handHeldController, icon: "formfitting.gamecontroller", label: "Player 1 to Handheld")

struct PerSettingsCard<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("oldSettingsUI") var oldSettingsUI = false
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal)
    }
}

struct PerSettingsToggle: View {
    @Binding var isOn: Bool
    let icon: String
    let label: String
    var disabled: Bool = false
    @AppStorage("toggleGreen") var toggleGreen: Bool = false
    @AppStorage("oldSettingsUI") var oldSettingsUI = false
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 8) {
                if icon.hasSuffix(".svg") {
                    SVGView(svgName: icon, color: .blue)
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: icon)
                    // .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.blue)
                }
                
                Text(label)
                    .font(.body)
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .blue))
        .disabled(disabled)
        .padding(.vertical, 6)
    }
    
    func disabled(_ disabled: Bool) -> PerSettingsToggle {
        var view = self
        view.disabled = disabled
        return view
    }
    
    func accentColor(_ color: Color) -> PerSettingsToggle {
        var view = self
        return view
    }
}
