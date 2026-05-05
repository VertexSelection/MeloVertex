//
//  SettingsView.swift
//  MeloNX
//
//  Created by Stossy11 on 25/11/2024.
//

import SwiftUI
import SwiftSVG
import UIKit


struct SettingsViewNew: View {
    @ObservedObject public var settingsManager = SettingsManager.shared
    @ObservedObject public var nativeSettingsManager = NativeSettingsManager.shared
    @ObservedObject var controllerManager = ControllerManager.shared
    @EnvironmentObject var ryujinx: Ryujinx
    @StateObject var metalHudEnabler = MTLHud.shared
    
    @AppStorage("useTrollStore") var useTrollStore: Bool = false
    @AppStorage("OldView") var oldView = true
    @AppStorage("LDN_MITM") var ldn = printAllIPv4Addresses().first ?? "Unknown"
    @AppStorage("portal") var gamepo = false
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    @State private var selectedCategory: SettingsCategory = .graphics
    @State private var showResolutionInfo = false
    @State private var showAnisotropicInfo = false
    @State private var showControllerInfo = false
    @State private var showAppIconSwitcher = false
    @State private var showBackgroundMusicSelector = false
    @State private var isShowingGameController = false
    @State private var searchText = ""
    @State private var selectedView = "Data Management"
    @State private var sidebar = true
    @FocusState private var isArgumentsKeyboardVisible: Bool
    
    private var config: Binding<Ryujinx.Arguments> {
        $settingsManager.config
    }
    
    private let memoryManagerModes = [
        ("HostMapped", "Host (fast)"),
        ("HostMappedUnsafe", "Host Unchecked (fast, unstable / unsafe)"),
        ("SoftwarePageTable", "Software (slow)"),
    ]
    
    private let totalMemory = ProcessInfo.processInfo.physicalMemory
    
    private var filteredMemoryModes: [(String, String)] {
        guard !searchText.isEmpty else { return memoryManagerModes }
        return memoryManagerModes.filter { $0.1.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private var isRegularLayout: Bool {
        (horizontalSizeClass == .regular && verticalSizeClass == .regular) ||
        (horizontalSizeClass == .regular && verticalSizeClass == .compact)
    }
    
    private var deviceIcon: String {
        let model = UIDevice.modelName
        if model.contains("iPad") { return "ipad" }
        if model.contains("iPhone") { return "iphone" }
        return "desktopcomputer"
    }
    
    private var memoryText: String {
        let divisor = ProcessInfo.processInfo.isiOSAppOnMac ? (1024 * 1024 * 1024) : 1_000_000_000
        return String(format: "%.0f GB", Double(totalMemory) / Double(divisor))
    }
    
    private var systemVersionString: LocalizedStringKey {
        let versionPart = ProcessInfo.processInfo.operatingSystemVersionString
            .replacingOccurrences(of: "Version ", with: "")
        let parts = versionPart.components(separatedBy: " (Build ")
        
        if parts.count == 2 {
            let version = parts[0]
            let build = parts[1].replacingOccurrences(of: ")", with: "")
            let osName = ProcessInfo.processInfo.isiOSAppOnMac ? "macOS" : UIDevice.current.systemName
            return "\(osName) \(version) (\(build))"
        }
        
        let osName = ProcessInfo.processInfo.isiOSAppOnMac ? "macOS" : UIDevice.current.systemName
        return "\(osName) \(UIDevice.current.systemVersion)"
    }
    
    
    enum SettingsCategory: LocalizedStringKey, CaseIterable, Identifiable {
        case graphics = "Graphics"
        case input = "Input"
        case misc = "Misc"
        case system = "System"
        case advanced = "Advanced"
        
        var id: String { "\(rawValue)" }
        
        var icon: String {
            switch self {
            case .graphics: return "paintbrush.fill"
            case .input: return "gamecontroller.fill"
            case .system: return "gearshape.fill"
            case .misc: return "ellipsis.circle.fill"
            case .advanced: return "terminal.fill"
            }
        }
        
        @ViewBuilder
        func view(for parent: SettingsViewNew) -> some View {
            switch self {
            case .graphics: parent.graphicsSettings
            case .misc: parent.miscSettings
            case .input: parent.inputSettings
            case .system: parent.systemSettings
            case .advanced: parent.advancedSettings
            }
        }
    }
    
    // i keep loosing where it is so i added MARK fr
    // MARK: - Body
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            iOSSettings
        } else if !nativeSettingsManager.oldSettingsUI.value {
            iPadOSSettings
                .ignoresSafeArea()
                .edgesIgnoringSafeArea(.all)
        } else {
            iOSSettings
        }
    }
    
    var allBody: some View {
        ZStack {
            graphicsSettings
            miscSettings
            inputSettings
            systemSettings
            advancedSettings
        }
        .frame(width: 2, height: 2)
    }
    
    // MARK: - iPadOS Layout
    
    var iPadOSSettings: some View {
        VStack {
            SidebarView(
                sidebar: { AnyView(sidebarContent) },
                content: {
                    ScrollView {
                        selectedCategory.view(for: self)
                    }
                },
                showSidebar: $sidebar
            )
            .onAppear(perform: loadSettings)
        }
    }
    
    private var sidebarContent: some View {
        ScrollView(.vertical) {
            VStack {
                sidebarHeaderSection
                
                Divider()
                
                sidebarCategoryList
            }
            .padding()
        }
    }
    
    private var sidebarHeaderSection: some View {
        VStack(spacing: 16) {
            HStack {
                jitStatusIndicator
                
                if isInLiveContainer.0, isInLiveContainer.1 == nil {
                    Text("LiveContainer")
                        .font(.system(size: 14))
                        .foregroundColor(.indigo)
                }
                
                Spacer()
                
                Text("v\(appVersion)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(memoryText) RAM")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }
            
            deviceInfoCards
        }
        .padding()
    }
    
    private var sidebarCategoryList: some View {
        ForEach(SettingsCategory.allCases, id: \.id) { category in
            CategoryRow(
                category: category,
                isSelected: selectedCategory == category
            ) {
                withAnimation(.smooth) {
                    selectedCategory = category
                }
            }
        }
    }
    
    // MARK: - iOS Layout
    
    var iOSSettings: some View {
        iOSNav {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    categoryScrollView
                    Divider()
                    
                    ScrollView(.vertical) {
                        VStack(spacing: 24) {
                            deviceInfoCard
                                .padding(.horizontal)
                                .padding(.top)
                            
                            selectedCategory.view(for: self)
                                .frame(maxWidth: UIScreen.main.bounds.width)
                            
                            Spacer(minLength: 50)
                        }
                        .padding(.bottom)
                    }
                    .scrollDismissesKeyboardIfAvailable()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear(perform: loadSettings)
        }
    }
    
    private var categoryScrollView: some View {
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
    }
    
    
    private var jitStatusIndicator: some View {
        HStack {
            Circle()
                .fill(ryujinx.jitenabled ? Color.green : Color.red)
                .frame(width: 12, height: 12)
            
            if ProcessInfo.processInfo.isiOSAppOnMac && !checkAppEntitlement("get-task-allow") {
                Text("JIT Enabled (macOS)")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(ryujinx.jitenabled ? .green : .red)
            } else {
                if !checkAppEntitlement("get-task-allow") &&
                    !checkAppEntitlement("com.apple.security.cs.allow-jit") &&
                    !checkAppEntitlement("dynamic-codesigning") &&
                    !ryujinx.jitenabled {
                    Text("No JIT Support. (no get-task-allow)")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.red)
                } else {
                    Text(ryujinx.jitenabled ? "JIT Enabled" : "JIT Not Acquired")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(ryujinx.jitenabled ? .green : .red)
                }
            }
        }
    }
    
    @ViewBuilder
    private var deviceInfoCards: some View {
        InfoCard(
            title: "Device",
            value: "\(UIDevice.modelName)",
            icon: deviceIcon,
            color: .blue
        )
        
        InfoCard(
            title: "System",
            value: systemVersionString,
            icon: "applelogo",
            color: .gray
        )
        
        if ProcessInfo.processInfo.isiOSAppOnMac {
            InfoCard(
                title: "Increased Memory Limit",
                value: "Not needed (macOS)",
                icon: "memorychip.fill",
                color: .orange
            )
        } else {
            InfoCard(
                title: "Increased Memory Limit",
                value: checkAppEntitlement("com.apple.developer.kernel.increased-memory-limit") ? "Enabled" : "Disabled",
                icon: "memorychip.fill",
                color: .orange
            )
            
            if checkAppEntitlement("com.apple.developer.kernel.extended-virtual-addressing") {
                InfoCard(
                    title: "Extended Virtual Addressing",
                    value: "Enabled",
                    icon: "memorychip",
                    color: .yellow
                )
            }
            
            if let lc = isInLiveContainer.1, !isInLiveContainer.2 {
                InfoCard(
                    title: "LiveContainer",
                    value: "v\(lc.infoDictionary?["CFBundleShortVersionString"] as? String ?? (lc.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")) \(lc.infoDictionary?["LCVersionInfo"] as? String ?? "")",
                    icon: "app.fill",
                    color: .indigo
                )
            } else if isInLiveContainer.2 {
                InfoCard(
                    title: "LiveContainer",
                    value: "Multitask",
                    icon: "app.fill",
                    color: .indigo
                )
            }
        }
    }
    
    private var deviceInfoCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack {
                    HStack {
                        jitStatusIndicator
                        if isInLiveContainer.0, isInLiveContainer.1 == nil {
                            Spacer()
                        }
                    }
                    if isInLiveContainer.0, isInLiveContainer.1 == nil {
                        HStack {
                            Text("Installed With LiveContainer")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.cyan)
                            Spacer()
                        }
                    }
                }
                Spacer()
                
                Text("\(memoryText) RAM")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("·")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if ProcessInfo.processInfo.isiOSAppOnMac {
                    Text("macOS \(ProcessInfo.processInfo.operatingSystemVersionString)")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                    Text("·")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("Version \(appVersion)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if isRegularLayout {
                HStack(spacing: 16) { deviceInfoCards }
            } else {
                VStack(spacing: 16) { deviceInfoCards }
            }
        }
        .padding()
        .liquidGlass(cornerRadius: 16) {
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .onAppear {
            ryujinx.checkForJIT()
        }
    }
    
    // MARK: - Graphics Settings
    
    private var graphicsSettings: some View {
        SettingsSection(title: "Graphics & Performance") {
            resolutionScaleCard
            anisotropicFilteringCard
            graphicsTogglesCard
            performanceOverlayCard
            aspectRatioCard
        }
    }
    
    // StackOverflow to the rescue fr
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    private var resolutionScaleCard: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    labelWithIcon("Resolution Scale", iconName: "magnifyingglass")
                        .font(.headline)
                    Spacer()
                    InfoButton(
                        title: "Resolution Scale",
                        message: "Lowering this is unsupported for some games and may cause crashing. Adjust the internal rendering resolution. Higher values improve visuals but may reduce performance.",
                        isPresented: $showResolutionInfo
                    )
                }
                
                if nativeSettingsManager.allowCustomResValue.value {
                    TextField("Resolution Scale", value: config.resscale, formatter: Self.formatter)
                        .keyboardType(.numberPad)
                } else {
                    sliderWithLabels(
                        value: config.resscale,
                        range: 0.1...3.0,
                        step: 0.05,
                        currentValue: settingsManager.config.resscale,
                        minLabel: "0.1x",
                        maxLabel: "3.0x"
                    )
                }
            }
            .contextMenu {
                Button("Allow Any Resolution Scale" + (nativeSettingsManager.allowCustomResValue.value ? "  ✓" : "")) {
                    if nativeSettingsManager.allowCustomResValue.value {
                        nativeSettingsManager.allowCustomResValue.value = false
                    } else { nativeSettingsManager.allowCustomResValue.value = true }
                }
            }
        }
    }
    
    private var anisotropicFilteringCard: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    labelWithIcon("Max Anisotropic Filtering", iconName: "magnifyingglass")
                        .font(.headline)
                    Spacer()
                    InfoButton(
                        title: "Max Anisotropic Filtering",
                        message: "Adjust the internal Anisotropic filtering. Higher values improve texture quality at angles but may reduce performance. Default at 0 lets game decide.",
                        isPresented: $showAnisotropicInfo
                    )
                }
                
                sliderWithLabels(
                    value: config.maxAnisotropy,
                    range: 0...16.0,
                    step: 0.1,
                    currentValue: settingsManager.config.maxAnisotropy,
                    minLabel: "Off",
                    maxLabel: "16x",
                    format: "%.1f"
                )
            }
        }
    }
    
    private var graphicsTogglesCard: some View {
        SettingsCard {
            VStack(spacing: 4) {
                SettingsToggle(isOn: config.enableShaderCache, icon: "memorychip", label: "Shader Cache", infoMessage: "Shader Cache saves shaders to a file and preloads them on game install. This should be enabled on devices with 8GB+ RAM.\n\nLeave OFF if unsure.")
                Divider()
                SettingsToggle(isOn: config.disablevsync.reversed, icon: "arrow.triangle.2.circlepath", label: "VSync", infoMessage: "VSync makes the game try to run at the Switch's Framerate, If you disable this it will cause the game to run at your device screen refresh rate. Which can would cause games to run at higher speed or make loading screens take longer or get stuck.\n\nLeave ON if unsure.")
                Divider()
                SettingsToggle(isOn: config.enableDockedMode, icon: "dock.rectangle", label: "Docked Mode", infoMessage: "Docked mode makes the emulated system behave as a docked Nintendo Switch. This improves graphical fidelity in most games. Conversely, disabling this will make the emulated system behave as a handheld Nintendo Switch, reducing graphics quality but improving performance.\n\nLeave OFF if unsure.")
                Divider()
                SettingsToggle(isOn: config.macroHLE, icon: "gearshape", label: "Macro HLE", infoMessage: "High-level emulation of GPU Macro code.\n\nImproves performance, but may cause graphical glitches in some games.\n\nLeave OFF if unsure.")
            }
        }
    }
    
    private var performanceOverlayCard: some View {
        SettingsCard {
            VStack(spacing: 4) {
                SettingsToggle(isOn: nativeSettingsManager.performacehud.projectedValue, icon: "speedometer", label: "Performance Overlay", infoMessage: "Gives performance information (Framerate, FPS, Optional Battery) while game is running via an overlay.")
                
                if nativeSettingsManager.performacehud.value {
                    Divider()
                    SettingsToggle(isOn: nativeSettingsManager.showBatteryPercentage.projectedValue, icon: "battery.100percent.bolt", label: "Show Battery Percentage", infoMessage: "Shows Battery Percentage in the Performance Overlay")
                }
                
                Divider()
                SettingsToggle(isOn: nativeSettingsManager.horizontalorvertical.projectedValue, icon: "rotate.right", label: "Horizontal Performance Overlay", infoMessage: "Changes the look of the Performance Overlay to be Horizontal instead of Vertical.")
            }
        }
    }
    
    private var aspectRatioCard: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 12) {
                // SettingsToggle(isOn: $oldView, icon: "rectangle.on.rectangle.dashed", label: "Old Display UI")
                // Divider()
                
                labelWithIcon("Aspect Ratio", iconName: "rectangle.expand.vertical")
                    .font(.headline)
                
                    Picker(selection: config.aspectRatio) {
                        ForEach(AspectRatio.allCases, id: \.self) { ratio in
                            Text(ratio.displayName).tag(ratio)
                        }
                    } label: {
                        EmptyView()
                    }
                    .if(!isRegularLayout) { view in
                        view.frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                            .pickerStyle(.menu)
                    }
                    .if(isRegularLayout) { view in
                        view.pickerStyle(.segmented)
                    }
                    .onAppear() {
                        oldView = true
                    }
            }
        }
    }
    
    // MARK: - Input Settings
    
    private var inputSettings: some View {
        SettingsSection(title: "Input Configuration") {
            controllerSelectionCard
            controllerTogglesCard
            onScreenControllerCard
        }
    }
    
    private var controllerSelectionCard: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Controller Selection")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if controllerManager.allControllers.isEmpty {
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
    }
    
    private var controllerTogglesCard: some View {
        SettingsCard {
            SettingsToggle(isOn: nativeSettingsManager.swapBandA.projectedValue, icon: "rectangle.2.swap", label: "Swap Face Buttons (Physical Controller)", infoMessage: "Swaps buttons on ALL Physical Controller (A <-> B, X <-> Y), If you would like to only do 1 physical controller, consult the native Settings app.")
        }
    }
    
    private var onScreenControllerCard: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Global On-Screen Controller Configuration")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Button {
                    isShowingGameController = true
                } label: {
                    HStack {
                        Image(systemName: "formfitting.gamecontroller")
                            .foregroundColor(.blue)
                        Text("On-Screen Controller Layout")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal)
                .fullScreenCover(isPresented: $isShowingGameController) {
                    ControllerView(isEditing: $isShowingGameController, gameId: nil)
                }
                
                Divider().padding(.horizontal)
                
                controllerScaleSection
                Divider()
                controllerOpacitySection
                Divider()
                
                SettingsToggle(isOn: nativeSettingsManager.stickButton.projectedValue, icon: "l.joystick.press.down", label: "Show Stick Buttons", infoMessage: "Shows L3 and R3 (Left Joystick and Right Joystick buttons) on the Virtual Controller.")
                Divider()
                SettingsToggle(isOn: nativeSettingsManager.virtualControllerOffDefault(ProcessInfo.processInfo.isiOSAppOnMac).projectedValue, icon: "formfitting.gamecontroller.fill", label: "Deselected By Default (Virtual Controller)", infoMessage: "Deselects the Virtual Controller by Default whether you have a physical controller connected or not.")
            }
        }
    }
    
    private var controllerScaleSection: some View {
        Group {
            HStack {
                labelWithIcon("Scale", iconName: "magnifyingglass")
                    .font(.headline)
                Spacer()
                InfoButton(
                    title: "On-Screen Controller Scale",
                    message: "Adjust the Global On-Screen Controller size.",
                    isPresented: $showControllerInfo
                )
            }
            
            sliderWithLabels(
                value: nativeSettingsManager.setting(forKey: "On-ScreenControllerScale", default: 1.0).projectedValue,
                range: 0.1...3.0,
                step: 0.05,
                currentValue: nativeSettingsManager.setting(forKey: "On-ScreenControllerScale", default: 1.0).value,
                minLabel: "Smaller",
                maxLabel: "Larger"
            )
        }
        .padding(.horizontal)
    }
    
    private var controllerOpacitySection: some View {
        Group {
            HStack {
                labelWithIcon("Opacity", iconName: "magnifyingglass")
                    .font(.headline)
                Spacer()
                InfoButton(
                    title: "On-Screen Controller Opacity",
                    message: "Adjust the Global On-Screen Controller transparency.",
                    isPresented: $showControllerInfo
                )
            }
            
            sliderWithLabels(
                value: nativeSettingsManager.setting(forKey: "On-ScreenControllerOpacity", default: 1.0).projectedValue,
                range: 0.05...1.0,
                step: 0.05,
                currentValue: nativeSettingsManager.setting(forKey: "On-ScreenControllerOpacity", default: 1.0).value,
                minLabel: "More Transparent",
                maxLabel: "Less Transparent"
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Controller List
    
    private var hasAvailableControllers: Bool {
        !ControllerManager.shared.allControllers
            .filter { !contains(ControllerManager.shared.selectedControllers, value: $0) }
            .isEmpty
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
            
            ForEach(Array(controllerManager.selectedControllers.enumerated()), id: \.offset) { index, id in
                ControllerRow(
                    index: index,
                    controllerId: id,
                    controllerManager: controllerManager
                )
            }
            .onAppear {
                setupControllerTypes()
            }
        }
    }
    
    private var addControllerButton: some View {
        Menu {
            ForEach(controllerManager.allControllers.filter({ !contains(controllerManager.selectedControllers, value: $0) })) { controller in
                Button {
                    controllerManager.selectedControllers.append(controller.id)
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
    
    private func setupControllerTypes() {
        for (index, controllerId) in ControllerManager.shared.selectedControllers.enumerated() {
            let (controller, idx) = controllerManager.controllerAndIndexForString(controllerId)!
            let defaultType: ControllerType = controller.virtual ? .joyconPair : .proController
            ControllerManager.shared.allControllers[idx].type = ControllerManager.shared.controllerTypes[index] ?? defaultType
        }
    }
    
    func contains(_ array: [String], value: BaseController) -> Bool {
        array.contains { $0 == value.id }
    }
    
    // MARK: - System Settings
    
    private var systemSettings: some View {
        SettingsSection(title: "System Configuration") {
            languageRegionCard
            cpuConfigCard
        }
    }
    
    private var languageRegionCard: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    labelWithIcon("System Language", iconName: "character.bubble")
                        .font(.headline)
                    
                    pickerView(
                        selection: config.language,
                        options: SystemLanguage.self,
                        displayName: \.displayName
                    )
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    labelWithIcon("Region", iconName: "globe")
                        .font(.headline)
                    
                    pickerView(
                        selection: config.regioncode,
                        options: SystemRegionCode.self,
                        displayName: \.displayName
                    )
                }
            }
        }
    }
    
    private var cpuConfigCard: some View {
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
                SettingsToggle(isOn: config.disablePTC.reversed, icon: "cpu", label: "PTC", infoMessage: "Saves translated JIT functions so that they do not need to be translated every time the game loads.\n\nReduces stuttering and significantly speeds up boot times after the first boot of a game.\n\nLeave ON if unsure.")
            }
        }
    }
    
    // MARK: - Advanced Settings
    
    private var advancedSettings: some View {
        SettingsSection(title: "Advanced Options") {
            debugOptionsCard
            advancedTogglesCard
            memoryHacksCard
            additionalArgsCard
            systemInfoCard
            memorialCard
        }
    }
    
    private var debugOptionsCard: some View {
        SettingsCard {
            VStack(spacing: 4) {
                SettingsToggle(isOn: nativeSettingsManager.showlogsloading.projectedValue, icon: "text.alignleft", label: "Show Logs While Loading", infoMessage: "Shows Logs while the game is loading.")
                Divider()
                SettingsToggle(isOn: nativeSettingsManager.showlogsgame.projectedValue, icon: "text.magnifyingglass", label: "Show Logs In-Game", infoMessage: "Shows Logs after the game has finished loading.")
                Divider()
                SettingsToggle(isOn: nativeSettingsManager.showFullLogs.projectedValue, icon: "waveform.path", label: "Show Full Logs", infoMessage: "Shows all Logs instead of ones only from the core.")
                Divider()
                SettingsToggle(isOn: config.debuglogs, icon: "exclamationmark.bubble", label: "Debug Logs", infoMessage: "Prints debug log messages in the console.\n\nOnly use this if specifically instructed by a staff member, as it will make logs difficult to read and worsen emulator performance.")
                Divider()
                SettingsToggle(isOn: config.tracelogs, icon: "waveform.path", label: "Trace Logs", infoMessage: "Prints trace log messages in the console. Does not affect performance.")
            }
        }
    }
    
    @AppStorage("hasbeenfinished") var inSetup: Bool = true
    
    private var advancedTogglesCard: some View {
        SettingsCard {
            VStack(spacing: 4) {
                SettingsToggle(isOn: config.dfsIntegrityChecks, icon: "checkmark.shield", label: "Disable FS Integrity Checks", infoMessage: "Checks for corrupt files when booting a game, and if corrupt files are detected, displays a hash error in the log.\n\nHas no impact on performance and is meant to help troubleshooting.\n\nLeave OFF if unsure.")
                Divider()
                
                if MTLHud.shared.canMetalHud {
                    SettingsToggle(isOn: $metalHudEnabler.metalHudEnabled, icon: "speedometer", label: "Metal Performance HUD", infoMessage: "Shows Apple's Metal Performance overlay with frame rate and GPU usage while the game runs.")
                    Divider()
                }
                
                SettingsToggle(isOn: nativeSettingsManager.ignoreJIT.projectedValue, icon: "cpu", label: "Ignore JIT Popup", infoMessage: "Ignores the JIT popup and tries to load the game reguardless.")
                Divider()
                
                SettingsToggle(isOn: nativeSettingsManager.mainThreadWatchdog(true).projectedValue, icon: "clock.badge.exclamationmark", label: "Enables Main Thread Watchdog", infoMessage: "Meant to help troubleshooting.\n\nLeave ON if unsure.")
                Divider()
                
                Button {
                    inSetup = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                            .foregroundColor(.blue)
                        Text("Show Setup Screen")
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding(8)
                }
            }
        }
    }
    
    private var memoryHacksCard: some View {
        SettingsCard {
            VStack(spacing: 4) {
                SettingsToggle(isOn: config.expandRam, icon: "exclamationmark.bubble", label: "Expand Guest RAM", infoMessage: "Utilizes an alternative memory mode with 8GiB of DRAM to mimic a Switch development model.\n\nThis is only useful for higher-resolution texture packs or 4k resolution mods. Does NOT improve performance.\n\nLeave OFF if unsure.")
                    .accentColor(.red)
                    .disabled(totalMemory < 5723)
                Divider()
                SettingsToggle(isOn: config.ignoreMissingServices, icon: "waveform.path", label: "Ignore Missing Services", infoMessage: "Ignores unimplemented Horizon OS services. This may help in bypassing crashes when booting certain games.\n\nLeave OFF if unsure.")
                    .accentColor(.red)
            }
        }
    }
    
    private var additionalArgsCard: some View {
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
                        settingsManager.config.additionalArgs = newValue
                            .split(separator: ",")
                            .map { $0.trimmingCharacters(in: .whitespaces) }
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
    }
    
    private var systemInfoCard: some View {
        SettingsCard {
            HStack {
                labelWithIcon("Page Size", iconName: "textformat.size")
                Spacer()
                Text("\(String(Int(getpagesize())))")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            
            HStack {
                let res = (UIApplication.shared.connectedScenes.first! as! UIWindowScene).windows.first!.bounds.size
                labelWithIcon("App Resolution", iconName: "display")
                Spacer()
                Text("\(Int(res.width))x\(Int(res.height))")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var memorialCard: some View {
        SettingsCard {
            if gamepo {
                Text("The cake is a lie")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    // MARK: - Miscellaneous Settings
    
    private var miscSettings: some View {
        SettingsSection(title: "Miscellaneous Options") {
            customRomFoldersCard
            networkConfigCard
            uiTogglesCard
            jitAndMiscCard
        }
    }
    
    private var customRomFoldersCard: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Custom ROM folders")
                    .font(.headline)
                    .foregroundColor(.primary)
                FolderListView()
            }
        }
    }
    
    private var networkConfigCard: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Network Configuration")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    labelWithIcon("Network Interface", iconName: "wifi")
                        .font(.headline)
                    
                    Picker(selection: $ldn) {
                        ForEach(printAllIPv4Addresses(), id: \.self) { option in
                            Text(option)
                        }
                    } label: {
                        EmptyView()
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                }
                
                Divider()
                SettingsToggle(isOn: config.enableInternet, icon: "wifi.router.fill", label: "Guest Internet Access / LAN Mode", infoMessage: "Allows the emulated application to connect to the Internet.\n\nGames with a LAN mode can connect to each other when this is enabled and the systems are connected to the same access point. This includes real consoles as well.\n\nDoes NOT allow connecting to Nintendo servers. May cause crashing in certain games that try to connect to the Internet.\n\nLeave OFF if unsure.")
                Divider()
                SettingsToggle(isOn: config.ldn_mitm, icon: "ipad.sizes", label: "ldn_mitm", infoMessage: "ldn_mitm will modify local wireless/local play functionality in games to function as if it were LAN, allowing for local, same-network connections with other Ryujinx instances and hacked Nintendo Switch consoles that have the ldn_mitm module installed.\n\nMultiplayer requires all players to be on the same game version (i.e. Super Smash Bros. Ultimate v13.0.1 can't connect to v13.0.0).\n\nLeave OFF if unsure.")
            }
        }
    }
    
    private var uiTogglesCard: some View {
        SettingsCard {
            VStack(spacing: 4) {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    SettingsToggle(isOn: nativeSettingsManager.toggleGreen.projectedValue, icon: "arrow.clockwise", label: "Toggle Color Green when \"ON\"", infoMessage: "Makes all options that were enabled the color Green")
                    Divider()
                }
                
                SettingsToggle(isOn: nativeSettingsManager.disableTouch.projectedValue, icon: "rectangle.and.hand.point.up.left.filled", label: "Disable Touch", infoMessage: "Disables the touch screen (Not Virtual Controller)")
                Divider()
                
                if #available(iOS 19, *) {
                    SettingsToggle(isOn: nativeSettingsManager.disableLiquidGlass.projectedValue, icon: "rectangle.slash", label: "Disable Liquid Glass", infoMessage: "Disables Liquid Glass in the settings menu and in the Library View.")
                    Divider()
                }
                
                
                VStack(alignment: .leading, spacing: 12) {
                    labelWithIcon("Library View", iconName: "list.bullet")
                        .font(.headline)
                    
                    Picker(selection: nativeSettingsManager.cardLayout(CardType.card).projectedValue) {
                        ForEach(CardType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    } label: {
                        EmptyView()
                    }
                    .if(!isRegularLayout) { view in
                        view.frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                            .pickerStyle(.menu)
                    }
                    .if(isRegularLayout) { view in
                        view.pickerStyle(.segmented)
                    }
                }
                
                Divider()
                
                SettingsToggle(isOn: nativeSettingsManager.showProfileonGame.projectedValue, icon: "person.3", label: "Select Profile on Game Launch", infoMessage: "Shows up a popup that allows you to select a profile when you launch a game.")
                Divider()
                
                Button {
                    showAppIconSwitcher = true
                } label: {
                    HStack {
                        Image(systemName: "app.dashed")
                            .foregroundColor(.blue)
                        Text("App Icon Switcher")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal)
                .sheet(isPresented: $showAppIconSwitcher) {
                    AppIconSwitcherView()
                }
                
                Divider()
                
                Button {
                    showBackgroundMusicSelector = true
                } label: {
                    HStack {
                        Image(systemName: "music.note.list")
                            .foregroundColor(.blue)
                        Text("Background Music")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal)
                .sheet(isPresented: $showBackgroundMusicSelector) {
                    MusicSelectorView()
                }
                
                Divider()
                SettingsToggle(isOn: nativeSettingsManager.showScreenShotButton(true).projectedValue, icon: "arrow.left.circle", label: "Menu Button (in-game)", infoMessage: "Shows a manu button in-game that allows you to Exit the current game (Unstable), Lock Orientation (iPhones Only), Change Aspect Ratio, Change Controllers.")
                Divider()
                SettingsToggle(isOn: nativeSettingsManager.setting(forKey: "location-enabled", default: false).projectedValue, icon: "location.viewfinder", label: "Keep app in background", infoMessage: "Uses Location to keep the app in the background. does NOT keep any data or track anything whatsoever.")
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Divider()
                    SettingsToggle(isOn: nativeSettingsManager.oldSettingsUI.projectedValue, icon: "ipad.landscape", label: "Non Switch-like Settings", infoMessage: "Changes the Settings UI to resemble a Nintendo Switch.")
                }
            }
        }
    }
    
    private var jitAndMiscCard: some View {
        SettingsCard {
            VStack(spacing: 4) {
                jitToggleView
                Divider()
                
                // SettingsToggle(isOn: nativeSettingsManager.setting(forKey: "MVK_CONFIG_SYNCHRONOUS_QUEUE_SUBMITS", default: true).projectedValue, icon: "line.diagonal", label: "MVK: Synchronous Queue Submits", infoMessage: "This option may help if Mario Kart 8 is crashing at Grand Prix mode.")
                // Divider()
                
                
                let model = UIDevice.modelName
                
                if !model.contains("Mac") || !ProcessInfo.processInfo.isiOSAppOnMac {
                    if #available(iOS 19, *) {
                        SettingsToggle(isOn: .constant(true), icon: "light.strip.2", label: "Dual Mapped JIT", infoMessage: "iOS 26 JIT.")
                            .disabled(true)
                    } else {
                        SettingsToggle(isOn: nativeSettingsManager.setting(forKey: "DUAL_MAPPED_JIT", default: false).projectedValue, icon: "light.strip.2", label: "Dual Mapped JIT", infoMessage: "iOS 26 / Non-TXM JIT.")
                            .disabled(ProcessInfo.processInfo.hasTXM)
                    }
                } else {
                    SettingsToggle(isOn: nativeSettingsManager.setting(forKey: "DUAL_MAPPED_JIT", default: false).projectedValue, icon: "light.strip.2", label: "Dual Mapped JIT", infoMessage: "iOS 26 JIT")
                }
                
                Divider()
                SettingsToggle(isOn: nativeSettingsManager.checkForUpdate(true).projectedValue, icon: "square.and.arrow.down", label: "Check for Updates", infoMessage: "Check for Updates on Launch")
                Divider()
                
                Button {
                    Ryujinx.clearShaderCache()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.blue)
                        Text("Clear All Shader Cache")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var jitToggleView: some View {
        Group {
            if #available(iOS 17.0.1, *) {
                let checked = stikJITorStikDebug()
                let stikJIT = checked == 1 ? "StikDebug" : checked == 2 ? "StikJIT" : "StikDebug"
                SettingsToggle(isOn: nativeSettingsManager.stikJIT(isInLiveContainer.0).projectedValue, icon: "bolt.heart", label: "\(stikJIT)", infoMessage: "\(stikJIT) is an app used to Enable JIT on the go on-device, made by jkcoxson and Blu")
            } else {
                SettingsToggle(isOn: $useTrollStore, icon: "troll.svg", label: "TrollStore JIT", infoMessage: "Enables JIT automatically using TrollStore's URL Scheme ('apple-magnifier://enable-jit?bundle-id')")
            }
        }
    }
    
    
    @ViewBuilder
    private func labelWithIcon(_ text: String, iconName: String, flipimage: Bool? = nil) -> some View {
        HStack(spacing: 8) {
            if iconName.hasSuffix(".svg") {
                if let flipimage, flipimage {
                    SVGView(svgName: iconName, color: .blue)
                        .frame(width: 20, height: 20)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                } else {
                    SVGView(svgName: iconName, color: .blue)
                        .frame(width: 20, height: 20)
                }
            } else if !iconName.isEmpty {
                Image(systemName: iconName)
                    .foregroundColor(.blue)
            }
            Text(text)
        }
        .font(.body)
    }
    
    
    private func sliderWithLabels(
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        currentValue: Double,
        minLabel: String,
        maxLabel: String,
        format: String = "%.2f"
    ) -> some View {
        VStack(spacing: 8) {
            if nativeSettingsManager.disableLiquidGlass.value {
                Pre26Slider(value: value, range: range, step: step)
            } else {
                Slider(value: value, in: range, step: step)
            }
            
            HStack {
                Text(minLabel)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(String(format: format, currentValue))x")
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
                Text(maxLabel)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func pickerView<T: Hashable & CaseIterable>(
        selection: Binding<T>,
        options: T.Type,
        displayName: KeyPath<T, String>
    ) -> some View {
        Picker(selection: selection) {
            ForEach(Array(options.allCases), id: \.self) { option in
                Text(option[keyPath: displayName]).tag(option)
            }
        } label: {
            EmptyView()
        }
        .pickerStyle(.menu)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
    
    
    private func loadSettings() {
        if let _ = SettingsManager.loadSettings() {
            settingsManager.loadSettings()
        } else {
            settingsManager.saveSettings()
        }
    }
    
    private func getGPUInfo() -> String? {
        MTLCreateSystemDefaultDevice()?.name
    }
    
    private func showAlert(title: String, message: String, learnMoreURL: String? = nil) {
        guard let mainWindow = AppDelegate.window else { return }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let urlString = learnMoreURL, let url = URL(string: urlString) {
            let learnMoreButton = UIAlertAction(title: "Learn More", style: .default) { _ in
                UIApplication.shared.open(url)
            }
            alertController.addAction(learnMoreButton)
        }
        
        let doneButton = UIAlertAction(title: learnMoreURL != nil ? "Done" : "OK", style: .cancel)
        alertController.addAction(doneButton)
        
        mainWindow.rootViewController?.present(alertController, animated: true)
    }
}


extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
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

func saveSettings(config: Ryujinx.Arguments) {
    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(config)
        
        let fileURL = URL.documentsDirectory.appendingPathComponent("config.json")
        
        try data.write(to: fileURL)
    } catch {
    }
}

func loadSettings() -> Ryujinx.Arguments? {
    do {
        let fileURL = URL.documentsDirectory.appendingPathComponent("config.json")
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            saveSettings(config: Ryujinx.Arguments())
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return loadSettings()
            }
            
            return nil
        }
        
        let data = try Data(contentsOf: fileURL)
        
        let decoder = JSONDecoder()
        let configs = try decoder.decode(Ryujinx.Arguments.self, from: data)
        return configs
    } catch {
        return nil
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

// seperate view for testing™
// this became perm. whoops
struct FolderListView: View {
    @StateObject private var folderManager = ROMFolderManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            ForEach(folderManager.bookmarks, id: \.self) { path in
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.blue)
                        
                        Text(folderManager.getUrl(from: path)?.lastPathComponent ?? "Unknown")
                            .lineLimit(1)
                            .truncationMode(.middle)
                        
                        Spacer()
                        
                        Button {
                            folderManager.bookmarks.removeAll(where: { $0 == path })
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 8)
                    
                    if path != folderManager.bookmarks.last {
                        Divider()
                    }
                }
            }
            
            Button(action: {
                FileImporterManager.shared.importFiles(types: [.folder]) { result in
                    switch result {
                    case .success(let paths):
                        for url in paths {
                            let wow = folderManager.addFolder(url: url)
                            print(wow)
                            Ryujinx.shared.games = Ryujinx.shared.loadGames()
                        }
                    case .failure:
                        break
                    }
                }
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Folder")
                }
                .padding(.vertical, 10)
            }
        }
        .padding(.horizontal)
    }
    
}


func printAllIPv4Addresses() -> [String] {
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    
    var cool: [String] = []

    guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
        print("Failed to get network interfaces")
        return []
    }

    var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr
    while ptr != nil {
        let interface = ptr!.pointee
        let name = String(cString: interface.ifa_name)

        if let addr = interface.ifa_addr, addr.pointee.sa_family == UInt8(AF_INET) {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            let addrLen = socklen_t(addr.pointee.sa_len)

            let result = getnameinfo(
                addr,
                addrLen,
                &hostname,
                socklen_t(hostname.count),
                nil,
                0,
                NI_NUMERICHOST
            )

            if result == 0 {
                let address = String(cString: hostname)
                print("\(name): \(address)")
                if !cool.contains(where: { $0.contains(address) }), address != "127.0.0.1" {
                    cool.append("\(name): \(address)")
                }
            } else {
                print("\(name): Address lookup failed (\(result))")
            }
        }

        ptr = interface.ifa_next
    }

    freeifaddrs(ifaddr)
    
    if cool.contains(where: { $0.contains("en0") }) {
        let indexToMove = cool.firstIndex(where: { $0.contains("en0") }) ?? 0
        if indexToMove < cool.count && indexToMove != 0 {
            let element = cool.remove(at: indexToMove)
            cool.insert(element, at: 0)
        }
    }
    
    return cool
}
