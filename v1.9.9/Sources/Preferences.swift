//
//  Preferences.swift
//  Simple wrapper around HBPreferences-style defaults (keys mirror AndroBar).
//

import UIKit

final class Preferences {
    static let shared = Preferences()
    private init() { load() }

    // Core options (subset)
    var isEnabled: Bool = true
    var useRipple: Bool = true
    var hapticFeedback: Int = 1
    var barHeight: Double = 40.0

    var barColour: UIColor {
        UIColor(hexRGBA: stored["barColour"] as? String ?? "#000000FF")
    }
    var backColour: UIColor {
        UIColor(hexRGBA: stored["backColour"] as? String ?? "#FFFFFFFF")
    }
    var homeColour: UIColor {
        UIColor(hexRGBA: stored["homeColour"] as? String ?? "#FFFFFFFF")
    }
    var switcherColour: UIColor {
        UIColor(hexRGBA: stored["switcherColour"] as? String ?? "#FFFFFFFF")
    }
    var colouringStyle: Int {
        stored["colouringStyle"] as? Int ?? 1
    }
    var themeName: String {
        stored["themeName"] as? String ?? "Pixel"
    }

    private var stored: [String: Any] = [:]

    func load() {
        // Read from CFPreferences (com.yourcompany.androidbar15)
        let id = "space.mekabrine.androidbar15.swift" as CFString
        if let dict = CFPreferencesCopyMultiple(nil, id, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) as? [String: Any] {
            stored = dict
        } else {
            stored = [:]
        }
    }
}

extension UIColor {
    convenience init(hexRGBA: String) {
        // accepts #RRGGBBAA
        var s = hexRGBA
        if s.hasPrefix("#") { s.removeFirst() }
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        let r = CGFloat((v >> 24) & 0xFF) / 255.0
        let g = CGFloat((v >> 16) & 0xFF) / 255.0
        let b = CGFloat((v >> 8) & 0xFF) / 255.0
        let a = CGFloat(v & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
