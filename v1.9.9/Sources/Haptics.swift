//
//  Haptics.swift
//

import UIKit

final class Haptics {
    static let shared = Haptics()
    private init() {}

    func tap() {
        // Basic tap feedback; intensity mapping can be extended
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.impactOccurred()
    }
}
