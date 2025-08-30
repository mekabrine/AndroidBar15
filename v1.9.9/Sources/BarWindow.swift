import UIKit

final class BarController {
    static let shared = BarController()
    private var window: UIWindow?
    private var installed = false

    func installIfNeeded() {
        guard !installed else { return }
        installed = true

        let frame = UIScreen.main.bounds
        let win = PassthroughWindow(frame: frame)

        if #available(iOS 13.0, *) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                win.windowScene = scene
            }
        }

        win.windowLevel = UIWindow.Level.statusBar + 50
        win.isHidden = false

        let bar = NavBarView()
        win.addSubview(bar)
        bar.translatesAutoresizingMaskIntoConstraints = false
        let g = win.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 24),
            bar.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -24),
            bar.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -10),
            bar.heightAnchor.constraint(equalToConstant: 44)
        ])

        self.window = win
    }
}

final class PassthroughWindow: UIWindow {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for v in subviews where v.frame.insetBy(dx: -1, dy: -1).contains(point) { return true }
        return false
    }
}

final class NavBarView: UIBlurEffectViewHost {
    private let backBtn = UIButton(type: .system)
    private let homeBtn = UIButton(type: .system)
    private let switcherBtn = UIButton(type: .system)

    init() {
        super.init(effect: UIBlurEffect(style: .systemThickMaterialDark))
        layer.cornerRadius = 16
        layer.masksToBounds = true

        let stack = UIStackView(arrangedSubviews: [backBtn, homeBtn, switcherBtn])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.spacing = 36

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
        ])

        backBtn.setTitle("‹", for: .normal)
        backBtn.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .semibold)

        homeBtn.setTitle("●", for: .normal)
        homeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)

        switcherBtn.setTitle("▢", for: .normal)
        switcherBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)

        [backBtn, homeBtn, switcherBtn].forEach { btn in
            btn.tintColor = .white
            btn.setTitleColor(.white, for: .normal)
            btn.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func tapped(_ sender: UIButton) {
        Haptics.shared.tap()   // vibrate only
    }
}

// Simple wrapper so this compiles on older SDK naming (UIVisualEffectView subclass)
class UIBlurEffectViewHost: UIVisualEffectView {}
