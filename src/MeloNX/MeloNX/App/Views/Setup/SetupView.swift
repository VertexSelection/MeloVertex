//
//  SetupView.swift
//  MeloNX
//
//  Created by Stossy11 on 04/03/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct SetupView: View {
    @State private var isImportingKeys = false
    @State private var isImportingFirmware = false
    @State private var showAlert = false
    @State private var showSkipAlert = false
    @State private var alertMessage = ""
    @State private var keysImported = false
    @State private var firmImported = false
    @Binding var finished: Bool
    
    var body: some View {
        iOSNav {
            ZStack {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    iPadSetupView(
                        finished: $finished,
                        isImportingKeys: $isImportingKeys,
                        isImportingFirmware: $isImportingFirmware,
                        keysImported: keysImported,
                        firmImported: firmImported
                    )
                } else {
                    iPhoneSetupView(
                        finished: $finished,
                        isImportingKeys: $isImportingKeys,
                        isImportingFirmware: $isImportingFirmware,
                        keysImported: keysImported,
                        firmImported: firmImported
                    )
                }
            }
            .fileImporter(
                isPresented: $isImportingKeys,
                allowedContentTypes: [.item],
                allowsMultipleSelection: true
            ) { result in
                handleKeysImport(result: result)
            }
        }
        .fileImporter(
            isPresented: $isImportingFirmware,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            handleFirmwareImport(result: result)
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
        .alert("Skip Setup?", isPresented: $showSkipAlert) {
            Button("Skip", role: .destructive) { finished = true }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear {
            initialize()
            finished = false
            keysImported = Ryujinx.shared.checkIfKeysImported()
            print((Double(Ryujinx.shared.fetchFirmwareVersion()) ?? 0))
            firmImported = ((Double(Ryujinx.shared.fetchFirmwareVersion()) ?? 0) != 0)
        }
    }
    
    private func iPadSetupView(
        finished: Binding<Bool>,
        isImportingKeys: Binding<Bool>,
        isImportingFirmware: Binding<Bool>,
        keysImported: Bool,
        firmImported: Bool
    ) -> some View {
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
                            
                            Text("Welcome to MeloNX")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .onTapGesture(count: 2) {
                                    showSkipAlert = true
                                }
                            
                            Text("Set up your Nintendo Switch emulation environment by importing keys and firmware.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        .frame(maxWidth: 400)
                    }
                    
                    VStack(spacing: 20) {
                        setupStep(
                            title: "Import Keys",
                            description: "Add your encryption keys",
                            systemImage: "key.fill",
                            isCompleted: keysImported,
                            action: { isImportingKeys.wrappedValue = true }
                        )
                        
                        setupStep(
                            title: "Add Firmware",
                            description: "Install Nintendo Switch firmware",
                            systemImage: "square.and.arrow.down",
                            isCompleted: firmImported,
                            isEnabled: keysImported,
                            action: { isImportingFirmware.wrappedValue = true }
                        )
                        
                        Button(action: { finished.wrappedValue = true }) {
                            HStack {
                                Text("Finish Setup")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                firmImported && keysImported
                                    ? Color.blue
                                    : Color.blue.opacity(0.3)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!(firmImported && keysImported))
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
    
    private func iPhoneSetupView(
        finished: Binding<Bool>,
        isImportingKeys: Binding<Bool>,
        isImportingFirmware: Binding<Bool>,
        keysImported: Bool,
        firmImported: Bool
    ) -> some View {
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
                        
                        Text("Welcome to MeloNX")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.bottom, 20)
                            .onTapGesture(count: 2) {
                                showSkipAlert = true
                            }
                        
                        setupStep(
                            title: "Import Keys",
                            description: "Add your encryption keys",
                            systemImage: "key.fill",
                            isCompleted: keysImported,
                            action: { isImportingKeys.wrappedValue = true }
                        )
                        
                        setupStep(
                            title: "Add Firmware",
                            description: "Install Nintendo Switch firmware",
                            systemImage: "square.and.arrow.down",
                            isCompleted: firmImported,
                            isEnabled: keysImported,
                            action: { isImportingFirmware.wrappedValue = true }
                        )
                    }
                    .padding()
                }
                
                // Finish Button
                VStack {
                    Button(action: { finished.wrappedValue = true }) {
                        HStack {
                            Text("Finish Setup")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            firmImported && keysImported
                                ? Color.blue
                                : Color.blue.opacity(0.3)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!(firmImported && keysImported))
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
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(isCompleted ? .green : .blue)
                    .imageScale(.large)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
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
                alertMessage = "Please select exactly 2 key files"
                showAlert = true
                return
            }
            
            for fileURL in selectedFiles {
                guard fileURL.startAccessingSecurityScopedResource() else {
                    alertMessage = "Permission denied to access file"
                    showAlert = true
                    return
                }
                
                defer {
                    fileURL.stopAccessingSecurityScopedResource()
                }
                
                let destinationURL = URL.documentsDirectory.appendingPathComponent("system").appendingPathComponent(fileURL.lastPathComponent)
                
                try FileManager.default.copyItem(at: fileURL, to: destinationURL)
            }
            
            keysImported = Ryujinx.shared.checkIfKeysImported()
            alertMessage = "Keys imported successfully"
            showAlert = true
            
        } catch {
            alertMessage = "Error importing keys: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func handleFirmwareImport(result: Result<[URL], Error>) {
        do {
            let selectedFiles = try result.get()
            
            guard let fileURL = selectedFiles.first else {
                alertMessage = "No file selected"
                showAlert = true
                return
            }
            
            guard fileURL.startAccessingSecurityScopedResource() else {
                alertMessage = "Permission denied to access file"
                showAlert = true
                return
            }
            
            defer {
                fileURL.stopAccessingSecurityScopedResource()
            }
            
            Ryujinx.shared.installFirmware(firmwarePath: fileURL.path)
            
            print(Double(Ryujinx.shared.fetchFirmwareVersion()) ?? 0)
            
            firmImported = ((Double(Ryujinx.shared.fetchFirmwareVersion()) ?? 0) != 0)
            alertMessage = "Firmware installed successfully"
            showAlert = true
            
        } catch {
            alertMessage = "Error importing firmware: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    func appIcon(in bundle: Bundle = .main) -> String {
        guard let icons = bundle.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
              
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              
              let iconFileName = iconFiles.last else {

            print("Could not find icons in bundle")
            return ""
        }

        return iconFileName
    }
}
