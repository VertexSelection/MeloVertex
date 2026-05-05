//
//  SetupView.swift
//  MeloNX
//
//  Created by Stossy11 on 04/03/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct SetupView: View {
    private struct SetupErrorMessage: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }
    
    @State private var isImportingKeys = false
    @State private var isImportingFirmware = false
    @State private var isInstallingFirmware = false
    @State private var activeErrorMessage: SetupErrorMessage?
    @State private var showSkipAlert = false
    @State private var keysImported = false
    @State private var firmImported = false
    @State private var stagedFirmwareInstallURL: URL?
    @State private var showMainSetup = false
    @AppStorage("skippedSetup") var skippedSetup: Bool = false
    @Binding var isInSetup: Bool
    
    private var canFinishSetup: Bool {
        keysImported && firmImported && !isInstallingFirmware
    }
    
    let cool: LocalizedStringKey = "MeloNX has issues with Certificates and should not be used. Official Install Guides is [here](https://melonx.org)"
    
    var body: some View {
        Group {
            if showMainSetup {
                mainBody
            } else {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.red.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .overlay(content: { IconAnimation(showMainSetup: $showMainSetup)})
            }
        }
    }
    
    var mainBody: some View {
        iOSNav {
            ZStack {
                if UIDevice.current.systemName.contains("iPadOS") {
                    iPadSetupView()
                } else {
                    iPhoneSetupView()
                }
            }
        }
        .sheet(item: $activeErrorMessage) { modal in
            setupErrorModalView(for: modal)
        }
        .alert(isPresented: $showSkipAlert) {
            Alert(
                title: Text("Skip Setup?"),
                primaryButton: .destructive(Text("Skip")) {
                    Task { @MainActor in
                        skippedSetup = true
                        isInSetup = false
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onChange(of: isImportingFirmware) { newValue in
            if newValue {
                FileImporterManager.shared.importFiles(types: [.folder, .zip]) { result in
                    handleFirmwareImport(result: result)
                }
                isImportingFirmware = false
            }
        }
        .onChange(of: isImportingKeys) { newValue in
            if newValue {
                FileImporterManager.shared.importFiles(types: [.item], allowMultiple: true) { result in
                    handleKeysImport(result: result)
                }
                isImportingKeys = false
            }
        }
        .onAppear {
            RyujinxBridge.initialize()
            isInSetup = true
            refreshSetupStatus()
        }
    }
    
    @ViewBuilder
    private func iPadSetupView() -> some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.red.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                HStack(spacing: 40) {
                    if geometry.size.width > 800 {
                        VStack(alignment: .center, spacing: 20) {
                            Image(uiImage: UIImage(named: appIcon()) ?? UIImage())
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 40))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 40)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    .blue.opacity(0.6),
                                                    .red.opacity(0.6)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 6)
                                .onTapGesture {
                                    if MusicSelectorView.isPlaying {
                                        MusicSelectorView.stopMusic()
                                    } else {
                                        let mp3 = MusicSelectorView.getMP3s().first(where: { $0.builtIn })
                                        MusicSelectorView.playMusic(mp3)
                                    }
                                }
                                .onTapGesture(count: 2) {
                                    let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                    var sharedurl = documentsUrl.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
                                    if ProcessInfo.processInfo.isiOSAppOnMac {
                                        sharedurl = documentsUrl.absoluteString
                                    }
                                    if UIApplication.shared.canOpenURL(URL(string: sharedurl)!) {
                                        UIApplication.shared.open(URL(string: sharedurl)!, options: [:])
                                    }
                                }
                            
                            Text("Welcome to MeloVertex")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .onTapGesture(count: 2) {
                                    showSkipAlert = true
                                }
                            
                            if shouldAsCopy && !isInLiveContainer.0 {
                                Text(cool)
                                    .font(.callout)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Text("Set up your Nintendo Switch emulation environment by importing keys and firmware.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                                .onTapGesture {
                                    let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                    var sharedurl = documentsUrl.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
                                    if ProcessInfo.processInfo.isiOSAppOnMac {
                                        sharedurl = documentsUrl.absoluteString
                                    }
                                    if UIApplication.shared.canOpenURL(URL(string: sharedurl)!) {
                                        UIApplication.shared.open(URL(string: sharedurl)!, options: [:])
                                    }
                                }
                        }
                        .frame(maxWidth: 400)
                    }
                    
                    VStack(spacing: 20) {
                        setupStep(
                            title: "Import Keys",
                            description: "Add your encryption keys\n(prod.keys, title.keys)",
                            systemImage: "key.fill",
                            isCompleted: keysImported,
                            action: { isImportingKeys = true }
                        )
                        
                        setupStep(
                            title: "Add Firmware",
                            description: "Install Nintendo Switch firmware\n(firmware.zip)",
                            systemImage: "square.and.arrow.down",
                            isCompleted: firmImported,
                            isEnabled: keysImported && !isInstallingFirmware,
                            action: { isImportingFirmware = true }
                        )
                        
                        if isInstallingFirmware {
                            HStack(spacing: 8) {
                                ProgressView()
                                Text("Installing firmware...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button(action: attemptFinishSetup) {
                            HStack {
                                Text("Finish Setup")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                canFinishSetup
                                    ? Color.blue
                                    : Color.blue.opacity(0.3)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!canFinishSetup)
                    }
                    .frame(maxWidth: 500)
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private func iPhoneSetupView() -> some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.1),
                    Color.red.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        Image(uiImage: UIImage(named: appIcon()) ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                .blue.opacity(0.6),
                                                .red.opacity(0.6)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
                            .padding(.top, 40)
                            .onTapGesture {
                                if MusicSelectorView.isPlaying {
                                    MusicSelectorView.stopMusic()
                                } else {
                                    let mp3 = MusicSelectorView.getMP3s().first(where: { $0.builtIn })
                                    MusicSelectorView.playMusic(mp3)
                                }
                            }
                            .onTapGesture(count: 2) {
                                let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                var sharedurl = documentsUrl.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
                                if ProcessInfo.processInfo.isiOSAppOnMac {
                                    sharedurl = documentsUrl.absoluteString
                                }
                                if UIApplication.shared.canOpenURL(URL(string: sharedurl)!) {
                                    UIApplication.shared.open(URL(string: sharedurl)!, options: [:])
                                }
                            }
                        
                        Text("Welcome to MeloVertex!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.bottom, 20)
                            .onTapGesture(count: 2) {
                                showSkipAlert = true
                            }
                        
                        if shouldAsCopy && !isInLiveContainer.0 {
                            Text(cool)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .padding(.bottom, 20)
                        }
                        
                        setupStep(
                            title: "Import Keys",
                            description: "Add your encryption keys\n(prod.keys, title.keys)",
                            systemImage: "key.fill",
                            isCompleted: keysImported,
                            action: { isImportingKeys = true }
                        )
                        
                        setupStep(
                            title: "Add Firmware",
                            description: "Install Nintendo Switch firmware\n(firmware.zip)",
                            systemImage: "square.and.arrow.down",
                            isCompleted: firmImported,
                            isEnabled: keysImported && !isInstallingFirmware,
                            action: { isImportingFirmware = true }
                        )
                        
                        if isInstallingFirmware {
                            HStack(spacing: 8) {
                                ProgressView()
                                Text("Installing firmware...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                }
                
                // Finish Button
                VStack {
                    Button(action: attemptFinishSetup) {
                        HStack {
                            Text("Let's Go!")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            canFinishSetup
                                ? Color.blue
                                : Color.blue.opacity(0.3)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!canFinishSetup)
                    .padding()
                }
            }
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func setupStep(
        title: String,
        description: String,
        systemImage: String,
        isCompleted: Bool,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(alignment: .top) {
                Image(systemName: systemImage)
                    .foregroundColor(isCompleted ? .green : .blue)
                    .imageScale(.large)
                    .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .padding(.top, 4)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .disabled(!isEnabled || isCompleted)
        .opacity(isEnabled ? 1.0 : 0.5)
    }
    
    private func handleKeysImport(result: Result<[URL], Error>) {
        do {
            let selectedFiles = try result.get()
            
            guard selectedFiles.count == 2 else {
                presentErrorModal("Please select exactly 2 key files")
                return
            }
            
            for fileURL in selectedFiles {
                guard fileURL.startAccessingSecurityScopedResource() else {
                    presentErrorModal("Permission denied to access file")
                    return
                }
                
                defer {
                    fileURL.stopAccessingSecurityScopedResource()
                }
                
                let destinationURL = URL.documentsDirectory.appendingPathComponent("system").appendingPathComponent(fileURL.lastPathComponent)
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                try FileManager.default.copyItem(at: fileURL, to: destinationURL)
            }
            
            refreshSetupStatus()
            
        } catch {
            presentErrorModal("Error importing keys: \(error.localizedDescription)")
        }
    }
    
    private func handleFirmwareImport(result: Result<[URL], Error>) {
        do {
            let selectedFiles = try result.get()
            
            guard let fileURL = selectedFiles.first else {
                presentErrorModal("No file selected")
                return
            }
            
            guard fileURL.startAccessingSecurityScopedResource() else {
                presentErrorModal("Permission denied to access file")
                return
            }
            
            defer {
                fileURL.stopAccessingSecurityScopedResource()
            }
            
            cleanupStagedFirmware()
            let stagedURL = try stageFirmwareForInstallation(from: fileURL)
            stagedFirmwareInstallURL = stagedURL
            let (string, isErr) = RyujinxBridge.installFirmware(at: stagedURL.path)
            
            if isErr {
                cleanupStagedFirmware()
                presentErrorModal(string)
                return
            }

            Ryujinx.shared.firmwareversion = string
            isInstallingFirmware = true
            
            Task { @MainActor in
                await waitForFirmwareInstallation()
            }
            
        } catch {
            isInstallingFirmware = false
            cleanupStagedFirmware()
            presentErrorModal("Error importing firmware: \(error.localizedDescription)")
        }
    }
    
    private func refreshSetupStatus() {
        keysImported = Ryujinx.shared.checkIfKeysImported()
        let firmware = Ryujinx.shared.fetchFirmwareVersion()
        firmImported = (firmware == "" ? "0" : firmware) != "0"
    }
    
    @MainActor
    private func waitForFirmwareInstallation() async {
        let timeoutSeconds = 1800.0
        let pollIntervalNanoseconds: UInt64 = 500_000_000
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < timeoutSeconds {
            refreshSetupStatus()
            
            if firmImported {
                isInstallingFirmware = false
                cleanupStagedFirmware()
                return
            }
            
            try? await Task.sleep(nanoseconds: pollIntervalNanoseconds)
        }
        
        isInstallingFirmware = false
        refreshSetupStatus()
        
        if !firmImported {
            presentErrorModal("Firmware installation is taking longer than expected. Please keep MeloNX open and try again in a few minutes.")
        }
    }
    
    private func attemptFinishSetup() {
        refreshSetupStatus()
        
        guard canFinishSetup else {
            return
        }
        
        isInSetup = false
    }
    
    @ViewBuilder
    private func setupErrorModalView(for modal: SetupErrorMessage) -> some View {
        iOSNav {
            VStack(spacing: 20) {
                Text(modal.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                ScrollView {
                    Text(modal.message)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button(action: { activeErrorMessage = nil }) {
                    Text("OK")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        activeErrorMessage = nil
                    }
                }
            }
        }
    }
    
    private func presentErrorModal(_ message: String) {
        activeErrorMessage = SetupErrorMessage(
            title: "Setup Error",
            message: message
        )
    }
    
    private func stageFirmwareForInstallation(from sourceURL: URL) throws -> URL {
        let fileManager = FileManager.default
        let stagingRoot = URL.documentsDirectory.appendingPathComponent("setup-firmware-staging", isDirectory: true)
        
        if !fileManager.fileExists(atPath: stagingRoot.path) {
            try fileManager.createDirectory(at: stagingRoot, withIntermediateDirectories: true)
        }
        
        let stagingFolder = stagingRoot.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: stagingFolder, withIntermediateDirectories: true)
        
        let stagedURL = stagingFolder.appendingPathComponent(sourceURL.lastPathComponent, isDirectory: sourceURL.hasDirectoryPath)
        try fileManager.copyItem(at: sourceURL, to: stagedURL)
        
        return stagedURL
    }
    
    private func cleanupStagedFirmware() {
        guard let stagedURL = stagedFirmwareInstallURL else {
            return
        }
        
        let fileManager = FileManager.default
        let stagingFolder = stagedURL.deletingLastPathComponent()
        
        if fileManager.fileExists(atPath: stagingFolder.path) {
            try? fileManager.removeItem(at: stagingFolder)
        }
        
        stagedFirmwareInstallURL = nil
    }
    
    func appIcon(in bundle: Bundle = .main) -> String {
        guard let icons = bundle.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
              
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              
              let iconFileName = iconFiles.last else {

            // print("Could not find icons in bundle")
            return ""
        }

        return iconFileName
    }
}
