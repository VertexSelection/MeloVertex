//
//  Ryujinx.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import Foundation
import SwiftUI
import GameController
import MetalKit
import Metal

class LogCapture {
    static let shared = LogCapture()

    private var stdoutPipe: Pipe?
    private var stderrPipe: Pipe?
    private let originalStdout: Int32
    private let originalStderr: Int32

    var capturedLogs: [String] = [] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .newLogCaptured, object: nil)
            }
        }
    }

    private init() {
        originalStdout = dup(STDOUT_FILENO)
        originalStderr = dup(STDERR_FILENO)
        startCapturing()
    }

    func startCapturing() {
        stdoutPipe = Pipe()
        stderrPipe = Pipe()

        redirectOutput(to: stdoutPipe!, fileDescriptor: STDOUT_FILENO)
        redirectOutput(to: stderrPipe!, fileDescriptor: STDERR_FILENO)

        setupReadabilityHandler(for: stdoutPipe!, isStdout: true)
        setupReadabilityHandler(for: stderrPipe!, isStdout: false)
    }

    func stopCapturing() {
        dup2(originalStdout, STDOUT_FILENO)
        dup2(originalStderr, STDERR_FILENO)

        stdoutPipe?.fileHandleForReading.readabilityHandler = nil
        stderrPipe?.fileHandleForReading.readabilityHandler = nil
    }

    private func redirectOutput(to pipe: Pipe, fileDescriptor: Int32) {
        dup2(pipe.fileHandleForWriting.fileDescriptor, fileDescriptor)
    }

    private func setupReadabilityHandler(for pipe: Pipe, isStdout: Bool) {
        pipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
            let data = fileHandle.availableData
            let originalFD = isStdout ? self?.originalStdout : self?.originalStderr
            write(originalFD ?? STDOUT_FILENO, (data as NSData).bytes, data.count)

            if let logString = String(data: data, encoding: .utf8),
               let cleanedLog = self?.cleanLog(logString), !cleanedLog.isEmpty {
                self?.capturedLogs.append(cleanedLog)
            }
        }
    }

    private func cleanLog(_ raw: String) -> String? {
        let lines = raw.split(separator: "\n")
        let filteredLines = lines.filter { line in
            !line.contains("SwiftUI") &&
            !line.contains("ForEach") &&
            !line.contains("VStack") &&
            !line.contains("Invalid frame dimension (negative or non-finite).")
        }

        let cleaned = filteredLines.map { line -> String in
            if let tabRange = line.range(of: "\t") {
                return line[tabRange.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return line.trimmingCharacters(in: .whitespacesAndNewlines)
        }.joined(separator: "\n")

        return cleaned.isEmpty ? nil : cleaned.replacingOccurrences(of: "\n\n", with: "\n")
    }

    deinit {
        stopCapturing()
    }
}


extension Notification.Name {
    static let newLogCaptured = Notification.Name("newLogCaptured")
}

struct Controller: Identifiable, Hashable {
    var id: String
    var name: String
}

struct iOSNav<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        if #available(iOS 16, *) {
            NavigationStack(root: content)
        } else {
            NavigationView(content: content)
                .navigationViewStyle(StackNavigationViewStyle())
                .navigationViewStyle(.stack)
        }
    }
}


class Ryujinx : ObservableObject {
    @Published var isRunning = false
    
    let virtualController = VirtualController()
    
    @Published var controllerMap: [Controller] = []
    @Published var metalLayer: CAMetalLayer? = nil
    @Published var isPortrait = false
    @Published var firmwareversion = "0"
    @Published var emulationUIView: MeloMTKView? = nil
    @Published var config: Ryujinx.Configuration? = nil
    @Published var games: [Game] = []
    
    @Published var defMLContentSize: CGFloat?
    
    var thread: Thread = Thread { }
    
    @Published var jitenabled = false
    
    var shouldMetal: Bool {
        metalLayer == nil
    }
    
    static let shared = Ryujinx()
    
    private init() {
        self.games = loadGames()
    }
    
    func runloop(_ cool: @escaping () -> Void) {
        if UserDefaults.standard.bool(forKey: "runOnMainThread") {
            RunLoop.main.perform {
                cool()
            }
        } else {
            thread = Thread {
                cool()
            }
            
            thread.qualityOfService = .userInteractive
            thread.name = "MeloNX"
            thread.start()
        }
    }
    
    public struct Configuration : Codable, Equatable {
        var gamepath: String
        var inputids: [String]
        var resscale: Float
        var debuglogs: Bool
        var tracelogs: Bool
        var nintendoinput: Bool
        var enableInternet: Bool
        var listinputids: Bool
        var aspectRatio: AspectRatio
        var memoryManagerMode: String
        var disableShaderCache: Bool
        var hypervisor: Bool
        var disableDockedMode: Bool
        var enableTextureRecompression: Bool
        var additionalArgs: [String]
        var maxAnisotropy: Float
        var macroHLE: Bool
        var ignoreMissingServices: Bool
        var expandRam: Bool
        var dfsIntegrityChecks: Bool
        var disablePTC: Bool
        var disablevsync: Bool
        var language: SystemLanguage
        var regioncode: SystemRegionCode
        var handHeldController: Bool
        

        init(gamepath: String,
             inputids: [String] = [],
             debuglogs: Bool = false,
             tracelogs: Bool = false,
             listinputids: Bool = false,
             aspectRatio: AspectRatio = .fixed16x9,
             memoryManagerMode: String = "HostMappedUnsafe",
             disableShaderCache: Bool = false,
             disableDockedMode: Bool = false,
             nintendoinput: Bool = true,
             enableInternet: Bool = false,
             enableTextureRecompression: Bool = true,
             additionalArgs: [String] = [],
             resscale: Float = 1.00,
             maxAnisotropy: Float = 0,
             macroHLE: Bool = false,
             ignoreMissingServices: Bool = false,
             hypervisor: Bool = false,
             expandRam: Bool = false,
             dfsIntegrityChecks: Bool = false,
             disablePTC: Bool = false,
             disablevsync: Bool = false,
             language: SystemLanguage = .americanEnglish,
             regioncode: SystemRegionCode = .usa,
             handHeldController: Bool = false
        ) {
            self.gamepath = gamepath
            self.inputids = inputids
            self.debuglogs = debuglogs
            self.tracelogs = tracelogs
            self.listinputids = listinputids
            self.aspectRatio = aspectRatio
            self.disableShaderCache = disableShaderCache
            self.disableDockedMode = disableDockedMode
            self.enableTextureRecompression = enableTextureRecompression
            self.additionalArgs = additionalArgs
            self.memoryManagerMode = memoryManagerMode
            self.resscale = resscale
            self.nintendoinput = nintendoinput
            self.enableInternet = enableInternet
            self.maxAnisotropy = maxAnisotropy
            self.macroHLE = macroHLE
            self.expandRam = expandRam
            self.ignoreMissingServices = ignoreMissingServices
            self.hypervisor = hypervisor
            self.dfsIntegrityChecks = dfsIntegrityChecks
            self.disablePTC = disablePTC
            self.disablevsync = disablevsync
            self.language = language
            self.regioncode = regioncode
            self.handHeldController = handHeldController
        }
    }

    
    func start(with config: Configuration) throws {
        guard !isRunning else {
            throw RyujinxError.alreadyRunning
        }
        
        self.config = config
        
        
        runloop { [self] in
            
            isRunning = true
            
            let url = URL(string: config.gamepath)
            
            do {
                let args = self.buildCommandLineArgs(from: config)
                let accessing = url?.startAccessingSecurityScopedResource()
                
                // Convert Arguments to ones that Ryujinx can Read
                let cArgs = args.map { strdup($0) }
                defer { cArgs.forEach { free($0) } }
                var argvPtrs = cArgs
                
                // Start the emulation
                if isRunning {
                    let result = main_ryujinx_sdl(Int32(args.count), &argvPtrs)
                    
                    if result != 0 {
                        self.isRunning = false
                        if let accessing, accessing {
                            url!.stopAccessingSecurityScopedResource()
                        }
                        
                        throw RyujinxError.executionError(code: result)
                    }
                }
            } catch {
                self.isRunning = false
                Thread.sleep(forTimeInterval: 0.3)
                let logs = LogCapture.shared.capturedLogs
                let parsedLogs = extractExceptionInfo(logs)
                if let parsedLogs {
                    DispatchQueue.main.async {
                        let result = Array(logs.suffix(from: parsedLogs.lineIndex))
                        
                        LogCapture.shared.capturedLogs = Array(LogCapture.shared.capturedLogs.prefix(upTo: parsedLogs.lineIndex))
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
                        let currentDate = Date()
                        let dateString = dateFormatter.string(from: currentDate)
                        let path = URL.documentsDirectory.appendingPathComponent("StackTrace").appendingPathComponent("StackTrace-\(dateString).txt").path
                        
                        self.saveArrayAsTextFile(strings: result, filePath: path)
                        
                        
                        presentAlert(title: "MeloNX Crashed!", message: parsedLogs.exceptionType + ": " + parsedLogs.message) {
    
                            assert(true, parsedLogs.exceptionType)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        presentAlert(title: "MeloNX Crashed!", message:  "Unknown Error") {
                            assert(true, "Exception was not detected")
                        }
                    }
                }
            }
        }
    }
    
    func saveArrayAsTextFile(strings: [String], filePath: String) {
        let text = strings.joined(separator: "\n")
        
        let path = URL.documentsDirectory.appendingPathComponent("StackTrace").path
        
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false)
        } catch {
            
        }
        
        do {
            try text.write(to: URL(fileURLWithPath: filePath), atomically: true, encoding: .utf8)
            print("File saved successfully.")
        } catch {
            print("Error saving file: \(error)")
        }
    }
    
    struct ExceptionInfo {
        let exceptionType: String
        let message: String
        let lineIndex: Int
    }

    func extractExceptionInfo(_ logs: [String]) -> ExceptionInfo? {
        for i in (0..<logs.count).reversed() {
            let line = logs[i]
            let pattern = "([\\w\\.]+Exception): ([^\\s]+(?:\\s+[^\\s]+)*)"
            
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []),
                  let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) else {
                continue
            }
            
            // Extract exception type and message if pattern matches
            if let exceptionTypeRange = Range(match.range(at: 1), in: line),
               let messageRange = Range(match.range(at: 2), in: line) {
                
                let exceptionType = String(line[exceptionTypeRange])
                
                var message = String(line[messageRange])
                if let atIndex = message.range(of: "\\s+at\\s+", options: .regularExpression) {
                    message = String(message[..<atIndex.lowerBound])
                }
                
                message = message.trimmingCharacters(in: .whitespacesAndNewlines)
                
                return ExceptionInfo(exceptionType: exceptionType, message: message, lineIndex: i)
            }
        }
        
        return nil
    }

    
    func stop() throws {
        guard isRunning else {
            throw RyujinxError.notRunning
        }

        isRunning = false
        
        self.emulationUIView = nil
        self.metalLayer = nil
        
        thread.cancel()
    }

    
    func loadGames() -> [Game] {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }
        
        let romsDirectory = documentsDirectory.appendingPathComponent("roms")
        
        if (!fileManager.fileExists(atPath: romsDirectory.path)) {
            do {
                try fileManager.createDirectory(at: romsDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                // print("Failed to create roms directory: \(error)")
            }
        }
        var games: [Game] = []
        
        do {
            let files = try fileManager.contentsOfDirectory(at: romsDirectory, includingPropertiesForKeys: nil)
            
            for fileURLCandidate in files {
                if fileURLCandidate.pathExtension == "zip" {
                    continue
                }
                
                do {
                    let handle = try FileHandle(forReadingFrom: fileURLCandidate)
                    let fileExtension = (fileURLCandidate.pathExtension as NSString).utf8String
                    let extensionPtr = UnsafeMutablePointer<CChar>(mutating: fileExtension)
                    
                    
                    let gameInfo = get_game_info(handle.fileDescriptor, extensionPtr)
                    
                    let game = Game.convertGameInfoToGame(gameInfo: gameInfo, url: fileURLCandidate)
                    
                    games.append(game)
                } catch {
                    // print(error)
                }
            }

            return games
        } catch {
            // print("Error loading games from roms folder: \(error)")
            return games
        }
        
    }

    private func buildCommandLineArgs(from config: Configuration) -> [String] {
        var args: [String] = []
        
        // Add the game path
        args.append(config.gamepath)
        
        // Starts with vulkan
        args.append("--graphics-backend")
        args.append("Vulkan")
        
        args.append(contentsOf: ["--memory-manager-mode", config.memoryManagerMode])
        
        // args.append(contentsOf: ["--exclusive-fullscreen", String(true)])
        // args.append(contentsOf: ["--exclusive-fullscreen-width", "\(Int(UIScreen.main.bounds.width))"])
        // args.append(contentsOf: ["--exclusive-fullscreen-height", "\(Int(UIScreen.main.bounds.height))"])
        // We don't need this. Ryujinx should handle it fine :3
        // this also causes crashes in some games :3
        
        var model = ""
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        model = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        args.append(contentsOf: ["--device-model", model])
        
        args.append(contentsOf: ["--device-display-name", UIDevice.modelName])
        
        if checkAppEntitlement("com.apple.developer.kernel.increased-memory-limit") {
            args.append("--has-memory-entitlement")
        }
        
        args.append(contentsOf: ["--system-language", config.language.rawValue])
        
        args.append(contentsOf: ["--system-region", config.regioncode.rawValue])
        
        args.append(contentsOf: ["--aspect-ratio", config.aspectRatio.rawValue])
        
        
        if config.nintendoinput {
            args.append("--correct-controller")
        }
        
        if config.disablePTC {
            args.append("--disable-ptc")
        }
        
        if config.disablevsync {
            args.append("--disable-vsync")
        }
        
         
        if config.hypervisor {
            args.append("--use-hypervisor")
        }
        
        if config.dfsIntegrityChecks {
            args.append("--disable-fs-integrity-checks")
        }
        
        
        if config.resscale != 1.0 {
            args.append(contentsOf: ["--resolution-scale", String(config.resscale)])
        }
        
        if config.expandRam {
            args.append(contentsOf: ["--expand-ram", String(config.expandRam)])
        }
        
        if config.ignoreMissingServices {
            // args.append(contentsOf: ["--ignore-missing-services"])
            args.append("--ignore-missing-services")
        }
        
        if config.maxAnisotropy != 0 {
            args.append(contentsOf: ["--max-anisotropy", String(config.maxAnisotropy)])
        }
        
        if !config.macroHLE {
            args.append("--disable-macro-hle")
        }
        
        if !config.disableShaderCache { // same with disableShaderCache
            args.append("--disable-shader-cache")
        }
        
        if !config.disableDockedMode { // disableDockedMode is actually enableDockedMode, i just have flipped it around in the settings page to make it easier to understand :3
            args.append("--disable-docked-mode")
        }
        if config.enableTextureRecompression {
            args.append("--enable-texture-recompression")
        }
        
        if config.debuglogs {
            args.append("--enable-debug-logs")
        }
        if config.tracelogs {
            args.append("--enable-trace-logs")
        }

        // List the input ids
        if config.listinputids {
            args.append("--list-inputs-ids")
        }
        
        // Append the input ids (limit to 8 (used to be 4) just in case)
        if !config.inputids.isEmpty {
            config.inputids.prefix(8).enumerated().forEach { index, inputId in
                if config.handHeldController {
                    args.append(contentsOf: ["\(index == 0 ? "--input-id-handheld" : "--input-id-\(index + 1)")", inputId])
                } else {
                    args.append(contentsOf: ["--input-id-\(index + 1)", inputId])
                }
            }
        }
        
        args.append(contentsOf: config.additionalArgs)

        return args
    }
    
    func checkIfKeysImported() -> Bool {
        let keysDirectory = URL.documentsDirectory.appendingPathComponent("system")
        let keysFile = keysDirectory.appendingPathComponent("prod.keys")

        return FileManager.default.fileExists(atPath: keysFile.path)
    }
    
    func fetchFirmwareVersion() -> String {
        let firmwareVersionPointer = installed_firmware_version()
        if let pointer = firmwareVersionPointer {
            let firmwareVersion = String(cString: pointer)
            DispatchQueue.main.async {
                self.firmwareversion = firmwareVersion
            }
            return firmwareVersion
        }

        return "0"
    }
    
    func installFirmware(firmwarePath: String) {
        guard let cString = firmwarePath.cString(using: .utf8) else {
            // print("Invalid firmware path")
            return
        }

        install_firmware(cString)
        
        let version = fetchFirmwareVersion()
        if !version.isEmpty {
            self.firmwareversion = version
        }
    }

    func getDlcNcaList(titleId: String, path: String) -> [DownloadableContentNca] {
        guard let titleIdCString = titleId.cString(using: .utf8),
            let pathCString = path.cString(using: .utf8)
        else {
            // print("Invalid path")
            return []
        }

        let listPointer = get_dlc_nca_list(titleIdCString, pathCString)
        // print("DLC parcing success: \(listPointer.success)")
        guard listPointer.success else { return [] }

        let list = Array(UnsafeBufferPointer(start: listPointer.items, count: Int(listPointer.size)))

        return list.map { item in
                .init(fullPath: withUnsafePointer(to: item.Path) {
                    $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: $0)) {
                        String(cString: $0)
                    }
                }, titleId: item.TitleId, enabled: true)
        }
    }

    private func generateGamepadId(joystickIndex: Int32) -> String? {
        let guid = SDL_JoystickGetDeviceGUID(joystickIndex)

        if guid.data.0 == 0 && guid.data.1 == 0 && guid.data.2 == 0 && guid.data.3 == 0 {
            return nil
        }

        let reorderedGUID: [UInt8] = [
            guid.data.3, guid.data.2, guid.data.1, guid.data.0,
            guid.data.5, guid.data.4,
            guid.data.7, guid.data.6,
            guid.data.8, guid.data.9,
            guid.data.10, guid.data.11, guid.data.12, guid.data.13, guid.data.14, guid.data.15
        ]

        let guidString = reorderedGUID.map { String(format: "%02X", $0) }.joined().lowercased()

        func substring(_ str: String, _ start: Int, _ end: Int) -> String {
            let startIdx = str.index(str.startIndex, offsetBy: start)
            let endIdx = str.index(str.startIndex, offsetBy: end)
            return String(str[startIdx..<endIdx])
        }

        let formattedGUID = "\(substring(guidString, 0, 8))-\(substring(guidString, 8, 12))-\(substring(guidString, 12, 16))-\(substring(guidString, 16, 20))-\(substring(guidString, 20, 32))"

        return "\(joystickIndex)-\(formattedGUID)"
    }
    
    func getConnectedControllers() -> [Controller] {
        var controllers: [Controller] = []

        let numJoysticks = SDL_NumJoysticks()

        for i in 0..<numJoysticks {
            if let controller = SDL_GameControllerOpen(i) {
                let guid = generateGamepadId(joystickIndex: i)
                let name = String(cString: SDL_GameControllerName(controller))
                
                // print("Controller \(i): \(name), GUID: \(guid ?? "")")
                
                guard let guid else {
                    SDL_GameControllerClose(controller)
                    return []
                }
                
                controllers.append(Controller(id: guid, name: name))

                SDL_GameControllerClose(controller)
            }
         }
        
        return controllers
    }
    
    func removeFirmware() {
        let fileManager = FileManager.default
        
        let documentsfolder = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        
        let bisFolder = documentsfolder.appendingPathComponent("bis")
        let systemFolder = bisFolder.appendingPathComponent("system")
        let contentsFolder = systemFolder.appendingPathComponent("Contents")
        let registeredFolder = contentsFolder.appendingPathComponent("registered").path
        
    
        do {
            if fileManager.fileExists(atPath: registeredFolder) {
                try fileManager.removeItem(atPath: registeredFolder)
                // print("Folder removed successfully.")
                let version = fetchFirmwareVersion()
                
                if version.isEmpty {
                    self.firmwareversion = "0"
                } else {
                    // print("Firmware eeeeee \(version)")
                }
                
            } else {
                // print("Folder does not exist.")
            }
        } catch {
            // print("Error removing folder: \(error)")
        }
    }
    


    static func log(_ message: String) {
        // print("[Ryujinx] \(message)")
    }
    
    public func updateOrientation() -> Bool {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return (window.bounds.size.height > window.bounds.size.width)
        }
        return false
    }
    
    func ryuIsJITEnabled() {
        jitenabled = isJITEnabled()
    }
}


public extension UIDevice {
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                       return "iPod touch (5th generation)"
            case "iPod7,1":                                       return "iPod touch (6th generation)"
            case "iPod9,1":                                       return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
            case "iPhone4,1":                                     return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                        return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                        return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
            case "iPhone7,2":                                     return "iPhone 6"
            case "iPhone7,1":                                     return "iPhone 6 Plus"
            case "iPhone8,1":                                     return "iPhone 6s"
            case "iPhone8,2":                                     return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
            case "iPhone11,2":                                    return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
            case "iPhone11,8":                                    return "iPhone XR"
            case "iPhone12,1":                                    return "iPhone 11"
            case "iPhone12,3":                                    return "iPhone 11 Pro"
            case "iPhone12,5":                                    return "iPhone 11 Pro Max"
            case "iPhone13,1":                                    return "iPhone 12 mini"
            case "iPhone13,2":                                    return "iPhone 12"
            case "iPhone13,3":                                    return "iPhone 12 Pro"
            case "iPhone13,4":                                    return "iPhone 12 Pro Max"
            case "iPhone14,4":                                    return "iPhone 13 mini"
            case "iPhone14,5":                                    return "iPhone 13"
            case "iPhone14,2":                                    return "iPhone 13 Pro"
            case "iPhone14,3":                                    return "iPhone 13 Pro Max"
            case "iPhone14,7":                                    return "iPhone 14"
            case "iPhone14,8":                                    return "iPhone 14 Plus"
            case "iPhone15,2":                                    return "iPhone 14 Pro"
            case "iPhone15,3":                                    return "iPhone 14 Pro Max"
            case "iPhone15,4":                                    return "iPhone 15"
            case "iPhone15,5":                                    return "iPhone 15 Plus"
            case "iPhone16,1":                                    return "iPhone 15 Pro"
            case "iPhone16,2":                                    return "iPhone 15 Pro Max"
            case "iPhone17,3":                                    return "iPhone 16"
            case "iPhone17,4":                                    return "iPhone 16 Plus"
            case "iPhone17,1":                                    return "iPhone 16 Pro"
            case "iPhone17,2":                                    return "iPhone 16 Pro Max"
            case "iPhone17,5":                                    return "iPhone 16e"
            case "iPhone8,4":                                     return "iPhone SE"
            case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
            case "iPhone14,6":                                    return "iPhone SE (3rd generation)"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":      return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":                 return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":                 return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
            case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
            case "iPad13,18", "iPad13,19":                        return "iPad (10th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
            case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
            case "iPad13,16", "iPad13,17":                        return "iPad Air (5th generation)"
            case "iPad14,8", "iPad14,9":                          return "iPad Air (11-inch) (M2)"
            case "iPad14,10", "iPad14,11":                        return "iPad Air (13-inch) (M2)"
            case "iPad2,5", "iPad2,6", "iPad2,7":                 return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
            case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
            case "iPad16,1", "iPad16,2":                          return "iPad mini (A17 Pro)"
            case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
            case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
            case "iPad14,3", "iPad14,4":                          return "iPad Pro (11-inch) (4th generation)"
            case "iPad16,3", "iPad16,4":                          return "iPad Pro (11-inch) (M4)"
            case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
            case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
            case "iPad14,5", "iPad14,6":                          return "iPad Pro (12.9-inch) (6th generation)"
            case "iPad16,5", "iPad16,6":                          return "iPad Pro (13-inch) (M4)"
            case "AppleTV5,3":                                    return "Apple TV"
            case "AppleTV6,2":                                    return "Apple TV 4K"
            case "AudioAccessory1,1":                             return "HomePod"
            case "AudioAccessory5,1":                             return "HomePod mini"
            case "i386", "x86_64", "arm64":                       return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                              return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2", "AppleTV11,1", "AppleTV14,1": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #elseif os(visionOS)
            switch identifier {
            case "RealityDevice14,1": return "Apple Vision Pro"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()

}
