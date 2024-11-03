//
//  RyujinxError.swift
//  MeloNX
//
//  Created by Stossy11 on 3/11/2024.
//

import Foundation

enum RyujinxError: Error {
    case libraryLoadError
    case executionError(code: Int32)
    case alreadyRunning
    case notRunning
}
