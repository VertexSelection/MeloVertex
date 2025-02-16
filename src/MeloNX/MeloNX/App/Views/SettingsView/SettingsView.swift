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
    
    @AppStorage("oldWindowCode") var windowCode: Bool = false
    
    @AppStorage("On-ScreenControllerScale") var controllerScale: Double = 1.0
    
    @State private var showResolutionInfo = false
    @State private var showAnisotropicInfo = false
    @State private var showControllerInfo = false
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
                    Picker(selection: $config.aspectRatio) {
                        ForEach(AspectRatio.allCases, id: \.self) { ratio in
                            Text(ratio.displayName).tag(ratio)
                        }
                    } label: {
                        labelWithIcon("Aspect Ratio", iconName: "rectangle.expand.vertical")
                    }
                    .tint(.blue)
                    
                    Toggle(isOn: $config.disableShaderCache) {
                        labelWithIcon("Shader Cache", iconName: "memorychip")
                    }
                    .tint(.blue)
                    
                    Toggle(isOn: $config.disablevsync) {
                        labelWithIcon("Disable VSync", iconName: "arrow.triangle.2.circlepath")
                    }
                    .tint(.blue)
                    
                    
                    Toggle(isOn: $config.enableTextureRecompression) {
                        labelWithIcon("Texture Recompression", iconName: "rectangle.compress.vertical")
                    }
                    .tint(.blue)
                    
                    Toggle(isOn: $config.disableDockedMode) {
                        labelWithIcon("Docked Mode", iconName: "dock.rectangle")
                    }
                    .tint(.blue)
                    
                    Toggle(isOn: $config.macroHLE) {
                        labelWithIcon("Macro HLE", iconName: "gearshape")
                    }.tint(.blue)
                        
                    
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
                        
                        Slider(value: $config.resscale, in: 0.1...3.0, step: 0.05) {
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
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            labelWithIcon("Max Anisotropic Scale", iconName: "magnifyingglass")
                                .font(.headline)
                            Spacer()
                            Button {
                                showAnisotropicInfo.toggle()
                            } label: {
                                Image(systemName: "info.circle")
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                            .help("Learn more about Max Anisotropic Scale")
                            .alert(isPresented: $showAnisotropicInfo) {
                                Alert(
                                    title: Text("Max Anisotripic Scale"),
                                    message: Text("Adjust the internal Anisotropic resolution. Higher values improve visuals but may reduce performance. Default at 0 lets game decide."),
                                    dismissButton: .default(Text("OK"))
                                )
                            }
                        }

                        Slider(value: $config.maxAnisotropy, in: 0...16.0, step: 0.1) {
                            Text("Resolution Scale")
                        } minimumValueLabel: {
                            Text("0x")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        } maximumValueLabel: {
                            Text("16.0x")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        Text("\(config.maxAnisotropy, specifier: "%.2f")x")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)

                    Toggle(isOn: $performacehud) {
                        labelWithIcon("Performance Overlay", iconName: "speedometer")
                    }
                    .tint(.blue)
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
                    if !controllersList.filter({ !currentControllers.contains($0) }).isEmpty {
                        DisclosureGroup("Unselected Controllers") {
                            ForEach(controllersList.filter { !currentControllers.contains($0) }) { controller in
                                var customBinding: Binding<Bool> {
                                    Binding(
                                        get: { currentControllers.contains(controller) },
                                        set: { bool in
                                            if !bool {
                                                currentControllers.removeAll(where: { $0.id == controller.id })
                                            } else {
                                                currentControllers.append(controller)
                                            }
                                        }
                                    )
                                }
                                
                                Toggle(isOn: customBinding) {
                                    Text(controller.name)
                                        .font(.body)
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    
                    
                    
                    ForEach(currentControllers) { controller in
                        
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
                        
                        
                        if customBinding.wrappedValue {
                            DisclosureGroup {
                                Toggle(isOn: customBinding) {
                                    Text(controller.name)
                                        .font(.body)
                                }
                                .tint(.blue)
                                .onDrag({ NSItemProvider() })
                            } label: {
                                
                                if let controller = currentControllers.firstIndex(where: { $0.id == controller.id } )  {
                                    Text("Player \(controller + 1)")
                                        .onAppear() {
                                            // print(currentControllers.firstIndex(where: { $0.id == controller.id }) ?? 0)
                                            print(currentControllers.count)
                                            
                                            if currentControllers.count > 2 {
                                                print(currentControllers[1])
                                                print(currentControllers[2])
                                            }
                                        }
                                }
                            }
                            
                        }
                    }
                    .onMove { from, to in
                        currentControllers.move(fromOffsets: from, toOffset: to)
                    }
                } header: {
                    Text("Input Selector")
                        .font(.title3.weight(.semibold))
                        .textCase(nil)
                        .headerProminence(.increased)
                } footer: {
                    Text("Select input devices and on-screen controls to play with. ")
                }
                
                // Language and Region Settings
                Section {
                    Picker(selection: $config.language) {
                        ForEach(SystemLanguage.allCases, id: \.self) { ratio in
                            Text(ratio.displayName).tag(ratio)
                        }
                    } label: {
                        labelWithIcon("Language", iconName: "character.bubble")
                    }
                    
                    Picker(selection: $config.regioncode) {
                        ForEach(SystemRegionCode.allCases, id: \.self) { ratio in
                            Text(ratio.displayName).tag(ratio)
                        }
                    } label: {
                        labelWithIcon("Region", iconName: "globe")
                    }
                    
                    
                    // globe
                } header: {
                    Text("Language and Region Settings")
                        .font(.title3.weight(.semibold))
                        .textCase(nil)
                        .headerProminence(.increased)
                } footer: {
                    Text("Configure the System Language and the Region.")
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
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            labelWithIcon("On-Screen Controller Scale", iconName: "magnifyingglass")
                                .font(.headline)
                            Spacer()
                            Button {
                                showControllerInfo.toggle()
                            } label: {
                                Image(systemName: "info.circle")
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                            .help("Learn more about On-Screen Controller Scale")
                            .alert(isPresented: $showControllerInfo) {
                                Alert(
                                    title: Text("On-Screen Controller Scale"),
                                    message: Text("Adjust the On-Screen Controller size."),
                                    dismissButton: .default(Text("OK"))
                                )
                            }
                        }
                        
                        Slider(value: $controllerScale, in: 0.1...3.0, step: 0.05) {
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
                        Text("\(controllerScale, specifier: "%.2f")x")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Input Settings")
                        .font(.title3.weight(.semibold))
                        .textCase(nil)
                        .headerProminence(.increased)
                } footer: {
                    Text("Configure input devices and on-screen controls for easier navigation and play.")
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
                    
                    Toggle(isOn: $config.disablePTC) {
                        labelWithIcon("Disable PTC", iconName: "cpu")
                    }.tint(.blue)
                    
                    if let cpuInfo = getCPUInfo(), cpuInfo.hasPrefix("Apple M") {
                        if #available (iOS 16.4, *) {
                            Toggle(isOn: .constant(false)) {
                                labelWithIcon("Hypervisor", iconName: "bolt.fill")
                            }
                            .tint(.blue)
                            .disabled(true)
                            .onAppear() {
                                print("CPU Info: \(cpuInfo)")
                            }
                        } else if getEntitlementValue("com.apple.private.hypervisor") {
                            Toggle(isOn: $config.hypervisor) {
                                labelWithIcon("Hypervisor", iconName: "bolt.fill")
                            }
                            .tint(.blue)
                            .onAppear() {
                                print("CPU Info: \(cpuInfo)")
                            }
                        }
                    }
                } header: {
                    Text("CPU")
                        .font(.title3.weight(.semibold))
                        .textCase(nil)
                        .headerProminence(.increased)
                } footer: {
                    Text("Select how memory is managed. 'Host (fast)' is best for most users.")
                }

            
            Section {
                
                
                Toggle(isOn: $config.expandRam) {
                    labelWithIcon("Expand Guest Ram (6GB)", iconName: "exclamationmark.bubble")
                }
                .tint(.red)

                Toggle(isOn: $config.ignoreMissingServices) {
                    labelWithIcon("Ignore Missing Services", iconName: "waveform.path")
                }
                .tint(.red)
            } header: {
                Text("Hacks")
                    .font(.title3.weight(.semibold))
                    .textCase(nil)
                    .headerProminence(.increased)
            }

                // Other Settings
                Section {
                    
                    Toggle(isOn: $ssb) {
                        labelWithIcon("Screenshot Button", iconName: "square.and.arrow.up")
                    }
                    .tint(.blue)
                    
                    if #available(iOS 17.0.1, *) {
                        Toggle(isOn: $jitStreamerEB) {
                            labelWithIcon("JitStreamer EB", iconName: "bolt.heart")
                        }
                        .tint(.blue)
                        .contextMenu {
                            Button {
                                if let mainWindow = UIApplication.shared.windows.last {
                                    let alertController = UIAlertController(title: "About JitStreamer EB", message: "JitStreamer EB is an Amazing Application to Enable JIT on the go, made by one of the best iOS developers of all time jkcoxson <3", preferredStyle: .alert)
                                    
                                    let learnMoreButton = UIAlertAction(title: "Learn More", style: .default) {_ in
                                        UIApplication.shared.open(URL(string: "https://jkcoxson.com/jitstreamer")!)
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
                        Toggle(isOn: $useTrollStore) {
                            labelWithIcon("TrollStore JIT", iconName: "troll.svg")
                        }
                        .tint(.blue)
                    }
                    
                    Toggle(isOn: $syncqsubmits) {
                        labelWithIcon("MVK: Synchronous Queue Submits", iconName: "line.diagonal")
                    }.tint(.blue)
                        .contextMenu() {
                            Button {
                                if let mainWindow = UIApplication.shared.windows.last {
                                    let alertController = UIAlertController(title: "About MVK: Synchronous Queue Submits", message: "Enable this option if Mario Kart 8 is crashing at Grand Prix mode.", preferredStyle: .alert)
                                    
                                    let doneButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                    alertController.addAction(doneButton)
                                    
                                    mainWindow.rootViewController?.present(alertController, animated: true)
                                }
                            } label: {
                                Text("About")
                            }
                        }
                    
                    DisclosureGroup {
                        Toggle(isOn: $config.debuglogs) {
                            labelWithIcon("Debug Logs", iconName: "exclamationmark.bubble")
                        }
                        .tint(.blue)
                        
                        Toggle(isOn: $config.tracelogs) {
                            labelWithIcon("Trace Logs", iconName: "waveform.path")
                        }
                        .tint(.blue)
                    } label: {
                        Text("Logs")
                    }
                    
                } header: {
                    Text("Miscellaneous Options")
                        .font(.title3.weight(.semibold))
                        .textCase(nil)
                        .headerProminence(.increased)
                } footer: {
                    Text("Enable trace and debug logs for advanced troubleshooting (Note: This degrades performance),\nEnable Screenshot Button for better screenshots\nand Enable TrollStore for automatic TrollStore JIT.")
                }
                
                // Advanced
                Section {
                    labelWithIcon("JIT Acquisition: \(isJITEnabled() ? "Acquired" : "Not Acquired" )", iconName: "bolt.fill")
                    
                    if #unavailable(iOS 17) {
                        Toggle(isOn: $windowCode) {
                            labelWithIcon("SDL Window", iconName: "macwindow.on.rectangle")
                        }
                        .tint(.blue)
                    }
                    
                    DisclosureGroup {
                        
                        Toggle(isOn: $mVKPreFillBuffer) {
                            labelWithIcon("MVK: Pre-Fill Metal Command Buffers", iconName: "gearshape")
                        }.tint(.blue)
                        
                        Toggle(isOn: $config.dfsIntegrityChecks) {
                            labelWithIcon("Disable FS Integrity Checks", iconName: "checkmark.shield")
                        }.tint(.blue)
                        
                        HStack {
                            labelWithIcon("Page Size", iconName: "textformat.size")
                            Spacer()
                            Text("\(String(Int(getpagesize())))")
                                .foregroundColor(.secondary)
                            
                        }
                        
                        TextField("Additional Arguments", text: Binding(
                            get: {
                                config.additionalArgs.joined(separator: " ")
                            },
                            set: { newValue in
                                config.additionalArgs = newValue
                                    .split(separator: ",")
                                    .map { $0.trimmingCharacters(in: .whitespaces) }
                            }
                        ))
                        .textInputAutocapitalization(.none)
                        .disableAutocorrection(true)
                        
                        
                        Button {
                            Ryujinx.shared.removeFirmware()
                            
                        } label: {
                            Text("Remove Firmware")
                                .font(.body)
                        }
                        
                        
                    } label: {
                        Text("Advanced Options")
                    }
                } header: {
                    Text("Advanced")
                        .font(.title3.weight(.semibold))
                        .textCase(nil)
                        .headerProminence(.increased)
                } footer: {
                    if #available(iOS 17, *) {
                        Text("For advanced users. See page size or add custom arguments for experimental features. (Please don't touch this if you don't know what you're doing).")
                    } else {
                        Text("For advanced users. See page size or add custom arguments for experimental features. (Please don't touch this if you don't know what you're doing). If the emulation is not showing (you may hear audio in some games), try enabling \"SDL Window\"")
                    }
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
#if targetEnvironment(simulator)
        
        print("Saving Settings")
#else
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(config)
            let jsonString = String(data: data, encoding: .utf8)
            UserDefaults.standard.set(jsonString, forKey: "config")
        } catch {
            print("Failed to save settings: \(error)")
        }
#endif
    }
    
    func getCPUInfo() -> String? {
        let device = MTLCreateSystemDefaultDevice()
        
        let gpu = device?.name
        print("GPU: " + (gpu ?? ""))
        return gpu
    }

    
    // Original loadSettings function assumed to exist
    func loadSettings() -> Ryujinx.Configuration? {
        
#if targetEnvironment(simulator)
        print("Running on Simulator")
        
        return Ryujinx.Configuration(gamepath: "")
#else
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
#endif
    }
    
    @ViewBuilder
    private func labelWithIcon(_ text: String, iconName: String, flipimage: Bool? = nil) -> some View {
        HStack(spacing: 8) {
            if iconName.hasSuffix(".svg"){
                if let flipimage, flipimage {
                    SVGView(svgName: iconName, color: .blue)
                        .symbolRenderingMode(.hierarchical)
                        .frame(width: 20, height: 20)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                } else {
                    SVGView(svgName: iconName, color: .blue)
                        .symbolRenderingMode(.hierarchical)
                        .frame(width: 20, height: 20)
                }
            } else if !iconName.isEmpty {
                Image(systemName: iconName)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.blue)
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
        var hammock = UIView()
        
        if svgName.hasSuffix(".svg") {
            svgName.removeLast(4)
        }
        
        
        
        let svgLayer = UIView(SVGNamed: svgName) { svgLayer in
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
