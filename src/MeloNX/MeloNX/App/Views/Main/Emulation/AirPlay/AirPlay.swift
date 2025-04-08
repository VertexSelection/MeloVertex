import UIKit
import SwiftUI

public extension View {
    
    func airPlay() -> some View {
        // print("AirKit - airPlay")
        Air.play(AnyView(self))
        return self
    }
    
}

