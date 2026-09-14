import UIKit
import UserNotifications

@main
final class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = RootTabBarController()
        window.tintColor = UIColor(red: 0.878, green: 0.125, blue: 0.153, alpha: 1)
        window.makeKeyAndVisible()
        self.window = window

        let launchOverlay = NinjaLaunchOverlay(frame: window.bounds)
        launchOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(launchOverlay)
        launchOverlay.play()

        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        DispatchQueue.main.async { [weak self] in
            (self?.window?.rootViewController as? RootTabBarController)?.showAppointments()
            completionHandler()
        }
    }
}

private final class NinjaLaunchOverlay: UIView {
    private let mark = UIImageView(image: UIImage(named: "LaunchMark"))
    private let brand = UILabel()
    private let detail = UILabel()
    private let slash = CAShapeLayer()
    private let glow = CAShapeLayer()
    private var hasPlayed = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor(red: 0.025, green: 0.03, blue: 0.027, alpha: 1)

        mark.contentMode = .scaleAspectFit
        addSubview(mark)

        brand.text = "MOSQUITO NINJA"
        brand.textAlignment = .center
        brand.textColor = .white
        brand.font = .systemFont(ofSize: 19, weight: .black)
        brand.alpha = 0
        addSubview(brand)

        detail.text = "MOSQUITOES. TICKS. CONSIDER THEM WARNED."
        detail.textAlignment = .center
        detail.textColor = UIColor.white.withAlphaComponent(0.52)
        detail.font = .systemFont(ofSize: 9, weight: .heavy)
        detail.alpha = 0
        addSubview(detail)

        let red = UIColor(red: 0.878, green: 0.125, blue: 0.153, alpha: 1)

        glow.fillColor = UIColor.clear.cgColor
        glow.strokeColor = red.withAlphaComponent(0.62).cgColor
        glow.lineWidth = 16
        glow.lineCap = .round
        glow.shadowColor = red.cgColor
        glow.shadowOpacity = 0.95
        glow.shadowRadius = 18
        glow.strokeEnd = 0
        layer.addSublayer(glow)

        slash.fillColor = UIColor.clear.cgColor
        slash.strokeColor = red.cgColor
        slash.lineWidth = 5
        slash.lineCap = .round
        slash.shadowColor = red.cgColor
        slash.shadowOpacity = 0.55
        slash.shadowRadius = 5
        slash.strokeEnd = 0
        layer.addSublayer(slash)

        accessibilityViewIsModal = true
        accessibilityLabel = "Mosquito Ninja"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let size = min(bounds.width * 0.645, 276)
        let top = bounds.midY - (size * 0.58)
        let left = bounds.midX - (size / 2)

        mark.frame = CGRect(x: left, y: top, width: size, height: size)
        brand.frame = CGRect(x: 24, y: top + size + 21, width: bounds.width - 48, height: 26)
        detail.frame = CGRect(x: 24, y: brand.frame.maxY + 5, width: bounds.width - 48, height: 18)

        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.midX - (size * 0.72), y: top + (size * 0.92)))
        path.addLine(to: CGPoint(x: bounds.midX + (size * 0.72), y: top + (size * 0.08)))
        glow.path = path.cgPath
        slash.path = path.cgPath
    }

    func play() {
        guard !hasPlayed else { return }
        hasPlayed = true
        layoutIfNeeded()

        if UIAccessibility.isReduceMotionEnabled {
            brand.alpha = 1
            detail.alpha = 1
            glow.strokeEnd = 1
            slash.strokeEnd = 1
            UIView.animate(withDuration: 0.35, delay: 0.28, options: [.curveEaseOut]) {
                self.alpha = 0
            } completion: { _ in
                self.removeFromSuperview()
            }
            return
        }

        mark.alpha = 0
        mark.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)

        UIView.animate(
            withDuration: 0.36,
            delay: 0,
            usingSpringWithDamping: 0.78,
            initialSpringVelocity: 0.42,
            options: [.curveEaseOut]
        ) {
            self.mark.alpha = 1
            self.mark.transform = .identity
            self.brand.alpha = 1
            self.detail.alpha = 1
        }

        let glowAnimation = CABasicAnimation(keyPath: "strokeEnd")
        glowAnimation.fromValue = 0
        glowAnimation.toValue = 1
        glowAnimation.duration = 0.34
        glowAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        glow.strokeEnd = 1
        glow.add(glowAnimation, forKey: "slashGlow")

        let slashAnimation = CABasicAnimation(keyPath: "strokeEnd")
        slashAnimation.fromValue = 0
        slashAnimation.toValue = 1
        slashAnimation.duration = 0.30
        slashAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        slash.strokeEnd = 1
        slash.add(slashAnimation, forKey: "slash")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            NinjaHaptics.impact(.medium, intensity: 0.90)
        }

        UIView.animate(
            withDuration: 0.30,
            delay: 2.20,
            options: [.curveEaseIn]
        ) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}
