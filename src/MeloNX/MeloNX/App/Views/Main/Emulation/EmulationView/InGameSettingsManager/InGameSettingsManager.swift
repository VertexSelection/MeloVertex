//
//  InGameSettingsManager.swift
//  MeloNX
//
//  Created by Stossy11 on 12/06/2025.
//

import Foundation

class InGameSettingsManager: PerGameSettingsManaging {
    @Published var config: [String: Ryujinx.Arguments]
    
    private var saveWorkItem: DispatchWorkItem?
    
    public static var shared = InGameSettingsManager()
    
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
        if let currentgame = Ryujinx.shared.games.first(where: { $0.fileURL == URL(string: Ryujinx.shared.config?.gamepath ?? "") }) {
            Ryujinx.shared.config = config[currentgame.titleId]
            let args = Ryujinx.shared.buildCommandLineArgs(from: config[currentgame.titleId] ?? Ryujinx.Arguments())
            
            // Convert Arguments to ones that Ryujinx can Read
            let cArgs = args.map { strdup($0) }
            defer { cArgs.forEach { free($0) } }
            var argvPtrs = cArgs
            
            let result = update_settings_external(Int32(args.count), &argvPtrs)
            
            print(result)
        }
    }
    
    static func loadSettings() -> [String: Ryujinx.Arguments]? {
        var cool: [String: Ryujinx.Arguments] = [:]
        if let currentgame = Ryujinx.shared.games.first(where: { $0.fileURL == URL(string: Ryujinx.shared.config?.gamepath ?? "") }) {
            cool[currentgame.titleId] = Ryujinx.shared.config
            return cool
        } else {
            return nil
        }
    }
    
    func loadSettings() {
        self.config = PerGameSettingsManager.loadSettings() ?? [:]
    }
}
