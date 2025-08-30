import UIKit

final class Haptics {
    static let shared = Haptics()
    private init() {}

    func tap() {
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.impactOccurred()
    }
}
