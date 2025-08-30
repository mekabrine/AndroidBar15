//
//  Tweak.swift
//  AndroidBar15 (Swift/Orion)
//

import Orion
import UIKit

// MARK: - SpringBoard hook
// Hook SpringBoard's UIApplication subclass to know when SB is ready.
class UIApplication_Hook: ClassHook<UIApplication> {
    func _run() {
        // SpringBoard finishes launching here. Ensure our bar exists.
        BarController.shared.installIfNeeded(inSpringBoard: true)
        orig()
    }
}
