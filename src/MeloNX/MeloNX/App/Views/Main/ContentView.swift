//
//  ContentView.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import SwiftUI
import GameController
import Darwin
import UIKit
import MetalKit
import CoreLocation

struct MoltenVKSettings: Codable, Hashable {
    let string: String
    var value: String
}

struct ContentView: View {
    // MARK: - Properties
    
    // Games
    @State private var game: Game?
    
    // Controllers
    @State private var controllersList: [Controller] = []
    @State private var currentControllers: [Controller] = []
    @State var onscreencontroller: Controller = Controller(id: "", name: "")
    @State var nativeControllers: [GCController: NativeController] = [:]
    @State private var isVirtualControllerActive: Bool = false
    @AppStorage("isVirtualController") var isVCA: Bool = true
    
    // Settings and Configuration
    @State private var config: Ryujinx.Configuration
    @State var settings: [MoltenVKSettings]
    @AppStorage("useTrollStore") var useTrollStore: Bool = false
    
    // JIT
    @AppStorage("jitStreamerEB") var jitStreamerEB: Bool = false
    @AppStorage("stikJIT") var stikJIT: Bool = false
    
    // Other Configuration
    @State var isMK8: Bool = false
    @AppStorage("quit") var quit: Bool = false
    @State var quits: Bool = false
    @AppStorage("MVK_CONFIG_PREFILL_METAL_COMMAND_BUFFERS") var mVKPreFillBuffer: Bool = true
    @AppStorage("MVK_CONFIG_SYNCHRONOUS_QUEUE_SUBMITS") var syncqsubmits: Bool = true
    @AppStorage("ignoreJIT") var ignoreJIT: Bool = false
    
    // Loading Animation
    @AppStorage("showlogsloading") var showlogsloading: Bool = true
    @State private var clumpOffset: CGFloat = -100
    private let clumpWidth: CGFloat = 100
    private let animationDuration: Double = 1.0
    @State private var isAnimating = false
    @State var isLoading = true
    @StateObject var ryujinx = Ryujinx.shared
    
    // MARK: - SDL
    var sdlInitFlags: UInt32 = SDL_INIT_EVENTS | SDL_INIT_GAMECONTROLLER | SDL_INIT_JOYSTICK | SDL_INIT_AUDIO | SDL_INIT_VIDEO

    // MARK: - Initialization
    init() {
        var defaultConfig = loadSettings()
        if defaultConfig == nil {
            saveSettings(config: .init(gamepath: ""))
            defaultConfig = loadSettings()
        }
        
        _config = State(initialValue: defaultConfig!)
        
        let defaultSettings: [MoltenVKSettings] = [
            MoltenVKSettings(string: "MVK_USE_METAL_PRIVATE_API", value: "1"),
            MoltenVKSettings(string: "MVK_CONFIG_USE_METAL_PRIVATE_API", value: "1"),
            MoltenVKSettings(string: "MVK_DEBUG", value: "0"),
            MoltenVKSettings(string: "MVK_CONFIG_SYNCHRONOUS_QUEUE_SUBMITS", value: "0"),
            MoltenVKSettings(string: "MVK_CONFIG_PREFILL_METAL_COMMAND_BUFFERS", value: "0"),
            MoltenVKSettings(string: "MVK_CONFIG_MAX_ACTIVE_METAL_COMMAND_BUFFERS_PER_QUEUE", value: "512"),
        ]
        
        _settings = State(initialValue: defaultSettings)
        
        // print(SDL_CONTROLLER_BUTTON_LEFTSTICK.rawValue)
        
        initializeSDL()
    }
    
    // MARK: - Body
    var body: some View {
        if game != nil && (ryujinx.jitenabled || ignoreJIT) {
            gameView
        } else if game != nil && !ryujinx.jitenabled {
            jitErrorView
        } else {
            mainMenuView
        }
    }
    
    // MARK: - View Components
    
    private var gameView: some View {
        ZStack {
            if #available(iOS 16, *) {
                EmulationView(startgame: $game)
                    .persistentSystemOverlays(.hidden)
            } else {
                EmulationView(startgame: $game)
            }
            
            if isLoading {
                ZStack {
                    Color.black.opacity(0.8)
                    emulationView.ignoresSafeArea(.all)
                }
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea(.all)
            }
        }
    }
    
    private var jitErrorView: some View {
        Text("")
            .fullScreenCover(isPresented:Binding(
                get: { !ryujinx.jitenabled },
                set: { newValue in
                    ryujinx.jitenabled = newValue
                    
                    ryujinx.ryuIsJITEnabled()
                })
            ) {
                JITPopover() {
                    ryujinx.jitenabled = false
                }
                // .interactiveDismissDisabled()
            }
    }
    
    private var mainMenuView: some View {
        MainTabView(
            startemu: $game,
            config: $config,
            MVKconfig: $settings,
            controllersList: $controllersList,
            currentControllers: $currentControllers,
            onscreencontroller: $onscreencontroller
        )
        .onAppear {
            quits = false
            let _ = loadSettings()
            isLoading = true
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                refreshControllersList()
            }
            
            
            // print(MTLHud.shared.isEnabled)
            
            initControllerObservers()
            
            Air.play(AnyView(
                ControllerListView(game: $game)
            ))
            
            checkJitStatus()
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
    }
    
    private var emulationView: some View {
        GeometryReader { screenGeometry in
            ZStack {
                gameLoadingContent(screenGeometry: screenGeometry)
                
                HStack{
                    
                    VStack {
                        if showlogsloading {
                            LogFileView(isfps: true)
                                .frame(alignment: .topLeading)
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func gameLoadingContent(screenGeometry: GeometryProxy) -> some View {
        HStack(spacing: screenGeometry.size.width * 0.04) {
            if let icon = game?.icon {
                Image(uiImage: icon)
                    .resizable()
                    .frame(
                        width: min(screenGeometry.size.width * 0.25, 250),
                        height: min(screenGeometry.size.width * 0.25, 250)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
            }
            
            VStack(alignment: .leading, spacing: screenGeometry.size.height * 0.015) {
                Text("Loading \(game?.titleName ?? "Game")")
                    .font(.system(size: min(screenGeometry.size.width * 0.04, 32)))
                    .foregroundColor(.white)
                
                loadingProgressBar(screenGeometry: screenGeometry)
            }
        }
        .padding(.horizontal, screenGeometry.size.width * 0.06)
        .padding(.vertical, screenGeometry.size.height * 0.05)
        .position(
            x: screenGeometry.size.width / 2,
            y: screenGeometry.size.height * 0.5
        )
    }
    
    private func loadingProgressBar(screenGeometry: GeometryProxy) -> some View {
        GeometryReader { geometry in
            let containerWidth = min(screenGeometry.size.width * 0.35, 350)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .cornerRadius(10)
                    .frame(width: containerWidth, height: min(screenGeometry.size.height * 0.015, 12))
                    .foregroundColor(.gray.opacity(0.3))
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                Rectangle()
                    .cornerRadius(10)
                    .frame(width: clumpWidth, height: min(screenGeometry.size.height * 0.015, 12))
                    .foregroundColor(.blue)
                    .shadow(color: .blue.opacity(0.5), radius: 4, x: 0, y: 2)
                    .offset(x: isAnimating ? containerWidth : -clumpWidth)
                    .animation(
                        Animation.linear(duration: 1.0)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .onAppear {
                isAnimating = true
                setupEmulation()
                
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                    if get_current_fps() != 0 {
                        withAnimation {
                            isLoading = false
                            isAnimating = false
                        }
                        timer.invalidate()
                    }
                }
            }
        }
        .frame(height: min(screenGeometry.size.height * 0.015, 12))
        .frame(width: min(screenGeometry.size.width * 0.35, 350))
    }
    
    private func initializeSDL() {
        setMoltenVKSettings()
        SDL_SetMainReady()
        SDL_iPhoneSetEventPump(SDL_TRUE)
        SDL_Init(sdlInitFlags)
        initialize()
    }
    
    private func initControllerObservers() {
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { notification in
            if let controller = notification.object as? GCController {
                // print("Controller connected: \(controller.productCategory)")
                nativeControllers[controller] = .init(controller)
                refreshControllersList()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidDisconnect,
            object: nil,
            queue: .main
        ) { notification in
            if let controller = notification.object as? GCController {
                // print("Controller disconnected: \(controller.productCategory)")
                nativeControllers[controller]?.cleanup()
                nativeControllers[controller] = nil
                refreshControllersList()
            }
        }
    }
    
    private func setupEmulation() {
        isVCA = (currentControllers.first(where: { $0 == onscreencontroller }) != nil)
        
        DispatchQueue.main.async {
            start(displayid: 1)
        }
    }
    
    private func refreshControllersList() {
        controllersList = ryujinx.getConnectedControllers()
        
        if let onscreen = controllersList.first(where: { $0.name == ryujinx.virtualController.controllername }) {
            self.onscreencontroller = onscreen
        }
        
        controllersList.removeAll(where: { $0.id == "0" || (!$0.name.starts(with: "GC - ") && $0 != onscreencontroller) })
        controllersList.mutableForEach { $0.name = $0.name.replacingOccurrences(of: "GC - ", with: "") }

        currentControllers = []
        
        if controllersList.count == 1 {
            currentControllers.append(controllersList[0])
        } else if (controllersList.count - 1) >= 1 {
            for controller in controllersList {
                if controller.id != onscreencontroller.id && !currentControllers.contains(where: { $0.id == controller.id }) {
                    currentControllers.append(controller)
                }
            }
        }
    }
    
    private func start(displayid: UInt32) {
        guard let game else { return }
        
        config.gamepath = game.fileURL.path
        config.inputids = Array(Set(currentControllers.map(\.id)))
        
        configureEnvironmentVariables()
        
        if config.inputids.isEmpty {
            config.inputids.append("0")
        }
        
        do {
            try ryujinx.start(with: config)
        } catch {
            // print("Error: \(error.localizedDescription)")
        }
    }
    
    private func configureEnvironmentVariables() {
        if mVKPreFillBuffer {
            mVKPreFillBuffer = false
            // setenv("MVK_CONFIG_PREFILL_METAL_COMMAND_BUFFERS", "2", 1)
        }
        
        if syncqsubmits {
            setenv("MVK_CONFIG_SYNCHRONOUS_QUEUE_SUBMITS", "1", 1)
        }
    }
    
    private func setMoltenVKSettings() {
        settings.forEach { setting in
            setenv(setting.string, setting.value, 1)
        }
    }
    
    private func checkJitStatus() {
        ryujinx.ryuIsJITEnabled()
        if jitStreamerEB {
            jitStreamerEB = false // byee jitstreamer eb
        }
        if !ryujinx.jitenabled {
            if useTrollStore {
                askForJIT()
            } else if stikJIT {
                enableJITStik()
            } else if jitStreamerEB {
                enableJITEB()
            } else {
                // print("no JIT")
            }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           components.host == "game" {
            DispatchQueue.main.async {
                refreshControllersList()
                if let text = components.queryItems?.first(where: { $0.name == "id" })?.value {
                    game = ryujinx.games.first(where: { $0.titleId == text })
                } else if let text = components.queryItems?.first(where: { $0.name == "name" })?.value {
                    game = ryujinx.games.first(where: { $0.titleName == text })
                }
            }
        }
    }
}

extension Array {
    @inlinable public mutating func mutableForEach(_ body: (inout Element) throws -> Void) rethrows {
        for index in self.indices {
            try body(&self[index])
        }
    }
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private var locationManager: CLLocationManager
    
    static let sharedInstance = LocationManager()
    
    private override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // print("wow")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with: \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .denied {
            print("Location services are disabled in settings.")
        } else {
            startUpdatingLocation()
        }
    }
    
    func stop() {
        if UserDefaults.standard.bool(forKey: "location-enabled") {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func startUpdatingLocation() {
        if UserDefaults.standard.bool(forKey: "location-enabled") {
            locationManager.requestAlwaysAuthorization()
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startUpdatingLocation()
        }
    }
}


struct ControllerListView: View {
    @State private var selectedIndex = 0
    @Binding var game: Game?
    @ObservedObject private var ryujinx = Ryujinx.shared

    var body: some View {
        List(ryujinx.games.indices, id: \.self) { index in
            let game = ryujinx.games[index]

            HStack(spacing: 16) {
                // Game Icon
                Group {
                    if let icon = game.icon {
                        Image(uiImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(width: 55, height: 55)
                .cornerRadius(10)

                // Game Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(game.titleName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)

                    HStack(spacing: 4) {
                        Text(game.developer)

                        if !game.version.isEmpty && game.version != "0" {
                            Text("•")
                            Text("v\(game.version)")
                        }
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                }

                Spacer()
            }
            .background(selectedIndex == index ? Color.blue.opacity(0.3) : .clear)
        }
        .onAppear(perform: setupControllerObservers)
    }

    private func setupControllerObservers() {
        let dpadHandler: GCControllerDirectionPadValueChangedHandler = { _, _, yValue in
            if yValue == 1.0 {
                selectedIndex = max(0, selectedIndex - 1)
            } else if yValue == -1.0 {
                selectedIndex = min(ryujinx.games.count - 1, selectedIndex + 1)
            }
        }

        for controller in GCController.controllers() {
            print("Controller connected: \(controller.vendorName ?? "Unknown")")
            controller.playerIndex = .index1

            controller.microGamepad?.dpad.valueChangedHandler = dpadHandler
            controller.extendedGamepad?.dpad.valueChangedHandler = dpadHandler

            controller.extendedGamepad?.buttonA.pressedChangedHandler = { _, _, pressed in
                if pressed {
                    print("A button pressed")
                    game = ryujinx.games[selectedIndex]
                }
            }
        }

        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { _ in
            setupControllerObservers()
        }
    }
}
