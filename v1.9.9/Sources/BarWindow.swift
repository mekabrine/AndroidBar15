//
//  BarWindow.swift
//

import UIKit
import CoreHaptics

final class BarController {
    static let shared = BarController()
    private var window: UIWindow?
    private var installed = false

    func installIfNeeded(inSpringBoard: Bool) {
        guard Preferences.shared.isEnabled else { return }
        guard !installed else { return }
        installed = true

        // Create a dedicated window that floats above content.
        let win = PassthroughWindow(frame: UIScreen.main.bounds)
        if #available(iOS 13.0, *) {
            // Put on the active scene if possible
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                win.windowScene = scene
            }
        }
        // Window level: above status bar and alerts, but below Siri.
        win.windowLevel = UIWindow.Level(3000)
        win.isHidden = false

        // Build the bar view
        let bar = NavBarView()
        win.addSubview(bar)

        // Autolayout: pin left/right/bottom respecting safe area.
        bar.translatesAutoresizingMaskIntoConstraints = false
        let g = win.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            bar.bottomAnchor.constraint(equalTo: g.bottomAnchor),
            bar.heightAnchor.constraint(equalToConstant: CGFloat(Preferences.shared.barHeight))
        ])

        self.window = win
    }
}

final class PassthroughWindow: UIWindow {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Only capture touches that hit our bar view; everything else passes through.
        for v in subviews {
            if v.frame.contains(point) { return true }
        }
        return false
    }
}

final class NavBarView: UIVisualEffectView {
    private let backBtn = UIButton(type: .custom)
    private let homeBtn = UIButton(type: .custom)
    private let switcherBtn = UIButton(type: .custom)

    init() {
        let style: UIBlurEffect.Style = Preferences.shared.colouringStyle == 0 ? .systemUltraThinMaterialDark : .systemThinMaterial
        super.init(effect: UIBlurEffect(style: style))
        layer.masksToBounds = true
        layer.cornerRadius = 16

        // Background color tint
        backgroundColor = Preferences.shared.barColour

        // Layout stack
        let stack = UIStackView(arrangedSubviews: [backBtn, homeBtn, switcherBtn])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.spacing = 36
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
        ])

        // Icons
        applyTheme()

        // Actions
        backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        homeBtn.addTarget(self, action: #selector(homeTapped), for: .touchUpInside)
        switcherBtn.addTarget(self, action: #selector(switcherTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func applyTheme() {
        let theme = Preferences.shared.themeName
        func img(_ name: String) -> UIImage? {
            // /var/jb/Library/Application Support/AndroidBar15/Themes/<Theme>/<name>.png
            let base = "/var/jb/Library/Application Support/AndroidBar15/Themes/" + theme + "/"
            return UIImage(contentsOfFile: base + name + ".png")
        }
        backBtn.setImage(img("back"), for: .normal)
        homeBtn.setImage(img("home"), for: .normal)
        switcherBtn.setImage(img("switcher"), for: .normal)

        backBtn.tintColor = Preferences.shared.backColour
        homeBtn.tintColor = Preferences.shared.homeColour
        switcherBtn.tintColor = Preferences.shared.switcherColour

        // Make the images render as template if colouring requested
        let templated = (Preferences.shared.colouringStyle != 2)
        [backBtn, homeBtn, switcherBtn].forEach { b in
            b.adjustsImageWhenHighlighted = true
            if templated, let img = b.image(for: .normal) {
                b.setImage(img.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }
    }

    private func haptic() {
        Haptics.shared.tap()
    }

    @objc private func backTapped() {
        haptic()
        Actions.perform(.back)
    }

    @objc private func homeTapped() {
        haptic()
        Actions.perform(.home)
    }

    @objc private func switcherTapped() {
        haptic()
        Actions.perform(.switcher)
    }
}

enum Actions {
    case back, home, switcher

    static func perform(_ a: Actions) {
        #if canImport(SpringBoardServices)
        // Attempt to call private SpringBoard selectors dynamically (avoids hard dependencies).
        if let cls = NSClassFromString("SBMainSwitcherViewController") as AnyObject?,
           let shared = (cls as? NSObject.Type)?.perform(NSSelectorFromString("sharedInstance"))?.takeUnretainedValue() as AnyObject? {
            if a == .switcher {
                _ = shared.perform(NSSelectorFromString("toggleSwitcher"))
                return
            }
        }
        if let uiCtrl = NSClassFromString("SBUIController") as AnyObject?,
           let shared = (uiCtrl as? NSObject.Type)?.perform(NSSelectorFromString("sharedInstance"))?.takeUnretainedValue() as AnyObject? {
            switch a {
            case .home:
                _ = shared.perform(NSSelectorFromString("clickedMenuButton"))
                return
            case .switcher:
                _ = shared.perform(NSSelectorFromString("toggleSwitcher"))
                return
            case .back:
                break
            }
        }
        #endif

        // Fallbacks for app processes: try popping a nav controller or simulating ESC key.
        if a == .back {
            if let win = UIApplication.shared.keyWindowOrFirst,
               let nav = win.rootViewController?.nearestNavigationController {
                nav.popViewController(animated: true)
                return
            }
        }
        if a == .home {
            // Attempt to send user to SpringBoard (background app).
            UIApplication.shared.performSelector(onMainThread: NSSelectorFromString("suspend"), with: nil, waitUntilDone: false)
        }
        if a == .switcher {
            // No reliable public fallback; do nothing.
        }
    }
}

private extension UIApplication {
    var keyWindowOrFirst: UIWindow? {
        if #available(iOS 13.0, *) {
            return connectedScenes.compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow }) ?? windows.first
        } else {
            return keyWindow ?? windows.first
        }
    }
}

private extension UIViewController {
    var nearestNavigationController: UINavigationController? {
        if let n = self as? UINavigationController { return n }
        if let n = self.navigationController { return n }
        if let p = self.presentedViewController { return p.nearestNavigationController }
        if let c = self.children.first { return c.nearestNavigationController }
        return nil
    }
}
