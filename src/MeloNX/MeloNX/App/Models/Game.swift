//
//  GameInfo.swift
//  MeloNX
//
//  Created by Stossy11 on 9/12/2024.
//

import SwiftUI
import UniformTypeIdentifiers

public struct Game: Identifiable, Equatable, Hashable {
    public var id: URL { fileURL }

    var containerFolder: URL
    var fileType: UTType
    var fileURL: URL

    var titleName: String
    var titleId: String
    var developer: String
    var version: String
    var icon: UIImage?
    
    
    static func convertGameInfoToGame(gameInfo: GameInfo, url: URL) -> Game {
        var gameInfo = gameInfo
        var gameTemp = Game(containerFolder: url.deletingLastPathComponent(), fileType: .item, fileURL: url, titleName: "", titleId: "", developer: "", version: "")
        
        gameTemp.titleName = withUnsafePointer(to: &gameInfo.TitleName) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: $0)) {
                String(cString: $0)
            }
        }
        
        gameTemp.developer = withUnsafePointer(to: &gameInfo.Developer) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: $0)) {
                String(cString: $0)
            }
        }
        
        gameTemp.titleId = withUnsafePointer(to: &gameInfo.TitleId) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: $0)) {
                String(cString: $0)
            }
        }
        
        
        gameTemp.version = withUnsafePointer(to: &gameInfo.Version) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: $0)) {
                String(cString: $0)
            }
        }
        
        let imageSize = Int(gameInfo.ImageSize)
        if imageSize > 0, imageSize <= 1024 * 1024 {
            let imageData = Data(bytes: gameInfo.ImageData, count: imageSize)
            
            gameTemp.icon = UIImage(data: imageData)
        } else {
            print("Invalid image size.")
        }
        return gameTemp
    }
    
    func createImage(from gameInfo: GameInfo) -> UIImage? {
        let gameInfoValue = gameInfo

        let imageSize = Int(gameInfoValue.ImageSize)
        guard imageSize > 0, imageSize <= 1024 * 1024 else {
            print("Invalid image size.")
            return nil
        }

        let imageData = Data(bytes: gameInfoValue.ImageData, count: imageSize)
        return UIImage(data: imageData)
    }
}
