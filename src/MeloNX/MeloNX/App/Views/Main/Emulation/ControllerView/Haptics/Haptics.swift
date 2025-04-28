//
//  Haptics.swift
//  Pomelo
//
//  Created by Stossy11 on 11/9/2024.
//  Copyright © 2024 Stossy11. All rights reserved.
//

import UIKit
import SwiftUI

class Haptics {
    static let shared = Haptics()
    
    private init() { }

    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}


