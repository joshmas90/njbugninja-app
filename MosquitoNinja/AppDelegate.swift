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
    private enum Palette {
        static let background = UIColor(red: 0.008, green: 0.016, blue: 0.012, alpha: 1)
        static let red = UIColor(red: 0.878, green: 0.125, blue: 0.153, alpha: 1)
        static let green = UIColor(red: 0.561, green: 0.741, blue: 0.180, alpha: 1)
    }

    private let stage = UIView()
    private let redHaze = CAGradientLayer()
    private let greenHaze = CAGradientLayer()
    private let aura = CAShapeLayer()
    private let burst = CAShapeLayer()
    private let orbit = CAShapeLayer()
    private let redOrb = CAShapeLayer()
    private let greenOrb = CAShapeLayer()
    private let mark = UIImageView(image: UIImage(named: "LaunchMark"))
    private let strikeGlow = CAShapeLayer()
    private let strike = CAShapeLayer()
    private let strikeTip = CAShapeLayer()
    private let wordmark = UIImageView(image: UIImage(named: "SplashWordmark"))
    private let wordmarkMask = CAShapeLayer()
    private var hasPlayed = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = Palette.background
        isUserInteractionEnabled = true
        isAccessibilityElement = true
        accessibilityViewIsModal = true
        accessibilityLabel = "Mosquito Ninja. Bite Back."

        configureHaze(
            redHaze,
            color: Palette.red,
            peakAlpha: 0.23,
            center: CGPoint(x: 0.50, y: 0.47)
        )
        layer.addSublayer(redHaze)

        configureHaze(
            greenHaze,
            color: Palette.green,
            peakAlpha: 0.07,
            center: CGPoint(x: 0.50, y: 0.52)
        )
        layer.addSublayer(greenHaze)

        stage.isUserInteractionEnabled = false
        addSubview(stage)

        configureCircle(aura, color: Palette.red.withAlphaComponent(0.18), lineWidth: 0)
        aura.shadowColor = Palette.red.cgColor
        aura.shadowOpacity = 0.68
        aura.shadowRadius = 54
        aura.opacity = 0
        stage.layer.addSublayer(aura)

        configureCircle(burst, color: Palette.red.withAlphaComponent(0.72), lineWidth: 1)
        burst.fillColor = UIColor.clear.cgColor
        burst.shadowColor = Palette.red.cgColor
        burst.shadowOpacity = 0.50
        burst.shadowRadius = 18
        burst.opacity = 0
        stage.layer.addSublayer(burst)

        configureCircle(orbit, color: UIColor.white.withAlphaComponent(0.14), lineWidth: 1)
        orbit.fillColor = UIColor.clear.cgColor
        orbit.opacity = 0
        stage.layer.addSublayer(orbit)

        redOrb.fillColor = Palette.red.cgColor
        redOrb.shadowColor = Palette.red.cgColor
        redOrb.shadowOpacity = 0.95
        redOrb.shadowRadius = 7
        orbit.addSublayer(redOrb)

        greenOrb.fillColor = Palette.green.cgColor
        greenOrb.shadowColor = Palette.green.cgColor
        greenOrb.shadowOpacity = 0.90
        greenOrb.shadowRadius = 7
        orbit.addSublayer(greenOrb)

        mark.contentMode = .scaleAspectFit
        mark.alpha = 0
        mark.layer.shadowColor = UIColor.black.cgColor
        mark.layer.shadowOpacity = 0.72
        mark.layer.shadowRadius = 24
        mark.layer.shadowOffset = CGSize(width: 0, height: 18)
        stage.addSubview(mark)

        configureStrike(strikeGlow, width: 18, opacity: 0.46)
        configureStrike(strike, width: 7, opacity: 1)
        stage.layer.addSublayer(strikeGlow)
        stage.layer.addSublayer(strike)

        strikeTip.fillColor = UIColor.white.cgColor
        strikeTip.shadowColor = Palette.red.cgColor
        strikeTip.shadowOpacity = 1
        strikeTip.shadowRadius = 15
        strikeTip.opacity = 0
        stage.layer.addSublayer(strikeTip)

        wordmark.contentMode = .scaleAspectFit
        wordmark.alpha = 0
        wordmark.layer.shadowColor = Palette.red.cgColor
        wordmark.layer.shadowOpacity = 0.22
        wordmark.layer.shadowRadius = 14
        wordmark.layer.mask = wordmarkMask
        addSubview(wordmark)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Mirrors the website splash: an oversized mark with a wide wordmark
        // tucked directly beneath it. Compact height prevents landscape crop.
        let compactHeight = bounds.height < 560
        let markSize = compactHeight
            ? min(bounds.height * 0.58, bounds.width * 0.52)
            : min(bounds.width * 0.88, 370)
        let wordmarkWidth = compactHeight
            ? min(bounds.width * 0.68, 460)
            : min(bounds.width * 0.96, 610)
        let wordmarkHeight = wordmarkWidth * (361.0 / 1080.0)
        let overlap: CGFloat = compactHeight ? 28 : 34
        let totalHeight = markSize + wordmarkHeight - overlap
        let stageTop = bounds.midY - (totalHeight / 2) - (compactHeight ? 0 : bounds.height * 0.02)

        stage.frame = CGRect(x: bounds.midX - markSize / 2, y: stageTop, width: markSize, height: markSize)
        mark.frame = stage.bounds
        wordmark.frame = CGRect(
            x: bounds.midX - wordmarkWidth / 2,
            y: stage.frame.maxY - overlap,
            width: wordmarkWidth,
            height: wordmarkHeight
        )

        redHaze.frame = bounds.insetBy(dx: -bounds.width * 0.24, dy: -bounds.height * 0.24)
        greenHaze.frame = bounds
        [aura, burst, orbit, strikeGlow, strike, strikeTip].forEach { layer in
            layer.frame = stage.bounds
        }

        let center = CGPoint(x: markSize / 2, y: markSize / 2)
        aura.path = UIBezierPath(ovalIn: stage.bounds.insetBy(dx: markSize * 0.13, dy: markSize * 0.13)).cgPath
        burst.path = UIBezierPath(ovalIn: stage.bounds.insetBy(dx: markSize * 0.08, dy: markSize * 0.08)).cgPath
        orbit.path = UIBezierPath(ovalIn: stage.bounds.insetBy(dx: 0.5, dy: 0.5)).cgPath

        let redSize = max(6, markSize * 0.019)
        redOrb.path = UIBezierPath(ovalIn: CGRect(x: markSize * 0.105, y: markSize * 0.145, width: redSize, height: redSize)).cgPath
        let greenSize = max(5, markSize * 0.014)
        greenOrb.path = UIBezierPath(ovalIn: CGRect(x: markSize * 0.915, y: markSize * 0.745, width: greenSize, height: greenSize)).cgPath

        // This is deliberately mark-local. It sits on the logo's existing
        // prohibition bar instead of spanning the screen behind the artwork.
        let angle = -38.0 * CGFloat.pi / 180.0
        let halfLength = markSize * 0.27
        let strikeCenter = CGPoint(x: center.x, y: markSize * 0.466)
        let delta = CGPoint(x: cos(angle) * halfLength, y: sin(angle) * halfLength)
        let start = CGPoint(x: strikeCenter.x - delta.x, y: strikeCenter.y - delta.y)
        let end = CGPoint(x: strikeCenter.x + delta.x, y: strikeCenter.y + delta.y)
        let strikePath = UIBezierPath()
        strikePath.move(to: start)
        strikePath.addLine(to: end)
        strikeGlow.path = strikePath.cgPath
        strike.path = strikePath.cgPath
        strikeGlow.lineWidth = max(13, markSize * 0.049)
        strike.lineWidth = max(6, markSize * 0.021)

        let tipRadius = max(10, markSize * 0.036)
        strikeTip.path = UIBezierPath(
            ovalIn: CGRect(x: end.x - tipRadius, y: end.y - tipRadius, width: tipRadius * 2, height: tipRadius * 2)
        ).cgPath

        wordmarkMask.frame = wordmark.bounds
        wordmarkMask.path = UIBezierPath(rect: wordmark.bounds).cgPath
    }

    func play() {
        guard !hasPlayed else { return }
        hasPlayed = true
        setNeedsLayout()
        layoutIfNeeded()

        if UIAccessibility.isReduceMotionEnabled {
            showReducedMotionSplash()
            return
        }

        animateAtmosphere()
        animateMark()
        animateStrike()
        animateWordmark()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.90) {
            NinjaHaptics.impact(.medium, intensity: 0.90)
        }

        UIView.animate(
            withDuration: 0.36,
            delay: 2.50,
            options: [.curveEaseIn, .beginFromCurrentState]
        ) {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 1.025, y: 1.025)
        } completion: { _ in
            self.removeFromSuperview()
        }
    }

    private func configureCircle(_ layer: CAShapeLayer, color: UIColor, lineWidth: CGFloat) {
        layer.fillColor = color.cgColor
        layer.strokeColor = color.cgColor
        layer.lineWidth = lineWidth
    }

    private func configureHaze(
        _ layer: CAGradientLayer,
        color: UIColor,
        peakAlpha: CGFloat,
        center: CGPoint
    ) {
        layer.type = .radial
        layer.colors = [
            color.withAlphaComponent(peakAlpha).cgColor,
            color.withAlphaComponent(peakAlpha * 0.32).cgColor,
            UIColor.clear.cgColor
        ]
        layer.locations = [0, 0.34, 0.72]
        layer.startPoint = center
        layer.endPoint = CGPoint(x: 0.94, y: 0.94)
        layer.opacity = 0
    }

    private func configureStrike(_ layer: CAShapeLayer, width: CGFloat, opacity: Float) {
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = Palette.red.withAlphaComponent(CGFloat(opacity)).cgColor
        layer.lineWidth = width
        layer.lineCap = .round
        layer.shadowColor = Palette.red.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = width
        layer.strokeEnd = 0
    }

    private func animateAtmosphere() {
        redHaze.opacity = 1
        animateScale(redHaze, values: [0.52, 1], keyTimes: [0, 1], duration: 1.30, delay: 0)
        animateOpacity(redHaze, values: [0, 1], keyTimes: [0, 1], duration: 0.82, delay: 0)

        greenHaze.opacity = 0.70
        animateOpacity(greenHaze, values: [0, 0.70], keyTimes: [0, 1], duration: 1.05, delay: 0.10)

        aura.opacity = 0.82
        animateScale(aura, values: [0.28, 1.18, 1.0], keyTimes: [0, 0.55, 1], duration: 1.50, delay: 0.04)
        animateOpacity(aura, values: [0, 1, 0.82], keyTimes: [0, 0.55, 1], duration: 1.50, delay: 0.04)

        burst.opacity = 0
        animateScale(burst, values: [0.25, 1.72], keyTimes: [0, 1], duration: 0.84, delay: 0.65)
        animateOpacity(burst, values: [0, 0.72, 0], keyTimes: [0, 0.24, 1], duration: 0.84, delay: 0.65)

        orbit.opacity = 0.38
        orbit.transform = CATransform3DMakeRotation(36 * .pi / 180, 0, 0, 1)
        let orbitTransform = CAKeyframeAnimation(keyPath: "transform")
        orbitTransform.values = [
            CATransform3DConcat(CATransform3DMakeScale(0.48, 0.48, 1), CATransform3DMakeRotation(-130 * .pi / 180, 0, 0, 1)),
            CATransform3DConcat(CATransform3DMakeScale(1, 1, 1), CATransform3DMakeRotation(36 * .pi / 180, 0, 0, 1))
        ]
        orbitTransform.duration = 1.45
        orbitTransform.beginTime = CACurrentMediaTime() + 0.06
        orbitTransform.fillMode = .backwards
        orbitTransform.timingFunction = CAMediaTimingFunction(controlPoints: 0.16, 0.78, 0.18, 1)
        orbit.add(orbitTransform, forKey: "orbitTransform")
        animateOpacity(orbit, values: [0, 0.8, 0.38], keyTimes: [0, 0.42, 1], duration: 1.45, delay: 0.06)
    }

    private func animateMark() {
        mark.alpha = 1

        let transformAnimation = CAKeyframeAnimation(keyPath: "transform")
        transformAnimation.values = [
            CATransform3DConcat(CATransform3DMakeScale(0.32, 0.32, 1), CATransform3DMakeRotation(-72 * .pi / 180, 0, 0, 1)),
            CATransform3DConcat(CATransform3DMakeScale(1.10, 1.10, 1), CATransform3DMakeRotation(4 * .pi / 180, 0, 0, 1)),
            CATransform3DConcat(CATransform3DMakeScale(0.97, 0.97, 1), CATransform3DMakeRotation(-1.2 * .pi / 180, 0, 0, 1)),
            CATransform3DIdentity
        ]
        transformAnimation.keyTimes = [0, 0.46, 0.72, 1]
        transformAnimation.duration = 1.02
        transformAnimation.beginTime = CACurrentMediaTime() + 0.08
        transformAnimation.fillMode = .backwards
        transformAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.14, 0.76, 0.18, 1)
        mark.layer.add(transformAnimation, forKey: "markEntrance")

        animateOpacity(mark.layer, values: [0, 1, 1], keyTimes: [0, 0.46, 1], duration: 1.02, delay: 0.08)
    }

    private func animateStrike() {
        let beginTime = CACurrentMediaTime() + 0.72
        [strikeGlow, strike].forEach { layer in
            layer.strokeEnd = 1
            let draw = CABasicAnimation(keyPath: "strokeEnd")
            draw.fromValue = 0
            draw.toValue = 1
            draw.duration = 0.62
            draw.beginTime = beginTime
            draw.fillMode = .backwards
            draw.timingFunction = CAMediaTimingFunction(controlPoints: 0.14, 0.72, 0.18, 1)
            layer.add(draw, forKey: "strikeDraw")

            let fade = CAKeyframeAnimation(keyPath: "opacity")
            fade.values = [0, 1, 1, 0]
            fade.keyTimes = [0, 0.12, 0.72, 1]
            fade.duration = 0.62
            fade.beginTime = beginTime
            layer.opacity = 0
            layer.add(fade, forKey: "strikeFade")
        }

        strikeTip.opacity = 0
        animateScale(strikeTip, values: [0.20, 1, 1.70], keyTimes: [0, 0.35, 1], duration: 0.52, delay: 0.78)
        animateOpacity(strikeTip, values: [0, 1, 0], keyTimes: [0, 0.35, 1], duration: 0.52, delay: 0.78)
    }

    private func animateWordmark() {
        wordmark.alpha = 1

        let transformAnimation = CAKeyframeAnimation(keyPath: "transform")
        transformAnimation.values = [
            CATransform3DConcat(CATransform3DMakeTranslation(0, 18, 0), CATransform3DMakeScale(0.92, 0.92, 1)),
            CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(1.025, 1.025, 1)),
            CATransform3DIdentity
        ]
        transformAnimation.keyTimes = [0, 0.72, 1]
        transformAnimation.duration = 0.86
        transformAnimation.beginTime = CACurrentMediaTime() + 0.98
        transformAnimation.fillMode = .backwards
        transformAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.16, 0.82, 0.2, 1)
        wordmark.layer.add(transformAnimation, forKey: "wordmarkEntrance")
        animateOpacity(wordmark.layer, values: [0, 1, 1], keyTimes: [0, 0.48, 1], duration: 0.86, delay: 0.98)

        let startRect = CGRect(x: wordmark.bounds.midX - 1, y: 0, width: 2, height: wordmark.bounds.height)
        let reveal = CABasicAnimation(keyPath: "path")
        reveal.fromValue = UIBezierPath(rect: startRect).cgPath
        reveal.toValue = UIBezierPath(rect: wordmark.bounds).cgPath
        reveal.duration = 0.86
        reveal.beginTime = CACurrentMediaTime() + 0.98
        reveal.fillMode = .backwards
        reveal.timingFunction = CAMediaTimingFunction(controlPoints: 0.16, 0.82, 0.2, 1)
        wordmarkMask.add(reveal, forKey: "wordmarkReveal")
    }

    private func showReducedMotionSplash() {
        mark.alpha = 1
        redHaze.opacity = 1
        greenHaze.opacity = 0.70
        aura.opacity = 0.82
        orbit.opacity = 0.38
        wordmark.alpha = 1
        strikeGlow.opacity = 0
        strike.opacity = 0
        strikeTip.opacity = 0

        UIView.animate(withDuration: 0.20, delay: 0.50, options: [.curveEaseOut]) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }

    private func animateScale(
        _ layer: CALayer,
        values: [CGFloat],
        keyTimes: [NSNumber],
        duration: CFTimeInterval,
        delay: CFTimeInterval
    ) {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = values
        animation.keyTimes = keyTimes
        animation.duration = duration
        animation.beginTime = CACurrentMediaTime() + delay
        animation.fillMode = .backwards
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.16, 0.84, 0.2, 1)
        layer.setValue(values.last ?? CGFloat(1), forKeyPath: "transform.scale")
        layer.add(animation, forKey: "scale")
    }

    private func animateOpacity(
        _ layer: CALayer,
        values: [Float],
        keyTimes: [NSNumber],
        duration: CFTimeInterval,
        delay: CFTimeInterval
    ) {
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values = values
        animation.keyTimes = keyTimes
        animation.duration = duration
        animation.beginTime = CACurrentMediaTime() + delay
        animation.fillMode = .backwards
        layer.opacity = values.last ?? 1
        layer.add(animation, forKey: "opacity")
    }
}
