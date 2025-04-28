//
//  ToggleButtonsState.swift
//  MeloNX
//
//  Created by Stossy11 on 12/04/2025.
//


struct ToggleButtonsState: Codable, Equatable {
    var toggle1: Bool
    var toggle2: Bool
    var toggle3: Bool
    var toggle4: Bool
    
    init() {
        self = .default
    }
    
    init(toggle1: Bool, toggle2: Bool, toggle3: Bool, toggle4: Bool) {
        self.toggle1 = toggle1
        self.toggle2 = toggle2
        self.toggle3 = toggle3
        self.toggle4 = toggle4
    }

    static let `default` = ToggleButtonsState(toggle1: false, toggle2: false, toggle3: false, toggle4: false)
}
