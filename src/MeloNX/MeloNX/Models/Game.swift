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
    var icon: Image?
}
