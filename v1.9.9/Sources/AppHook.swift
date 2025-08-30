//
//  AppHook.swift
//  Injects into user apps (UIKit) so the bar appears inside apps too.
//

import Orion
import UIKit

class UIApplication_AppHook: ClassHook<UIApplication> {
    func applicationDidFinishLaunching(_ application: UIApplication) {
        orig(application)
        BarController.shared.installIfNeeded(inSpringBoard: false)
    }
}
