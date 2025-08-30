import Orion
import UIKit

private let kPrefsDomain = "space.mekabrine.androidbar15.swift"
private let kAskedRespringKey = "askedRespringOnce"

class UIApplication_SBHook: ClassHook<UIApplication> {
    func _run() {
        BarController.shared.installIfNeeded()
        promptRespringIfNeeded()
        orig()
    }
}

private func promptRespringIfNeeded() {
    let domain = kPrefsDomain as CFString
    let key = kAskedRespringKey as CFString
    let asked = (CFPreferencesCopyAppValue(key, domain) as? Bool) ?? false
    guard !asked else { return }

    CFPreferencesSetAppValue(key, true as CFBoolean, domain)
    CFPreferencesAppSynchronize(domain)

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        presentRespringAlert()
    }
}

private func presentRespringAlert() {
    let alert = UIAlertController(title: "AndroidBar15",
                                  message: "Installation complete. Respring now to finish setup?",
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Later", style: .cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "Respring", style: .destructive, handler: { _ in
        respring()
    }))

    presentAlertOnTop(alert)
}

private func presentAlertOnTop(_ vc: UIViewController) {
    let w = UIWindow(frame: UIScreen.main.bounds)
    if #available(iOS 13.0, *) {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            w.windowScene = scene
        }
    }
    w.windowLevel = UIWindow.Level.alert + 1
    w.isHidden = false
    let host = UIViewController()
    w.rootViewController = host
    host.present(vc, animated: true, completion: nil)
    objc_setAssociatedObject(host, Unmanaged.passUnretained(w).toOpaque(), w, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}

private func respring() {
    let sbreload = "/var/jb/usr/bin/sbreload"
    if FileManager.default.isExecutableFile(atPath: sbreload) {
        let t = Process()
        t.launchPath = sbreload
        t.launch()
    } else {
        let k = Process()
        k.launchPath = "/usr/bin/killall"
        k.arguments = ["-9", "SpringBoard"]
        k.launch()
    }
}
