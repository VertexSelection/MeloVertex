//
//  SettingsView.swift
//  MeloNX
//
//  Created by Stossy11 on 25/11/2024.
//

import SwiftUI
import SwiftSVG

struct SettingsView: View {
    @Binding var config: Ryujinx.Configuration
    @Binding var MoltenVKSettings: [MoltenVKSettings]
    
    @Binding var controllersList: [Controller]
    @Binding var currentControllers: [Controller]
    
    @Binding var onscreencontroller: Controller
    @AppStorage("useTrollStore") var useTrollStore: Bool = false
    
    @AppStorage("jitStreamerEB") var jitStreamerEB: Bool = false
    @AppStorage("stikJIT") var stikJIT: Bool = false
    
    @AppStorage("ignoreJIT") var ignoreJIT: Bool = false
    
    var memoryManagerModes = [
        ("HostMapped", "Host (fast)"),
        ("HostMappedUnsafe", "Host Unchecked (fast, unstable / unsafe)"),
        ("SoftwarePageTable", "Software (slow)"),
    ]
    
    @AppStorage("RyuDemoControls") var ryuDemo: Bool = false
    @AppStorage("MTL_HUD_ENABLED") var metalHUDEnabled: Bool = false
    
    @AppStorage("showScreenShotButton") var ssb: Bool = false
    
    @AppStorage("MVK_CONFIG_PREFILL_METAL_COMMAND_BUFFERS") var mVKPreFillBuffer: Bool = false
    @AppStorage("MVK_CONFIG_SYNCHRONOUS_QUEUE_SUBMITS") var syncqsubmits: Bool = false
    
    @AppStorage("performacehud") var performacehud: Bool = false
    
    @AppStorage("swapBandA") var swapBandA: Bool = false
    
    @AppStorage("oldWindowCode") var windowCode: Bool = false
    
    @AppStorage("On-ScreenControllerScale") var controllerScale: Double = 1.0
    
    @AppStorage("hasbeenfinished") var finishedStorage: Bool = false
    
    @AppStorage("showlogsloading") var showlogsloading: Bool = true
    
    @AppStorage("showlogsgame") var showlogsgame: Bool = false
    
    @AppStorage("stick-button") var stickButton = false
    @AppStorage("waitForVPN") var waitForVPN = false
    
    @AppStorage("HideButtons") var hideButtonsJoy = false
    
    @AppStorage("checkForUpdate") var checkForUpdate: Bool = true
    
    @State private var showResolutionInfo = false
    @State private var showAnisotropicInfo = false
    @State private var showControllerInfo = false
    @State private var searchText = ""
    @AppStorage("portal") var gamepo = false
    @StateObject var ryujinx = Ryujinx.shared
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    @State private var selectedCategory: SettingsCategory = .graphics
    
    var filteredMemoryModes: [(String, String)] {
        guard !searchText.isEmpty else { return memoryManagerModes }
        return memoryManagerModes.filter { $0.1.localizedCaseInsensitiveContains(searchText) }
    }
    
    enum SettingsCategory: String, CaseIterable, Identifiable {
        case graphics = "Graphics"
        case input = "Input"
        case system = "System"
        case misc = "Misc"
        case advanced = "Advanced"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .graphics: return "paintbrush.fill"
            case .input: return "gamecontroller.fill"
            case .system: return "gearshape.fill"
            case .misc: return "ellipsis.circle.fill"
            case .advanced: return "terminal.fill"
            }
        }
    }
    
    var appVersion: String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "Unknown"
        }
        return version
    }
    
    @FocusState private var isArgumentsKeyboardVisible: Bool
    
    var body: some View {
        iOSNav {
            ZStack {
                // Background color
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Category selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(SettingsCategory.allCases, id: \.id) { category in
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
                            // Device Info Card
                            deviceInfoCard
                                .padding(.horizontal)
                                .padding(.top)
                            
                            switch selectedCategory {
                            case .graphics:
                                graphicsSettings
                            case .input:
                                inputSettings
                            case .system:
                                systemSettings
                            case .advanced:
                                advancedSettings
                            case .misc:
                                miscSettings
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
            // .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .onAppear {
                mVKPreFillBuffer = false
                
                if let configs = loadSettings() {
                    self.config = configs
                } else {
                    saveSettings()
                }
            }
            .onChange(of: config) { _ in
                saveSettings()
            }
        }
    }
    
    // MARK: - Device Info Card
    
    private var deviceInfoCard: some View {
        VStack(spacing: 16) {
            // JIT Status indicator
            HStack {
                Circle()
                    .fill(ryujinx.jitenabled ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                
                Text(ryujinx.jitenabled ? "JIT Enabled" : "JIT Not Acquired")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(ryujinx.jitenabled ? .green : .red)
                
                Spacer()
                
                let totalMemory = ProcessInfo.processInfo.physicalMemory
                let memoryText = ProcessInfo.processInfo.isiOSAppOnMac
                    ? String(format: "%.0f GB", Double(totalMemory) / (1024 * 1024 * 1024))
                    : String(format: "%.0f GB", Double(totalMemory) / 1_000_000_000)
                
                Text("\(memoryText) RAM")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("·")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Version \(appVersion)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Device cards
            if (horizontalSizeClass == .regular && verticalSizeClass == .regular) || (horizontalSizeClass == .regular && verticalSizeClass == .compact) {
                HStack(spacing: 16) {
                    InfoCard(
                        title: "Device",
                        value: UIDevice.modelName,
                        icon: deviceIcon,
                        color: .blue
                    )
                    
                    InfoCard(
                        title: "System",
                        value: "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
                        icon: "applelogo",
                        color: .gray
                    )
                    
                    InfoCard(
                        title: "Increased Memory Limit",
                        value: checkAppEntitlement("com.apple.developer.kernel.increased-memory-limit") ? "Enabled" : "Disabled",
                        icon: "memorychip.fill",
                        color: .orange
                    )
                }
            } else {
                VStack(spacing: 16) {
                    InfoCard(
                        title: "Device",
                        value: UIDevice.modelName,
                        icon: deviceIcon,
                        color: .blue
                    )
                    
                    InfoCard(
                        title: "System",
                        value: "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
                        icon: "applelogo",
                        color: .gray
                    )
                    
                    InfoCard(
                        title: "Increased Memory Limit",
                        value: checkAppEntitlement("com.apple.developer.kernel.increased-memory-limit") ? "Enabled" : "Disabled",
                        icon: "memorychip.fill",
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .onAppear {
            ryujinx.ryuIsJITEnabled()
        }
    }
    
    private var deviceIcon: String {
        let model = UIDevice.modelName
        if model.contains("iPad") {
            return "ipad"
        } else if model.contains("iPhone") {
            return "iphone"
        } else {
            return "desktopcomputer"
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
                        Slider(value: $config.resscale, in: 0.1...3.0, step: 0.05)
                        
                        HStack {
                            Text("0.1x")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(config.resscale, specifier: "%.2f")x")
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
                        Slider(value: $config.maxAnisotropy, in: 0...16.0, step: 0.1)
                        
                        HStack {
                            Text("Off")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(config.maxAnisotropy, specifier: "%.1f")x")
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
                    SettingsToggle(isOn: $config.disableShaderCache, icon: "memorychip", label: "Shader Cache")
                    
                    Divider()
                    
                    SettingsToggle(isOn: $config.disablevsync, icon: "arrow.triangle.2.circlepath", label: "Disable VSync")
                    
                    Divider()
                    
                    SettingsToggle(isOn: $config.enableTextureRecompression, icon: "rectangle.compress.vertical", label: "Texture Recompression")
                    
                    Divider()
                    
                    SettingsToggle(isOn: $config.disableDockedMode, icon: "dock.rectangle", label: "Docked Mode")
                    
                    Divider()
                    
                    SettingsToggle(isOn: $config.macroHLE, icon: "gearshape", label: "Macro HLE")
                    
                    Divider()
                    
                    SettingsToggle(isOn: $performacehud, icon: "speedometer", label: "Performance Overlay")
                }
            }
            
            // Aspect ratio card
            SettingsCard {
                VStack(alignment: .leading, spacing: 12) {
                    labelWithIcon("Aspect Ratio", iconName: "rectangle.expand.vertical")
                        .font(.headline)
                    
                    if (horizontalSizeClass == .regular && verticalSizeClass == .regular) || (horizontalSizeClass == .regular && verticalSizeClass == .compact) {
                        Picker(selection: $config.aspectRatio) {
                            ForEach(AspectRatio.allCases, id: \.self) { ratio in
                                Text(ratio.displayName).tag(ratio)
                            }
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.segmented)
                    } else {
                        Picker(selection: $config.aspectRatio) {
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
    
    // MARK: - Input Settings
    
    private var inputSettings: some View {
        SettingsSection(title: "Input Configuration") {
            // Controller selection card
            SettingsCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Controller Selection")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if currentControllers.isEmpty {
                        emptyControllersView
                    } else {
                        controllerListView
                    }
                    
                    if hasAvailableControllers {
                        Divider()
                        addControllerButton
                    }
                }
            }
            
            // On-screen controls card
            SettingsCard {
                VStack(spacing: 4) {
                    SettingsToggle(isOn: $config.handHeldController, icon: "formfitting.gamecontroller", label: "Player 1 to Handheld")
                    
                    Divider()
                    
                    SettingsToggle(isOn: $stickButton, icon: "l.joystick.press.down", label: "Show Stick Buttons")
                    
                    Divider()
                    
                    SettingsToggle(isOn: $ryuDemo, icon: "hand.draw", label: "On-Screen Controller (Demo)")
                        .disabled(true)
                    
                    Divider()
                    
                    SettingsToggle(isOn: $swapBandA, icon: "rectangle.2.swap", label: "Swap Face Buttons (Physical Controller)")
                }
            }
            
            // Controller scale card
            SettingsCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        labelWithIcon("On-Screen Controller Scale", iconName: "magnifyingglass")
                            .font(.headline)
                        Spacer()
                        Button {
                            showControllerInfo.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        .alert(isPresented: $showControllerInfo) {
                            Alert(
                                title: Text("On-Screen Controller Scale"),
                                message: Text("Adjust the On-Screen Controller size."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                    
                    VStack(spacing: 8) {
                        Slider(value: $controllerScale, in: 0.1...3.0, step: 0.05)
                        
                        HStack {
                            Text("Smaller")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(controllerScale, specifier: "%.2f")x")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Text("Larger")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Controller Selection Components

    private var hasAvailableControllers: Bool {
        !controllersList.filter { !currentControllers.contains($0) }.isEmpty
    }

    private var emptyControllersView: some View {
        HStack {
            Text("No controllers selected (Keyboard will be used)")
                .foregroundColor(.secondary)
                .italic()
            Spacer()
        }
        .padding(.vertical, 8)
    }

    private var controllerListView: some View {
        VStack(spacing: 0) {
            Divider()
            
            ForEach(currentControllers.indices, id: \.self) { index in
                let controller = currentControllers[index]
                
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "gamecontroller.fill")
                            .foregroundColor(.blue)
                        
                        Text("Player \(index + 1): \(controller.name)")
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Button {
                            toggleController(controller)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 8)
                    
                    if index < currentControllers.count - 1 {
                        Divider()
                    }
                }
            }
            .onMove { from, to in
                currentControllers.move(fromOffsets: from, toOffset: to)
            }
            .environment(\.editMode, .constant(.active))
        }
    }

    private var addControllerButton: some View {
        Menu {
            ForEach(controllersList.filter { !currentControllers.contains($0) }) { controller in
                Button {
                    currentControllers.append(controller)
                } label: {
                    Text(controller.name)
                }
            }
        } label: {
            Label("Add Controller", systemImage: "plus.circle.fill")
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 6)
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
                        
                        Picker(selection: $config.language) {
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
                        
                        Picker(selection: $config.regioncode) {
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
                        
                        Picker(selection: $config.memoryManagerMode) {
                            ForEach(filteredMemoryModes, id: \.0) { key, displayName in
                                Text(displayName).tag(key)
                            }
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Divider()
                    
                    SettingsToggle(isOn: $config.disablePTC, icon: "cpu", label: "Disable PTC")
                    
                    if let gpuInfo = getGPUInfo(), gpuInfo.hasPrefix("Apple M") {
                        Divider()
                        
                        if #available(iOS 16.4, *) {
                            SettingsToggle(isOn: .constant(false), icon: "bolt", label: "Hypervisor")
                                .disabled(true)
                        } else if checkAppEntitlement("com.apple.private.hypervisor") {
                            SettingsToggle(isOn: $config.hypervisor, icon: "bolt", label: "Hypervisor")
                        }
                    }
                }
            }
            
            // Memory hacks card
            SettingsCard {
                VStack(spacing: 4) {
                    SettingsToggle(isOn: $config.expandRam, icon: "exclamationmark.bubble", label: "Expand Guest RAM (6GB)")
                        .accentColor(.red)
                    
                    Divider()
                    
                    SettingsToggle(isOn: $config.ignoreMissingServices, icon: "waveform.path", label: "Ignore Missing Services")
                        .accentColor(.red)
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
                    SettingsToggle(isOn: $showlogsloading, icon: "text.alignleft", label: "Show Logs While Loading")
                    
                    Divider()
                    
                    SettingsToggle(isOn: $showlogsgame, icon: "text.magnifyingglass", label: "Show Logs In-Game")
                    
                    Divider()
                    
                    SettingsToggle(isOn: $config.debuglogs, icon: "exclamationmark.bubble", label: "Debug Logs")
                    
                    Divider()
                    
                    SettingsToggle(isOn: $config.tracelogs, icon: "waveform.path", label: "Trace Logs")
                }
            }
            
            // Advanced toggles card
            SettingsCard {
                VStack(spacing: 4) {
                    SettingsToggle(isOn: $config.dfsIntegrityChecks, icon: "checkmark.shield", label: "Disable FS Integrity Checks")
                    
                    Divider()
                    
                    if MTLHud.shared.canMetalHud {
                        SettingsToggle(isOn: $metalHUDEnabled, icon: "speedometer", label: "Metal Performance HUD")
                            .onChange(of: metalHUDEnabled) { newValue in
                                MTLHud.shared.toggle()
                            }
                        
                        Divider()
                    }
                    
                    SettingsToggle(isOn: $ignoreJIT, icon: "cpu", label: "Ignore JIT Popup")
                    
                    Divider()
                    
                    Button {
                        finishedStorage = false
                    } label: {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                .foregroundColor(.blue)
                            Text("Show Setup Screen")
                                .foregroundColor(.blue)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            
            // Additional args card
            SettingsCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Additional Arguments")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if #available(iOS 15.0, *) {
                        TextField("Separate arguments with commas" ,text: Binding(
                            get: {
                                config.additionalArgs.joined(separator: ", ")
                            },
                            set: { newValue in
                                config.additionalArgs = newValue
                                    .split(separator: ",")
                                    .map { $0.trimmingCharacters(in: .whitespaces) }
                            }
                        ))
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
                        TextField("Separate arguments with commas", text: Binding(
                            get: {
                                config.additionalArgs.joined(separator: ", ")
                            },
                            set: { newValue in
                                config.additionalArgs = newValue
                                    .split(separator: ",")
                                    .map { $0.trimmingCharacters(in: .whitespaces) }
                            }
                        ))
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
            
            if gamepo {
                SettingsCard {
                    Text("The cake is a lie")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
    
    // MARK: - Miscellaneous Settings
    
    private var miscSettings: some View {
        SettingsSection(title: "Miscellaneous Options") {
            SettingsCard {
                VStack(spacing: 4) {
                    // Screenshot button card
                    SettingsToggle(isOn: $ssb, icon: "square.and.arrow.up", label: "Screenshot Button")
                    
                    Divider()
                    
                    // JIT options
                    if #available(iOS 17.0.1, *) {
                        SettingsToggle(isOn: $stikJIT, icon: "bolt.heart", label: "StikJIT")
                            .contextMenu {
                                Button {
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let mainWindow = windowScene.windows.last {
                                        let alertController = UIAlertController(title: "About StikJIT", message: "StikJIT is a really amazing iOS Application to Enable JIT on the go on-device, made by the best, most kind, helpful and nice developers of all time jkcoxson and Blu <3", preferredStyle: .alert)
                                        
                                        let learnMoreButton = UIAlertAction(title: "Learn More", style: .default) {_ in
                                            UIApplication.shared.open(URL(string: "https://github.com/0-Blu/StikJIT")!)
                                        }
                                        alertController.addAction(learnMoreButton)
                                        
                                        let doneButton = UIAlertAction(title: "Done", style: .cancel, handler: nil)
                                        alertController.addAction(doneButton)
                                        
                                        mainWindow.rootViewController?.present(alertController, animated: true)
                                    }
                                } label: {
                                    Text("About")
                                }
                            }
                    } else {
                        SettingsToggle(isOn: $useTrollStore, icon: "troll.svg", label: "TrollStore JIT")
                    }
                    
                    Divider()
                    
                    // MoltenVK Options
                    SettingsToggle(isOn: $syncqsubmits, icon: "line.diagonal", label: "MVK: Synchronous Queue Submits")
                        .contextMenu {
                            Button {
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let mainWindow = windowScene.windows.last {
                                    let alertController = UIAlertController(title: "About MVK: Synchronous Queue Submits", message: "Enable this option if Mario Kart 8 is crashing at Grand Prix mode.", preferredStyle: .alert)
                                    
                                    let doneButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                    alertController.addAction(doneButton)
                                    
                                    mainWindow.rootViewController?.present(alertController, animated: true)
                                }
                            } label: {
                                Text("About")
                            }
                        }
                    
                    Divider()
                    
                    SettingsToggle(isOn: $checkForUpdate, icon: "square.and.arrow.down", label: "Check for Updates")
                    
                    if ryujinx.firmwareversion != "0" {
                        Divider()
                        Button {
                            Ryujinx.shared.removeFirmware()
                        } label: {
                            HStack {
                                Text("Remove Firmware")
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func toggleController(_ controller: Controller) {
        if currentControllers.contains(where: { $0.id == controller.id }) {
            currentControllers.removeAll(where: { $0.id == controller.id })
        } else {
            currentControllers.append(controller)
        }
    }
    
    func saveSettings() {
        MeloNX.saveSettings(config: config)
    }
    
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

struct SVGView: UIViewRepresentable {
    var svgName: String
    var color: Color = Color.black
    
    func makeUIView(context: Context) -> UIView {
        var svgName = svgName
        let hammock = UIView()
        
        if svgName.hasSuffix(".svg") {
            svgName.removeLast(4)
        }
        
        
        
        _ = UIView(svgNamed: svgName) { svgLayer in
            svgLayer.fillColor = UIColor(color).cgColor // Apply the provided color
            svgLayer.resizeToFit(hammock.frame)
            hammock.layer.addSublayer(svgLayer)
        }
        
        return hammock
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the SVG view's fill color when the color changes
        if let svgLayer = uiView.layer.sublayers?.first as? CAShapeLayer {
            svgLayer.fillColor = UIColor(color).cgColor
        }
    }
}

func saveSettings(config: Ryujinx.Configuration) {
    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(config)
        
        let fileURL = URL.documentsDirectory.appendingPathComponent("config.json")
        
        try data.write(to: fileURL)
        // print("Settings saved to: \(fileURL.path)")
    } catch {
        // print("Failed to save settings: \(error)")
    }
}

func loadSettings() -> Ryujinx.Configuration? {
    do {
        let fileURL = URL.documentsDirectory.appendingPathComponent("config.json")
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // print("Config file does not exist at: \(fileURL.path)")
            return nil
        }
        
        let data = try Data(contentsOf: fileURL)
        
        let decoder = JSONDecoder()
        let configs = try decoder.decode(Ryujinx.Configuration.self, from: data)
        return configs
    } catch {
        // print("Failed to load settings: \(error)")
        return nil
    }
}


// MARK: - Supporting Views

struct CategoryButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                Text(title)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? .blue : .secondary)
            .frame(width: 70, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.15) : Color.clear)
            )
            .animation(.bouncy(duration: 0.3), value: isSelected)
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2.weight(.bold))
                .padding(.horizontal)
            
            content
        }
    }
}

struct SettingsCard<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
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

struct SettingsToggle: View {
    let isOn: Binding<Bool>
    let icon: String
    let label: String
    var disabled: Bool = false
    
    var body: some View {
        Toggle(isOn: isOn) {
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
    
    func disabled(_ disabled: Bool) -> SettingsToggle {
        var view = self
        view.disabled = disabled
        return view
    }
    
    func accentColor(_ color: Color) -> SettingsToggle {
        var view = self
        return view
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// this code is used to enable the keyboard to be dismissed when scrolling if available on iOS 16+
extension View {
    @ViewBuilder
    func scrollDismissesKeyboardIfAvailable() -> some View {
        if #available(iOS 16.0, *) {
            self.scrollDismissesKeyboard(.interactively)
        } else {
            self
        }
    }
}

