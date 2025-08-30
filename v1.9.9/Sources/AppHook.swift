import Orion
import UIKit

class UIApplication_AppHook: ClassHook<UIApplication> {
    func applicationDidFinishLaunching(_ application: UIApplication) {
        orig(application)
        BarController.shared.installIfNeeded()
    }
}
