import UIKit

struct NinjaPalette {
    static let ink = UIColor(red: 0.025, green: 0.03, blue: 0.027, alpha: 1)
    static let panel = UIColor(red: 0.055, green: 0.065, blue: 0.058, alpha: 1)
    static let paper = UIColor(red: 0.953, green: 0.937, blue: 0.898, alpha: 1)
    static let red = UIColor(red: 0.878, green: 0.125, blue: 0.153, alpha: 1)
    static let green = UIColor(red: 0.561, green: 0.741, blue: 0.180, alpha: 1)
    static let muted = UIColor.white.withAlphaComponent(0.68)
}


final class NinjaActivityIndicator: UIView {
    private let ring = CAShapeLayer()
    private var running = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        isUserInteractionEnabled = false

        ring.fillColor = UIColor.clear.cgColor
        ring.strokeColor = NinjaPalette.red.cgColor
        ring.lineWidth = 2.6
        ring.lineCap = .round
        ring.strokeStart = 0.08
        ring.strokeEnd = 0.76
        ring.shadowColor = NinjaPalette.red.cgColor
        ring.shadowOpacity = 0.38
        ring.shadowRadius = 4

        layer.addSublayer(ring)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        ring.frame = bounds
        ring.path = UIBezierPath(
            ovalIn: bounds.insetBy(dx: 3, dy: 3)
        ).cgPath
    }

    func startAnimating() {
        guard !running else { return }
        running = true

        let animation = CABasicAnimation(
            keyPath: "transform.rotation.z"
        )
        animation.fromValue = 0
        animation.toValue = Double.pi * 2
        animation.duration = 0.82
        animation.repeatCount = .infinity
        animation.timingFunction =
            CAMediaTimingFunction(name: .linear)

        layer.add(animation, forKey: "ninjaSpin")
    }

    func stopAnimating() {
        running = false
        layer.removeAnimation(forKey: "ninjaSpin")
    }
}

enum NinjaFeedbackKind {
    case success
    case warning
    case error
    case info

    var symbol: String {
        switch self {
        case .success:
            return "checkmark.seal.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .error:
            return "xmark.octagon.fill"
        case .info:
            return "info.circle.fill"
        }
    }

    var accent: UIColor {
        switch self {
        case .success:
            return NinjaPalette.green
        case .warning:
            return NinjaPalette.red
        case .error:
            return NinjaPalette.red
        case .info:
            return UIColor.white
        }
    }
}

enum NinjaHaptics {
    static func impact(
        _ style: UIImpactFeedbackGenerator.FeedbackStyle = .light,
        intensity: CGFloat = 0.72
    ) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
}

final class NinjaTouchControl: UIControl {
    private let feedback = UIImpactFeedbackGenerator(style: .light)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureInteraction()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureInteraction()
    }

    private func configureInteraction() {
        isExclusiveTouch = true
        accessibilityTraits.insert(.button)

        addTarget(
            self,
            action: #selector(pressBegan),
            for: [.touchDown, .touchDragEnter]
        )

        addTarget(
            self,
            action: #selector(pressEnded),
            for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit]
        )

        addTarget(
            self,
            action: #selector(successfulTap),
            for: .touchUpInside
        )
    }

    override func point(
        inside point: CGPoint,
        with event: UIEvent?
    ) -> Bool {
        return bounds.contains(point)
    }

    override func hitTest(
        _ location: CGPoint,
        with event: UIEvent?
    ) -> UIView? {
        guard
            !isHidden,
            isUserInteractionEnabled,
            alpha > 0.01,
            self.point(inside: location, with: event)
        else {
            return nil
        }

        // The entire visible card is one touch target.
        // Labels, icons and chevrons never steal the gesture.
        return self
    }

    @objc private func pressBegan() {
        feedback.prepare()

        UIView.animate(
            withDuration: 0.08,
            delay: 0,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.transform = CGAffineTransform(scaleX: 0.985, y: 0.985)
            self.alpha = 0.88
        }
    }

    @objc private func pressEnded() {
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.transform = .identity
            self.alpha = 1
        }
    }

    @objc private func successfulTap() {
        feedback.impactOccurred(intensity: 0.80)
    }
}

final class NinjaButton: UIButton {
    var hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light {
        didSet {
            feedback = nil
        }
    }

    private var feedback: UIImpactFeedbackGenerator?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureInteraction()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureInteraction()
    }

    private func configureInteraction() {
        isExclusiveTouch = true

        addTarget(
            self,
            action: #selector(pressBegan),
            for: [.touchDown, .touchDragEnter]
        )

        addTarget(
            self,
            action: #selector(pressEnded),
            for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit]
        )

        addTarget(
            self,
            action: #selector(successfulTap),
            for: .touchUpInside
        )
    }

    override func point(
        inside point: CGPoint,
        with event: UIEvent?
    ) -> Bool {
        let expanded = bounds.insetBy(dx: -4, dy: -6)
        return expanded.contains(point)
    }

    @objc private func pressBegan() {
        let generator = UIImpactFeedbackGenerator(style: hapticStyle)
        generator.prepare()
        feedback = generator

        UIView.animate(
            withDuration: 0.07,
            delay: 0,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.transform = CGAffineTransform(scaleX: 0.975, y: 0.975)
            self.alpha = 0.86
        }
    }

    @objc private func pressEnded() {
        UIView.animate(
            withDuration: 0.14,
            delay: 0,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.transform = .identity
            self.alpha = 1
        }
    }

    @objc private func successfulTap() {
        if feedback == nil {
            feedback = UIImpactFeedbackGenerator(style: hapticStyle)
        }

        feedback?.impactOccurred(
            intensity: hapticStyle == .medium ? 0.90 : 0.72
        )

        feedback = nil
    }
}
final class NinjaScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl {
            return true
        }

        return super.touchesShouldCancel(in: view)
    }
}

class NinjaBaseViewController: UIViewController {
    let scrollView = NinjaScrollView()
    let contentStack = UIStackView()
    private let messageComposer = MessageComposer()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = NinjaPalette.ink
        configureScroll()
    }

    private func configureScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.delaysContentTouches = true
        scrollView.canCancelContentTouches = true
        scrollView.decelerationRate = .normal
        view.addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 18
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 22, left: 20, bottom: 34, right: 20)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    func eyebrow(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.textColor = NinjaPalette.red
        label.font = .systemFont(ofSize: 12, weight: .heavy)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }

    func headline(_ text: String, size: CGFloat = 40) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.textColor = .white
        label.font = .systemFont(ofSize: size, weight: .black)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = false
        return label
    }

    func body(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = NinjaPalette.muted
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }

    func sectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 0
        return label
    }

    func primaryButton(_ title: String, symbol: String? = nil, action: Selector) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title.uppercased()
        config.baseBackgroundColor = NinjaPalette.red
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
        if let symbol { config.image = UIImage(systemName: symbol); config.imagePadding = 8 }
        let button = NinjaButton(frame: .zero)
        button.layer.cornerCurve = .continuous
        button.configuration = config
        button.hapticStyle = .medium
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .heavy)
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    func secondaryButton(_ title: String, symbol: String? = nil, action: Selector) -> UIButton {
        var config = UIButton.Configuration.gray()
        config.title = title.uppercased()
        config.baseBackgroundColor = NinjaPalette.panel
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
        if let symbol { config.image = UIImage(systemName: symbol); config.imagePadding = 8 }
        let button = NinjaButton(frame: .zero)
        button.layer.cornerCurve = .continuous
        button.configuration = config
        button.hapticStyle = .light
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    func card(title: String, detail: String, symbol: String, accent: UIColor = NinjaPalette.green) -> UIView {
        let container = UIView()
        container.backgroundColor = NinjaPalette.panel
        container.layer.cornerRadius = 16
        container.layer.cornerCurve = .continuous
        container.layer.borderWidth = 0.75
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.10).cgColor

        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = accent
        icon.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = title.uppercased()
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.numberOfLines = 0

        let detailLabel = UILabel()
        detailLabel.text = detail
        detailLabel.textColor = NinjaPalette.muted
        detailLabel.font = .systemFont(ofSize: 14)
        detailLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let row = UIStackView(arrangedSubviews: [icon, textStack])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 14
        container.addSubview(row)

        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 26),
            icon.heightAnchor.constraint(equalToConstant: 26),
            row.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        return container
    }

    func composeMessage(body: String = "", kind: MessageComposer.Kind = .text) {
        messageComposer.present(from: self, body: body, kind: kind)
    }

    func openExternal(_ value: String) {
        guard let url = URL(string: value) else {
            showFeedback(
                title: "Unable to Open",
                detail: "That action could not be prepared. Please try again.",
                kind: .error
            )
            return
        }

        if url.scheme?.lowercased() == "sms" {
            messageComposer.present(from: self, smsURL: url)
            return
        }

        UIApplication.shared.open(
            url,
            options: [:]
        ) { [weak self] success in
            guard !success else { return }

            DispatchQueue.main.async {
                self?.showFeedback(
                    title: "Unable to Open",
                    detail: "iOS could not open that action. Check your device settings and try again.",
                    kind: .error
                )
            }
        }
    }
}

// Shared in-app status feedback, including MessageUI completion results.
extension UIViewController {
    func showFeedback(
        title: String,
        detail: String,
        kind: NinjaFeedbackKind,
        duration: TimeInterval = 1.25,
        completion: (() -> Void)? = nil
    ) {
        let banner = UIView()
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.backgroundColor = NinjaPalette.panel
        banner.layer.cornerRadius = 17
        banner.layer.cornerCurve = .continuous
        banner.layer.borderWidth = 1
        banner.layer.borderColor =
            kind.accent.withAlphaComponent(0.44).cgColor
        banner.isAccessibilityElement = true
        banner.accessibilityLabel = "\(title). \(detail)"
        banner.alpha = 0
        banner.transform =
            CGAffineTransform(
                translationX: 0,
                y: 18
            )

        let icon = UIImageView(
            image: UIImage(systemName: kind.symbol)
        )
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = kind.accent
        icon.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = title.uppercased()
        titleLabel.textColor = .white
        titleLabel.font =
            .systemFont(ofSize: 13, weight: .heavy)
        titleLabel.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: titleLabel.font)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0

        let detailLabel = UILabel()
        detailLabel.text = detail
        detailLabel.textColor = NinjaPalette.muted
        detailLabel.font =
            .systemFont(ofSize: 12, weight: .medium)
        detailLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: detailLabel.font)
        detailLabel.adjustsFontForContentSizeCategory = true
        detailLabel.numberOfLines = 0

        let labels = UIStackView(
            arrangedSubviews: [
                titleLabel,
                detailLabel
            ]
        )
        labels.axis = .vertical
        labels.spacing = 3

        let row = UIStackView(
            arrangedSubviews: [
                icon,
                labels
            ]
        )
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12

        banner.addSubview(row)
        view.addSubview(banner)

        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(
                equalToConstant: 25
            ),
            icon.heightAnchor.constraint(
                equalToConstant: 25
            ),

            row.topAnchor.constraint(
                equalTo: banner.topAnchor,
                constant: 14
            ),
            row.leadingAnchor.constraint(
                equalTo: banner.leadingAnchor,
                constant: 15
            ),
            row.trailingAnchor.constraint(
                equalTo: banner.trailingAnchor,
                constant: -15
            ),
            row.bottomAnchor.constraint(
                equalTo: banner.bottomAnchor,
                constant: -14
            ),

            banner.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 18
            ),
            banner.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -18
            ),
            banner.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -14
            )
        ])

        view.bringSubviewToFront(banner)
        UIAccessibility.post(notification: .announcement, argument: banner.accessibilityLabel)

        switch kind {
        case .success:
            NinjaHaptics.success()
        case .warning, .error:
            NinjaHaptics.warning()
        case .info:
            NinjaHaptics.selection()
        }

        UIView.animate(
            withDuration: UIAccessibility.isReduceMotionEnabled ? 0 : 0.24,
            delay: 0,
            usingSpringWithDamping: 0.84,
            initialSpringVelocity: 0.3,
            options: [.curveEaseOut]
        ) {
            banner.alpha = 1
            banner.transform = .identity
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + duration
        ) {
            UIView.animate(
                withDuration: UIAccessibility.isReduceMotionEnabled ? 0 : 0.20,
                animations: {
                    banner.alpha = 0
                    banner.transform =
                        CGAffineTransform(
                            translationX: 0,
                            y: 12
                        )
                }
            ) { _ in
                banner.removeFromSuperview()
                completion?()
            }
        }
    }

}
