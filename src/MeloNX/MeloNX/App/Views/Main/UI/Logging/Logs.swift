//
//  LogEntry.swift
//  MeloNX
//
//  Created by Stossy11 on 09/02/2025.
//

import SwiftUI
import Combine

struct LogFileView: View {
    @StateObject var logsModel = LogViewModel()
    @State private var showingLogs = false
    
    public var isfps: Bool
    
    private let fileManager = FileManager.default
    private let maxDisplayLines = 4
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(logsModel.logs.suffix(maxDisplayLines), id: \.self) { log in
                Text(log)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(4)
                    .transition(.opacity)
            }
        }
        .padding()
    }
    
    private func stopLogFileWatching() {
        showingLogs = false
    }
}


class LogViewModel: ObservableObject {
    @Published var logs: [String] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        _ = LogCapture.shared
        
        NotificationCenter.default.publisher(for: .newLogCaptured)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateLogs()
            }
            .store(in: &cancellables)
        
        updateLogs()
    }
    
    func updateLogs() {
        logs = LogCapture.shared.capturedLogs
    }
    
    func clearLogs() {
        LogCapture.shared.capturedLogs = []
        updateLogs()
    }
}
