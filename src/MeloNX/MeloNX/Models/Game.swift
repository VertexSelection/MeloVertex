//
//  GameInfo.swift
//  MeloNX
//
//  Created by Stossy11 on 9/12/2024.
//

import SwiftUI
import UniformTypeIdentifiers

public struct Game: Identifiable, Equatable {
    public var id = UUID()

    var containerFolder: URL
    var fileType: UTType
    
    var fileURL: URL

    var titleName: String
    var titleId: String
    var developer: String
    var version: String
    var icon: UIImage?
    
    func createImage(from gameInfo: GameInfo) -> UIImage? {
        // Access the struct
        let gameInfoValue = gameInfo

        // Get the image data
        let imageSize = Int(gameInfoValue.ImageSize)
        guard imageSize > 0, imageSize <= 1024 * 1024 else {
            print("Invalid image size.")
            return nil
        }

        // Convert the ImageData byte array to Swift's Data
        let imageData = Data(bytes: gameInfoValue.ImageData, count: imageSize)

        // Create a UIImage (or NSImage on macOS)
        
        print(imageData)
        
        return UIImage(data: imageData)
    }
}
