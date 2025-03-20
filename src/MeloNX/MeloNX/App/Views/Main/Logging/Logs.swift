//
//  LogEntry.swift
//  MeloNX
//
//  Created by Stossy11 on 09/02/2025.
//

import SwiftUI

struct LogFileView: View {
    @State private var logs: [String] = []
    @State private var showingLogs = false
    
    public var isfps: Bool
    
    private let fileManager = FileManager.default
    private let maxDisplayLines = 10
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(logs.suffix(maxDisplayLines), id: \.self) { log in
                Text(log)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(4)
                    .transition(.opacity)
            }
        }
        .onAppear {
            startLogFileWatching()
        }
        .onChange(of: logs) { newLogs in
            print("Logs updated: \(newLogs.count) entries")
        }
    }
    
    private func getLatestLogFile() -> URL? {
        let logsDirectory = URL.documentsDirectory.appendingPathComponent("Logs")
        let currentDate = Date()
        
        do {
            try fileManager.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
            
            let logFiles = try fileManager.contentsOfDirectory(at: logsDirectory, includingPropertiesForKeys: [.creationDateKey])
                .filter {
                    let filename = $0.lastPathComponent
                    guard filename.hasPrefix("MeloNX_") && filename.hasSuffix(".log") else {
                        return false
                    }
                    
                    let dateString = filename.replacingOccurrences(of: "MeloNX_", with: "").replacingOccurrences(of: ".log", with: "")
                    guard let logDate = dateFormatter.date(from: dateString) else {
                        return false
                    }
                    
                    return Calendar.current.isDate(logDate, inSameDayAs: currentDate)
                }
            
            let sortedLogFiles = logFiles.sorted {
                $0.lastPathComponent > $1.lastPathComponent
            }
            
            return sortedLogFiles.first
        } catch {
            print("Error finding log files: \(error)")
            return nil
        }
    }
    
    private func readLatestLogFile() {
        guard let logFileURL = getLatestLogFile() else {
            print("no logs?")
            return
        }
        print(logFileURL)
        
        do {
            let logContents = try String(contentsOf: logFileURL)
            let allLines = logContents.components(separatedBy: .newlines)
            
            DispatchQueue.global(qos: .userInteractive).async {
                self.logs = Array(allLines)
            }
        } catch {
            print("Error reading log file: \(error)")
        }
    }
    
    private func startLogFileWatching() {
        showingLogs = true
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if showingLogs {
                self.readLatestLogFile()
            }
            
            if isfps {
                sleep(1)
                if get_current_fps() != 0 {
                    stopLogFileWatching()
                    timer.invalidate()
                }
            }
        }
    }
    
    private func stopLogFileWatching() {
        showingLogs = false
    }
}
