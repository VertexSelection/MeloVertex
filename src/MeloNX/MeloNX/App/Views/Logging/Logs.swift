//
//  LogEntry.swift
//  MeloNX
//
//  Created by Stossy11 on 09/02/2025.
//


import SwiftUI

struct LogEntry: Identifiable, Equatable {
    let id = UUID()
    let text: String

    static func == (lhs: LogEntry, rhs: LogEntry) -> Bool {
        return lhs.id == rhs.id && lhs.text == rhs.text
    }
}

struct LogViewer: View {
    @State private var logs: [LogEntry] = []
    @State private var latestLogFilePath: String?

    var body: some View {
        VStack {
            Spacer()
            VStack {
                ForEach(logs) { log in
                    Text(log.text)
                        .padding(4)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeOut(duration: 2), value: logs)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            findNewestLogFile()
        }
    }

    func findNewestLogFile() {
        let logsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("logs")

        guard let directory = logsDirectory else { return }
        
        do {
            let logFiles = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.contentModificationDateKey], options: .skipsHiddenFiles)
            
            // Sort files by modification date (newest first)
            let sortedFiles = logFiles.sorted {
                (try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast >
                (try? $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? Date.distantPast
            }
            
            if let newestLogFile = sortedFiles.first {
                latestLogFilePath = newestLogFile.path
                startReadingLogFile()
            }
        } catch {
            print("Error reading log files: \(error)")
        }
    }

    func startReadingLogFile() {
        guard let path = latestLogFilePath else { return }
        let fileHandle = try? FileHandle(forReadingAtPath: path)
        fileHandle?.seekToEndOfFile()
        
        NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: fileHandle, queue: .main) { _ in
            if let data = fileHandle?.availableData, !data.isEmpty {
                if let logLine = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    DispatchQueue.main.async {
                        withAnimation {
                            logs.append(LogEntry(text: logLine))
                        }
                        // Remove old logs after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                removelogfirst()
                            }
                        }
                    }
                }
            }
            fileHandle?.waitForDataInBackgroundAndNotify()
        }
        
        fileHandle?.waitForDataInBackgroundAndNotify()
    }
    
    func removelogfirst() {
        logs.removeFirst()
    }
}
