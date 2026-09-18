import UIKit

private final class NinjaGradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
    private var isNarrow: Bool?

    override init(frame: CGRect) {
        super.init(frame: frame)

        isUserInteractionEnabled = false
        updateGradient(for: frame.width)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradient(for: bounds.width)
    }

    private func updateGradient(for width: CGFloat) {
        let narrow = width < 760
        guard isNarrow != narrow else { return }
        isNarrow = narrow

        // Leave the artwork clear above the copy on phones, and across the
        // right side on tablets. Contrast stays local to the text area.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if narrow {
            gradientLayer.colors = [
                UIColor.clear.cgColor,
                UIColor.black.withAlphaComponent(0.04).cgColor,
                UIColor.black.withAlphaComponent(0.64).cgColor
            ]
            gradientLayer.locations = [0, 0.40, 1]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        } else {
            gradientLayer.colors = [
                UIColor.black.withAlphaComponent(0.18).cgColor,
                UIColor.black.withAlphaComponent(0.04).cgColor,
                UIColor.clear.cgColor
            ]
            gradientLayer.locations = [0, 0.32, 0.72]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        }
        CATransaction.commit()
    }
}

private final class NinjaFocalImageView: UIImageView {
    var focalPoint = CGPoint(x: 0.5, y: 0.5) {
        didSet { setNeedsLayout() }
    }

    override var image: UIImage? {
        didSet { setNeedsLayout() }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard
            let image,
            bounds.width > 0,
            bounds.height > 0,
            image.size.width > 0,
            image.size.height > 0
        else {
            layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1)
            return
        }

        let viewAspect = bounds.width / bounds.height
        let imageAspect = image.size.width / image.size.height

        if imageAspect > viewAspect {
            let visibleWidth = viewAspect / imageAspect
            let originX = min(
                max(focalPoint.x - visibleWidth / 2, 0),
                1 - visibleWidth
            )

            layer.contentsRect = CGRect(
                x: originX,
                y: 0,
                width: visibleWidth,
                height: 1
            )
        } else {
            let visibleHeight = imageAspect / viewAspect
            let originY = min(
                max(focalPoint.y - visibleHeight / 2, 0),
                1 - visibleHeight
            )

            layer.contentsRect = CGRect(
                x: 0,
                y: originY,
                width: 1,
                height: visibleHeight
            )
        }
    }
}

private final class SpringBookingCardView: UIControl {
    override class var layerClass: AnyClass { CAGradientLayer.self }

    private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
    private let emberLayer = CAShapeLayer()
    private let energySweep = CAGradientLayer()
    private let rimPulse = CAShapeLayer()
    private let edgeSweep = CAGradientLayer()
    private let feedback = UIImpactFeedbackGenerator(style: .medium)
    private var lastLayoutSize = CGSize.zero

    override init(frame: CGRect) {
        super.init(frame: frame)

        gradientLayer.colors = [
            UIColor(red: 0.075, green: 0.09, blue: 0.078, alpha: 1).cgColor,
            UIColor(red: 0.035, green: 0.042, blue: 0.037, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        layer.cornerRadius = 22
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = NinjaPalette.red.withAlphaComponent(0.40).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.38
        layer.shadowRadius = 22
        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.masksToBounds = false

        emberLayer.fillColor = NinjaPalette.red.withAlphaComponent(0.11).cgColor
        emberLayer.shadowColor = NinjaPalette.red.cgColor
        emberLayer.shadowOpacity = 0.60
        emberLayer.shadowRadius = 28
        emberLayer.shadowOffset = .zero
        emberLayer.opacity = 0.56
        gradientLayer.insertSublayer(emberLayer, at: 0)

        energySweep.colors = [
            UIColor.clear.cgColor,
            NinjaPalette.red.withAlphaComponent(0.02).cgColor,
            NinjaPalette.red.withAlphaComponent(0.10).cgColor,
            UIColor(red: 1, green: 0.46, blue: 0.48, alpha: 0.22).cgColor,
            NinjaPalette.red.withAlphaComponent(0.08).cgColor,
            UIColor.clear.cgColor
        ]
        energySweep.locations = [0, 0.26, 0.42, 0.52, 0.62, 1]
        energySweep.startPoint = CGPoint(x: 0, y: 1)
        energySweep.endPoint = CGPoint(x: 1, y: 0)
        energySweep.cornerRadius = 22
        energySweep.masksToBounds = true
        energySweep.opacity = 0
        gradientLayer.addSublayer(energySweep)

        rimPulse.fillColor = UIColor.clear.cgColor
        rimPulse.strokeColor = NinjaPalette.red.withAlphaComponent(0.62).cgColor
        rimPulse.lineWidth = 1.4
        rimPulse.shadowColor = NinjaPalette.red.cgColor
        rimPulse.shadowOpacity = 0.60
        rimPulse.shadowRadius = 10
        rimPulse.shadowOffset = .zero
        rimPulse.opacity = 0.40
        gradientLayer.addSublayer(rimPulse)

        edgeSweep.colors = [
            UIColor.clear.cgColor,
            NinjaPalette.red.withAlphaComponent(0.62).cgColor,
            UIColor(red: 1, green: 0.62, blue: 0.64, alpha: 0.86).cgColor,
            NinjaPalette.red.withAlphaComponent(0.58).cgColor,
            UIColor.clear.cgColor
        ]
        edgeSweep.locations = [0, 0.28, 0.52, 0.74, 1]
        edgeSweep.startPoint = CGPoint(x: 0, y: 0.5)
        edgeSweep.endPoint = CGPoint(x: 1, y: 0.5)
        edgeSweep.shadowColor = NinjaPalette.red.cgColor
        edgeSweep.shadowOpacity = 0.70
        edgeSweep.shadowRadius = 9
        edgeSweep.opacity = 0
        gradientLayer.addSublayer(edgeSweep)

        isExclusiveTouch = true
        isAccessibilityElement = false
        addTarget(self, action: #selector(pressBegan), for: [.touchDown, .touchDragEnter])
        addTarget(
            self,
            action: #selector(pressEnded),
            for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit]
        )
        addTarget(self, action: #selector(successfulTap), for: .touchUpInside)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reduceMotionStatusChanged),
            name: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard
            !isHidden,
            isUserInteractionEnabled,
            alpha > 0.01,
            self.point(inside: point, with: event)
        else {
            return nil
        }

        let hitView = super.hitTest(point, with: event)
        var candidate = hitView

        // Preserve the Request, Call and Text controls. Every other visible
        // part of the card acts as one large Spring Service target.
        while let view = candidate, view !== self {
            if let control = view as? UIControl {
                return control
            }
            candidate = view.superview
        }

        return self
    }

    @objc private func pressBegan() {
        feedback.prepare()

        guard !UIAccessibility.isReduceMotionEnabled else {
            alpha = 0.94
            return
        }

        UIView.animate(
            withDuration: 0.10,
            delay: 0,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.transform = CGAffineTransform(scaleX: 0.992, y: 0.992)
            self.alpha = 0.94
        }
    }

    @objc private func pressEnded() {
        UIView.animate(
            withDuration: UIAccessibility.isReduceMotionEnabled ? 0.08 : 0.18,
            delay: 0,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.transform = .identity
            self.alpha = 1
        }
    }

    @objc private func successfulTap() {
        feedback.impactOccurred(intensity: 0.82)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0 else { return }

        emberLayer.frame = bounds
        let glowHeight = min(86, max(54, bounds.height * 0.27))
        let glowRect = CGRect(
            x: bounds.width * 0.02,
            y: bounds.height - glowHeight * 0.76,
            width: bounds.width * 0.96,
            height: glowHeight * 1.08
        )
        let glowPath = UIBezierPath(ovalIn: glowRect).cgPath
        emberLayer.path = glowPath
        emberLayer.shadowPath = glowPath

        let sizeChanged = lastLayoutSize != bounds.size
        let sweepWidth = max(142, bounds.width * 0.42)
        edgeSweep.bounds = CGRect(x: 0, y: 0, width: sweepWidth, height: 2.5)

        let energyWidth = max(190, bounds.width * 0.52)
        energySweep.bounds = CGRect(
            x: 0,
            y: 0,
            width: energyWidth,
            height: bounds.height
        )

        rimPulse.frame = bounds
        let rimPath = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 1.25, dy: 1.25),
            cornerRadius: max(0, layer.cornerRadius - 1.25)
        ).cgPath
        rimPulse.path = rimPath
        rimPulse.shadowPath = rimPath

        if sizeChanged {
            edgeSweep.position = CGPoint(x: -sweepWidth / 2, y: 0.75)
            energySweep.position = CGPoint(x: -energyWidth / 2, y: bounds.midY)
            lastLayoutSize = bounds.size
            updateAmbientMotion()
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        if window == nil {
            emberLayer.removeAllAnimations()
            energySweep.removeAllAnimations()
            rimPulse.removeAllAnimations()
            edgeSweep.removeAllAnimations()
        } else {
            setNeedsLayout()
            layoutIfNeeded()
            updateAmbientMotion()
        }
    }

    @objc private func reduceMotionStatusChanged() {
        updateAmbientMotion()
    }

    private func updateAmbientMotion() {
        guard bounds.width > 0, window != nil else { return }

        emberLayer.removeAllAnimations()
        energySweep.removeAllAnimations()
        rimPulse.removeAllAnimations()
        edgeSweep.removeAllAnimations()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        emberLayer.transform = CATransform3DIdentity

        if UIAccessibility.isReduceMotionEnabled {
            emberLayer.opacity = 0.50
            energySweep.opacity = 0.12
            energySweep.position.x = bounds.midX
            rimPulse.opacity = 0.54
            edgeSweep.opacity = 0.62
            edgeSweep.position.x = 22 + edgeSweep.bounds.width / 2
            CATransaction.commit()
            return
        }

        emberLayer.opacity = 0.56
        energySweep.opacity = 0
        energySweep.position.x = -energySweep.bounds.width / 2
        rimPulse.opacity = 0.38
        edgeSweep.opacity = 0
        edgeSweep.position.x = -edgeSweep.bounds.width / 2
        CATransaction.commit()

        let emberScale = CAKeyframeAnimation(keyPath: "transform.scale")
        emberScale.values = [0.90, 1.08, 0.96, 1.12]
        emberScale.keyTimes = [0, 0.36, 0.68, 1]

        let emberDrift = CAKeyframeAnimation(keyPath: "transform.translation.x")
        emberDrift.values = [-14, 5, 14, -5]
        emberDrift.keyTimes = [0, 0.36, 0.68, 1]

        let emberOpacity = CAKeyframeAnimation(keyPath: "opacity")
        emberOpacity.values = [0.40, 0.68, 0.46, 0.72]
        emberOpacity.keyTimes = [0, 0.36, 0.68, 1]

        let emberGroup = CAAnimationGroup()
        emberGroup.animations = [emberScale, emberDrift, emberOpacity]
        emberGroup.duration = 4.8
        emberGroup.autoreverses = true
        emberGroup.repeatCount = .infinity
        emberGroup.timingFunction = CAMediaTimingFunction(
            controlPoints: 0.45,
            0,
            0.20,
            1
        )
        emberLayer.add(emberGroup, forKey: "spring-ember")

        let energyPosition = CABasicAnimation(keyPath: "position.x")
        energyPosition.fromValue = -energySweep.bounds.width / 2
        energyPosition.toValue = bounds.width + energySweep.bounds.width / 2

        let energyOpacity = CAKeyframeAnimation(keyPath: "opacity")
        energyOpacity.values = [0, 0, 0.52, 0.20, 0, 0]
        energyOpacity.keyTimes = [0, 0.12, 0.28, 0.62, 0.78, 1]

        let energyGroup = CAAnimationGroup()
        energyGroup.animations = [energyPosition, energyOpacity]
        energyGroup.duration = 5.2
        energyGroup.beginTime = CACurrentMediaTime() + 0.55
        energyGroup.fillMode = .backwards
        energyGroup.repeatCount = .infinity
        energyGroup.timingFunction = CAMediaTimingFunction(
            controlPoints: 0.30,
            0,
            0.22,
            1
        )
        energySweep.add(energyGroup, forKey: "spring-energy-sweep")

        let rimOpacity = CAKeyframeAnimation(keyPath: "opacity")
        rimOpacity.values = [0.26, 0.76, 0.40, 0.66, 0.26]
        rimOpacity.keyTimes = [0, 0.22, 0.52, 0.74, 1]

        let rimWidth = CAKeyframeAnimation(keyPath: "lineWidth")
        rimWidth.values = [1.1, 2.0, 1.3, 1.7, 1.1]
        rimWidth.keyTimes = [0, 0.22, 0.52, 0.74, 1]

        let rimGroup = CAAnimationGroup()
        rimGroup.animations = [rimOpacity, rimWidth]
        rimGroup.duration = 3.8
        rimGroup.repeatCount = .infinity
        rimGroup.timingFunction = CAMediaTimingFunction(
            controlPoints: 0.45,
            0,
            0.25,
            1
        )
        rimPulse.add(rimGroup, forKey: "spring-rim-pulse")

        let sweepPosition = CABasicAnimation(keyPath: "position.x")
        sweepPosition.fromValue = -edgeSweep.bounds.width / 2
        sweepPosition.toValue = bounds.width + edgeSweep.bounds.width / 2
        sweepPosition.duration = 4.6

        let sweepOpacity = CAKeyframeAnimation(keyPath: "opacity")
        sweepOpacity.values = [0, 0, 0.82, 0.82, 0, 0]
        sweepOpacity.keyTimes = [0, 0.10, 0.20, 0.62, 0.74, 1]
        sweepOpacity.duration = 4.6

        let sweepGroup = CAAnimationGroup()
        sweepGroup.animations = [sweepPosition, sweepOpacity]
        sweepGroup.duration = 4.6
        sweepGroup.repeatCount = .infinity
        sweepGroup.timingFunction = CAMediaTimingFunction(
            controlPoints: 0.35,
            0,
            0.25,
            1
        )
        edgeSweep.add(sweepGroup, forKey: "spring-edge-sweep")
    }
}

final class HomeViewController: NinjaBaseViewController {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d 'at' h:mm a"
        return formatter
    }()

    private var isCheckingServiceArea = false
    private var serviceAreaResult: ServiceAreaResult?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mosquito Ninja"
        navigationItem.backButtonTitle = "Home"
        scrollView.contentInsetAdjustmentBehavior = .never
        contentStack.layoutMargins.top =
            traitCollection.userInterfaceIdiom == .pad ? 4 : 10
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refresh),
            name: .mosquitoNinjaAppointmentsDidChange,
            object: nil
        )
        buildUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // The iPad website-style header already occupies the first 82 points
        // beneath the system safe area. Keeping that inset on the navigation
        // controller and then pinning Home to its safe area creates a second
        // empty band above the hero. Apply the inset once, directly to Home.
        if traitCollection.userInterfaceIdiom == .pad {
            navigationController?.additionalSafeAreaInsets.top = 0
            additionalSafeAreaInsets.top = 82
        }

        navigationController?.setNavigationBarHidden(true, animated: animated)
        refresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if traitCollection.userInterfaceIdiom == .pad {
            additionalSafeAreaInsets.top = 0
            navigationController?.additionalSafeAreaInsets.top = 82
        }

        // Detail screens still need their title and Back button.
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func refresh() {
        for view in contentStack.arrangedSubviews {
            contentStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        buildUI()
    }

    private func buildUI() {
        contentStack.addArrangedSubview(ninjaHero())
        contentStack.addArrangedSubview(springBookingCard())
        contentStack.addArrangedSubview(serviceAreaCard())

        if let appointment = AppointmentStore.shared.nextAppointment {
            contentStack.addArrangedSubview(nextAppointmentCard(appointment))
        } else {
            contentStack.addArrangedSubview(addAppointmentCard())
        }

        let quote = primaryButton("Request a Quote", symbol: "doc.text.fill", action: #selector(openQuote))
        contentStack.addArrangedSubview(quote)

        contentStack.addArrangedSubview(sectionTitle("Services"))
        let mosquito = tappableCard(title: "Mosquito Control", detail: "Target resting and harborage areas around the property.", symbol: "drop.fill", page: "mosquito-control.html", titleForPage: "Mosquito Control")
        let ticks = tappableCard(title: "Tick Control", detail: "Focus on wooded edges, leaf litter, brush and transition zones.", symbol: "scope", page: "tick-control.html", titleForPage: "Tick Control")
        let flies = tappableCard(title: "Outdoor Fly Control", detail: "Source-focused service for house-fly and nuisance-fly pressure around exterior activity areas.", symbol: "ant.fill", page: "fly-control.html", titleForPage: "Outdoor Fly Control")
        let commercial = tappableCard(title: "Commercial & Government", detail: "Business, hospitality, municipal and government-managed outdoor properties.", symbol: "building.2.fill", page: "commercial.html", titleForPage: "Commercial & Government")
        [mosquito, ticks, flies, commercial].forEach(contentStack.addArrangedSubview)

        contentStack.addArrangedSubview(sectionTitle("Customer Tools"))
        contentStack.addArrangedSubview(
            secondaryButton("Appointments", symbol: "calendar.badge.clock", action: #selector(openAppointments))
        )

        contentStack.addArrangedSubview(card(title: "Owner-operated", detail: "Your quote and treatment stay with one point of contact from the first conversation through service.", symbol: "person.crop.circle.badge.checkmark", accent: NinjaPalette.red))
    }

    private func springBookingCard() -> UIView {
        let panel = SpringBookingCardView()
        panel.translatesAutoresizingMaskIntoConstraints = false
        panel.addTarget(
            self,
            action: #selector(openSpringQuote),
            for: .touchUpInside
        )
        panel.shouldGroupAccessibilityChildren = true

        let accent = UIView()
        accent.translatesAutoresizingMaskIntoConstraints = false
        accent.backgroundColor = NinjaPalette.red
        accent.layer.cornerRadius = 2
        accent.layer.shadowColor = NinjaPalette.red.cgColor
        accent.layer.shadowOpacity = 0.65
        accent.layer.shadowRadius = 7

        let signal = UIView()
        signal.translatesAutoresizingMaskIntoConstraints = false
        signal.backgroundColor = NinjaPalette.green
        signal.layer.cornerRadius = 4
        signal.layer.shadowColor = NinjaPalette.green.cgColor
        signal.layer.shadowOpacity = 0.55
        signal.layer.shadowRadius = 6

        let kicker = UILabel()
        kicker.text = "NOW ACCEPTING EARLY REQUESTS"
        kicker.textColor = NinjaPalette.green
        kicker.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(
            for: .systemFont(ofSize: 11, weight: .heavy),
            maximumPointSize: 14
        )
        kicker.adjustsFontForContentSizeCategory = true
        kicker.numberOfLines = 0

        let status = UIStackView(arrangedSubviews: [signal, kicker])
        status.axis = .horizontal
        status.alignment = .center
        status.spacing = 9

        let title = UILabel()
        title.text = "SPRING 2027\nSCHEDULING IS OPEN"
        title.textColor = .white
        title.font = UIFontMetrics(forTextStyle: .title1).scaledFont(
            for: .systemFont(ofSize: 28, weight: .black),
            maximumPointSize: 38
        )
        title.adjustsFontForContentSizeCategory = true
        title.numberOfLines = 0
        title.accessibilityTraits = .header

        let detail = UILabel()
        detail.text = "Plan ahead for the first spring outdoor pest-control routes. Mosquito, tick and targeted outdoor fly requests can be discussed together with the property details."
        detail.textColor = UIColor.white.withAlphaComponent(0.72)
        detail.font = .preferredFont(forTextStyle: .subheadline)
        detail.adjustsFontForContentSizeCategory = true
        detail.numberOfLines = 0

        let request = primaryButton(
            "Request Spring Service",
            symbol: "calendar.badge.plus",
            action: #selector(openSpringQuote)
        )

        let divider = UIView()
        divider.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let contactLabel = UILabel()
        contactLabel.text = "CALL OR TEXT DIRECTLY"
        contactLabel.textColor = UIColor.white.withAlphaComponent(0.56)
        contactLabel.font = .systemFont(ofSize: 10, weight: .heavy)

        let phone = UILabel()
        phone.text = "609-313-6317"
        phone.textColor = .white
        phone.font = UIFontMetrics(forTextStyle: .title2).scaledFont(
            for: .systemFont(ofSize: 22, weight: .black),
            maximumPointSize: 30
        )
        phone.adjustsFontForContentSizeCategory = true
        phone.accessibilityLabel = "609-313-6317"

        let phoneStack = UIStackView(arrangedSubviews: [contactLabel, phone])
        phoneStack.axis = .vertical
        phoneStack.spacing = 3

        let contactActions = UIStackView(arrangedSubviews: [
            secondaryButton("Call Now", symbol: "phone.fill", action: #selector(call)),
            secondaryButton("Text Us", symbol: "message.fill", action: #selector(text))
        ])
        contactActions.axis = .horizontal
        contactActions.distribution = .fillEqually
        contactActions.spacing = 10

        let stack = UIStackView(arrangedSubviews: [
            status,
            title,
            detail,
            request,
            divider,
            phoneStack,
            contactActions
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing =
            traitCollection.userInterfaceIdiom == .pad ? 10 : 14

        panel.addSubview(accent)
        panel.addSubview(stack)

        let panelVerticalInset: CGFloat =
            traitCollection.userInterfaceIdiom == .pad ? 18 : 22

        NSLayoutConstraint.activate([
            signal.widthAnchor.constraint(equalToConstant: 8),
            signal.heightAnchor.constraint(equalToConstant: 8),

            accent.topAnchor.constraint(equalTo: panel.topAnchor, constant: 20),
            accent.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            accent.widthAnchor.constraint(equalToConstant: 4),
            accent.heightAnchor.constraint(equalToConstant: 48),

            stack.topAnchor.constraint(
                equalTo: panel.topAnchor,
                constant: panelVerticalInset
            ),
            stack.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -22),
            stack.bottomAnchor.constraint(
                equalTo: panel.bottomAnchor,
                constant: -panelVerticalInset
            )
        ])

        panel.accessibilityIdentifier = "spring-2027-booking-card"
        return panel
    }

    private func ninjaHero() -> UIView {
        let hero = UIView()
        hero.translatesAutoresizingMaskIntoConstraints = false
        hero.backgroundColor = .black
        hero.layer.cornerRadius = 24
        hero.layer.cornerCurve = .continuous
        hero.layer.masksToBounds = true
        hero.layer.borderWidth = 1
        hero.layer.borderColor = UIColor.white.withAlphaComponent(0.16).cgColor
        hero.accessibilityIdentifier = "home-hero"

        let useWideHero =
            traitCollection.userInterfaceIdiom == .pad &&
            view.bounds.width >= 760

        let preferredHeroHeight: CGFloat =
            useWideHero ? 340 : 432

        hero.heightAnchor.constraint(
            greaterThanOrEqualToConstant: preferredHeroHeight
        ).isActive = true

        let preferredHeight = hero.heightAnchor.constraint(
            equalToConstant: preferredHeroHeight
        )
        preferredHeight.priority = .defaultLow
        preferredHeight.isActive = true

        let imageView = NinjaFocalImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.focalPoint = useWideHero
            ? CGPoint(x: 0.50, y: 0.47)
            : CGPoint(x: 0.45, y: 0.50)
        imageView.isAccessibilityElement = false
        // Text determines expansion; the artwork's pixel height must not size the card.
        imageView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
        imageView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)

        if let root = Bundle.main.resourceURL {
            let images = [
                root.appendingPathComponent("Web/assets/hero-v20.webp"),
                root.appendingPathComponent("Web/assets/hero-ninja.webp")
            ]

            for url in images {
                if let image = UIImage(contentsOfFile: url.path) {
                    imageView.image = image
                    break
                }
            }
        }

        let gradient = NinjaGradientView()
        gradient.translatesAutoresizingMaskIntoConstraints = false
        gradient.isUserInteractionEnabled = false

        let brand = UILabel()
        brand.text = "  MOSQUITO NINJA  "
        brand.textColor = .white
        brand.backgroundColor = NinjaPalette.red
        brand.font = .systemFont(ofSize: 11, weight: .black)
        brand.layer.cornerRadius = 4
        brand.layer.masksToBounds = true

        let eyebrow = UILabel()
        eyebrow.text = "MOSQUITOES. TICKS. FLIES. CONSIDER THEM WARNED."
        eyebrow.textColor = UIColor.white.withAlphaComponent(0.90)
        eyebrow.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: .systemFont(ofSize: 12, weight: .bold))
        eyebrow.adjustsFontForContentSizeCategory = true
        eyebrow.numberOfLines = 0
        eyebrow.layer.shadowColor = UIColor.black.cgColor
        eyebrow.layer.shadowOpacity = 0.72
        eyebrow.layer.shadowRadius = 3
        eyebrow.layer.shadowOffset = CGSize(width: 0, height: 1)

        let headline = UILabel()
        headline.text = "THEY WON’T\nSEE US COMING."
        headline.textColor = .white
        headline.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(
            for: .systemFont(
                ofSize: useWideHero ? 32 : 33,
                weight: .black
            )
        )
        headline.adjustsFontForContentSizeCategory = true
        headline.numberOfLines = 0
        headline.accessibilityTraits = .header
        headline.layer.shadowColor = UIColor.black.cgColor
        headline.layer.shadowOpacity = 0.70
        headline.layer.shadowRadius = 5
        headline.layer.shadowOffset = .zero

        let detail = UILabel()
        detail.text = "Targeted mosquito, tick & outdoor fly control for South Jersey residential, commercial and government properties."
        detail.textColor = UIColor.white.withAlphaComponent(0.92)
        detail.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: .systemFont(ofSize: 15, weight: .medium))
        detail.adjustsFontForContentSizeCategory = true
        detail.numberOfLines = 0
        detail.layer.shadowColor = UIColor.black.cgColor
        detail.layer.shadowOpacity = 0.65
        detail.layer.shadowRadius = 4
        detail.layer.shadowOffset = .zero

        let audience = UILabel()
        audience.text = "MOSQUITO   TICK   OUTDOOR FLY"
        audience.textColor = NinjaPalette.green
        audience.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: .systemFont(ofSize: 11, weight: .bold), maximumPointSize: 14)
        audience.adjustsFontForContentSizeCategory = true
        audience.numberOfLines = 0
        audience.lineBreakMode = .byWordWrapping
        audience.accessibilityLabel = "Mosquito control, Tick control, Outdoor fly control"
        audience.layer.shadowColor = UIColor.black.cgColor
        audience.layer.shadowOpacity = 0.80
        audience.layer.shadowRadius = 3
        audience.layer.shadowOffset = CGSize(width: 0, height: 1)

        [brand, eyebrow, headline, detail, audience].forEach {
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
        }

        let stack = UIStackView(arrangedSubviews: [
            brand,
            eyebrow,
            headline,
            detail,
            audience
        ])

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = useWideHero ? 10 : 11

        hero.addSubview(imageView)
        hero.addSubview(gradient)
        hero.addSubview(stack)

        var heroConstraints: [NSLayoutConstraint] = [
            audience.widthAnchor.constraint(equalTo: stack.widthAnchor),

            gradient.topAnchor.constraint(equalTo: hero.topAnchor),
            gradient.leadingAnchor.constraint(equalTo: hero.leadingAnchor),
            gradient.trailingAnchor.constraint(equalTo: hero.trailingAnchor),
            gradient.bottomAnchor.constraint(equalTo: hero.bottomAnchor),

            stack.topAnchor.constraint(greaterThanOrEqualTo: hero.topAnchor, constant: 22),
            stack.leadingAnchor.constraint(equalTo: hero.leadingAnchor, constant: 24),
            stack.widthAnchor.constraint(lessThanOrEqualToConstant: 480),
            stack.trailingAnchor.constraint(
                lessThanOrEqualTo: hero.trailingAnchor,
                constant: -24
            )
        ]

        if useWideHero {
            // Give the iPad hero a deliberate two-zone composition instead of
            // bottom-anchoring the copy and over-extending the artwork above the
            // card. This keeps the copy centered in the dark pane while the face
            // and shoulder mark stay visible in the image pane.
            heroConstraints += [
                imageView.topAnchor.constraint(equalTo: hero.topAnchor),
                imageView.trailingAnchor.constraint(equalTo: hero.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: hero.bottomAnchor),
                imageView.widthAnchor.constraint(
                    equalTo: hero.widthAnchor,
                    multiplier: 0.64
                ),

                stack.trailingAnchor.constraint(
                    lessThanOrEqualTo: imageView.leadingAnchor,
                    constant: -26
                ),
                stack.centerYAnchor.constraint(equalTo: hero.centerYAnchor),
                stack.bottomAnchor.constraint(
                    lessThanOrEqualTo: hero.bottomAnchor,
                    constant: -22
                )
            ]
        } else {
            // On iPhone, keep the artwork full bleed but bias the crop slightly
            // left in source space, which moves the ninja/shoulder emblem toward
            // the right side and gives the copy cleaner visual territory.
            heroConstraints += [
                imageView.topAnchor.constraint(equalTo: hero.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: hero.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: hero.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: hero.bottomAnchor),

                stack.bottomAnchor.constraint(
                    equalTo: hero.bottomAnchor,
                    constant: -24
                )
            ]
        }

        NSLayoutConstraint.activate(heroConstraints)

        return hero
    }

    private func nextAppointmentCard(_ appointment: ServiceAppointment) -> UIControl {
        let control = NinjaTouchControl()
        control.backgroundColor = NinjaPalette.panel
        control.layer.cornerRadius = 18
        control.layer.cornerCurve = .continuous
        control.layer.borderWidth = 1
        control.layer.borderColor = NinjaPalette.red.withAlphaComponent(0.38).cgColor
        control.accessibilityTraits = .button
        control.accessibilityLabel = "Upcoming appointment \(dateFormatter.string(from: appointment.startDate))"

        let icon = UIImageView(image: UIImage(systemName: "calendar.badge.clock"))
        icon.tintColor = NinjaPalette.red
        icon.translatesAutoresizingMaskIntoConstraints = false

        let kicker = UILabel()
        kicker.text = "UPCOMING SERVICE"
        kicker.textColor = NinjaPalette.green
        kicker.font = .systemFont(ofSize: 11, weight: .heavy)

        let date = UILabel()
        date.text = dateFormatter.string(from: appointment.startDate).uppercased()
        date.textColor = .white
        date.font = .systemFont(ofSize: 17, weight: .black)
        date.numberOfLines = 0

        let service = UILabel()
        service.text = appointment.service.displayName
        service.textColor = NinjaPalette.muted
        service.font = .systemFont(ofSize: 14, weight: .medium)

        let labels = UIStackView(arrangedSubviews: [kicker, date, service])
        labels.axis = .vertical
        labels.spacing = 4

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = UIColor.white.withAlphaComponent(0.42)

        let row = UIStackView(arrangedSubviews: [icon, labels, chevron])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 14
        control.addSubview(row)
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 28),
            icon.heightAnchor.constraint(equalToConstant: 28),
            row.topAnchor.constraint(equalTo: control.topAnchor, constant: 17),
            row.leadingAnchor.constraint(equalTo: control.leadingAnchor, constant: 17),
            row.trailingAnchor.constraint(equalTo: control.trailingAnchor, constant: -17),
            row.bottomAnchor.constraint(equalTo: control.bottomAnchor, constant: -17)
        ])
        control.addAction(UIAction { [weak self] _ in self?.openAppointments() }, for: .touchUpInside)
        return control
    }

    private func addAppointmentCard() -> UIControl {
        let control = NinjaTouchControl()
        control.backgroundColor = NinjaPalette.panel
        control.layer.cornerRadius = 18
        control.layer.cornerCurve = .continuous
        control.layer.borderWidth = 0.5
        control.layer.borderColor = UIColor.white.withAlphaComponent(0.10).cgColor

        let icon = UIImageView(image: UIImage(systemName: "bell.badge.fill"))
        icon.tintColor = NinjaPalette.green
        icon.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = "APPOINTMENT REMINDERS"
        title.textColor = .white
        title.font = .systemFont(ofSize: 14, weight: .bold)

        let detail = UILabel()
        detail.text = "After Mosquito Ninja confirms the visit, save the service time for 24-hour and 1-hour reminders."
        detail.textColor = NinjaPalette.muted
        detail.font = .systemFont(ofSize: 13)
        detail.numberOfLines = 0

        let labels = UIStackView(arrangedSubviews: [title, detail])
        labels.axis = .vertical
        labels.spacing = 4

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = UIColor.white.withAlphaComponent(0.42)

        let row = UIStackView(arrangedSubviews: [icon, labels, chevron])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 14
        control.addSubview(row)
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 26),
            icon.heightAnchor.constraint(equalToConstant: 26),
            row.topAnchor.constraint(equalTo: control.topAnchor, constant: 16),
            row.leadingAnchor.constraint(equalTo: control.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: control.trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: control.bottomAnchor, constant: -16)
        ])
        control.addAction(UIAction { [weak self] _ in self?.openAppointments() }, for: .touchUpInside)
        return control
    }

    private func tappableCard(title: String, detail: String, symbol: String, page: String, titleForPage: String) -> UIControl {
        let control = NinjaTouchControl()
        control.backgroundColor = NinjaPalette.panel
        control.layer.cornerRadius = 16
        control.layer.cornerCurve = .continuous
        control.layer.borderWidth = 0.5
        control.layer.borderColor = UIColor.white.withAlphaComponent(0.10).cgColor
        control.accessibilityTraits = .button
        control.accessibilityLabel = title

        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.tintColor = NinjaPalette.green
        icon.translatesAutoresizingMaskIntoConstraints = false
        let titleLabel = UILabel()
        titleLabel.text = title.uppercased()
        titleLabel.textColor = .white
        titleLabel.font = UIFontMetrics(forTextStyle: .headline).scaledFont(
            for: .systemFont(ofSize: 15, weight: .bold)
        )
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        let detailLabel = UILabel()
        detailLabel.text = detail
        detailLabel.textColor = NinjaPalette.muted
        detailLabel.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(
            for: .systemFont(ofSize: 14)
        )
        detailLabel.adjustsFontForContentSizeCategory = true
        detailLabel.numberOfLines = 0
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = UIColor.white.withAlphaComponent(0.45)

        let text = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        text.axis = .vertical
        text.spacing = 4
        let row = UIStackView(arrangedSubviews: [icon, text, chevron])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 14
        control.addSubview(row)
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 26),
            icon.heightAnchor.constraint(equalToConstant: 26),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            row.topAnchor.constraint(equalTo: control.topAnchor, constant: 16),
            row.leadingAnchor.constraint(equalTo: control.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: control.trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: control.bottomAnchor, constant: -16)
        ])
        control.addAction(UIAction { [weak self] _ in
            let destination: UIViewController
            if let service = NinjaService(page: page) {
                destination = ServiceDetailViewController(service: service)
            } else {
                destination = WebViewController(page: page, title: titleForPage)
            }
            self?.navigationController?.pushViewController(destination, animated: true)
        }, for: .touchUpInside)
        return control
    }

    private func serviceAreaCard() -> UIControl {
        let control = NinjaTouchControl()

        control.backgroundColor = NinjaPalette.panel
        control.layer.cornerRadius = 18
        control.layer.cornerCurve = .continuous
        control.layer.borderWidth = 1

        let titleText: String
        let detailText: String
        let symbol: String
        let accent: UIColor

        if isCheckingServiceArea {
            titleText = "CHECKING YOUR LOCATION..."
            detailText =
                "Finding your county and ZIP and checking current coverage. This can take a few seconds."
            symbol = "location.fill"
            accent = NinjaPalette.green

        } else if let result = serviceAreaResult {
            switch result.coverage {
            case .covered:
                titleText = "YOU'RE IN OUR SERVICE AREA"
                symbol = "checkmark.seal.fill"
                accent = NinjaPalette.green

            case .confirm:
                titleText = "ROUTE CONFIRMATION NEEDED"
                symbol = "location.circle.fill"
                accent = NinjaPalette.green

            case .outside:
                titleText = "OUTSIDE OUR CURRENT SERVICE AREA"
                symbol = "xmark.circle.fill"
                accent = NinjaPalette.red
            }

            let locationText = [
                result.county,
                result.postalCode
            ]
            .compactMap { value -> String? in
                guard let value = value, !value.isEmpty else {
                    return nil
                }

                return value
            }
            .joined(separator: " | ")

            if locationText.isEmpty {
                detailText = result.message
            } else {
                detailText =
                    locationText + "\n" + result.message
            }

        } else {
            titleText = "CHECK MY SERVICE AREA"
            detailText =
                "Use your current location for an instant county and ZIP coverage check."
            symbol = "location.circle.fill"
            accent = NinjaPalette.green
        }

        control.layer.borderColor =
            accent.withAlphaComponent(0.42).cgColor

        control.accessibilityTraits = .button
        control.accessibilityLabel = titleText
        control.accessibilityValue =
            isCheckingServiceArea
            ? "Checking current location and service coverage"
            : detailText
        control.isUserInteractionEnabled =
            !isCheckingServiceArea

        let leadingView: UIView

        if isCheckingServiceArea {
            let loader = NinjaActivityIndicator(frame: .zero)
            loader.translatesAutoresizingMaskIntoConstraints = false
            loader.startAnimating()
            leadingView = loader
        } else {
            let icon = UIImageView(
                image: UIImage(systemName: symbol)
            )
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.tintColor = accent
            icon.contentMode = .scaleAspectFit
            leadingView = icon
        }

        let title = UILabel()
        title.text = titleText
        title.textColor = .white
        title.font = .systemFont(
            ofSize: 14,
            weight: .heavy
        )
        title.numberOfLines = 0

        let detail = UILabel()
        detail.text = detailText
        detail.textColor = NinjaPalette.muted
        detail.font = .systemFont(ofSize: 13)
        detail.numberOfLines = 0

        let labels = UIStackView(
            arrangedSubviews: [title, detail]
        )

        labels.axis = .vertical
        labels.spacing = 5

        let chevron = UIImageView(
            image: UIImage(systemName: "chevron.right")
        )

        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor =
            UIColor.white.withAlphaComponent(0.42)
        chevron.isHidden = isCheckingServiceArea

        let row = UIStackView(
            arrangedSubviews: [
                leadingView,
                labels,
                chevron
            ]
        )

        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 14

        control.addSubview(row)

        NSLayoutConstraint.activate([
            leadingView.widthAnchor.constraint(
                equalToConstant: 28
            ),

            leadingView.heightAnchor.constraint(
                equalToConstant: 28
            ),

            chevron.widthAnchor.constraint(
                equalToConstant: 12
            ),

            row.topAnchor.constraint(
                equalTo: control.topAnchor,
                constant: 16
            ),

            row.leadingAnchor.constraint(
                equalTo: control.leadingAnchor,
                constant: 16
            ),

            row.trailingAnchor.constraint(
                equalTo: control.trailingAnchor,
                constant: -16
            ),

            row.bottomAnchor.constraint(
                equalTo: control.bottomAnchor,
                constant: -16
            )
        ])

        control.addAction(
            UIAction { [weak self] _ in
                self?.checkServiceArea()
            },
            for: .touchUpInside
        )

        return control
    }

    private func checkServiceArea() {
        guard !isCheckingServiceArea else {
            return
        }

        serviceAreaResult = nil
        isCheckingServiceArea = true
        refresh()

        ServiceAreaManager.shared.checkCurrentLocation {
            [weak self] result in

            guard let self = self else {
                return
            }

            self.isCheckingServiceArea = false

            switch result {
            case .success(let areaResult):
                self.serviceAreaResult = areaResult

                self.refresh()

                switch areaResult.coverage {
                case .covered:
                    self.showFeedback(
                        title: "Coverage Confirmed",
                        detail: "Your current location is inside our normal service area.",
                        kind: .success,
                        duration: 1.65
                    )

                case .confirm:
                    self.showFeedback(
                        title: "Route Confirmation Needed",
                        detail: "This location may be serviceable. Contact Mosquito Ninja so we can confirm the route and schedule.",
                        kind: .info,
                        duration: 2.0
                    )

                case .outside:
                    self.showFeedback(
                        title: "Outside Normal Coverage",
                        detail: "This location is outside our normal service area. Contact us if you would like us to review the route.",
                        kind: .warning,
                        duration: 2.0
                    )
                }

            case .failure(let error):
                self.serviceAreaResult = nil
                self.refresh()

                if let serviceError =
                    error as? ServiceAreaError {

                    switch serviceError {
                    case .permissionDenied:
                        NinjaHaptics.warning()
                        self.showLocationSettingsAlert()

                    case .locationUnavailable,
                         .geocodingFailed:
                        NinjaHaptics.warning()
                        self.showServiceAreaError(
                            serviceError.localizedDescription
                        )
                    }

                } else {
                    NinjaHaptics.warning()
                    self.showServiceAreaError(
                        error.localizedDescription
                    )
                }
            }
        }
    }

    private func showLocationSettingsAlert() {
        let alert = UIAlertController(
            title: "Location Access Is Off",
            message:
                "Mosquito Ninja uses your location only when you choose to check the service area. To continue, open Settings, allow Location While Using the App, then return and tap Check My Service Area again. Your precise coordinates are not stored by Mosquito Ninja.",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Not Now",
                style: .cancel
            )
        )

        alert.addAction(
            UIAlertAction(
                title: "Open Settings",
                style: .default
            ) { _ in
                guard let url = URL(
                    string:
                        UIApplication.openSettingsURLString
                ) else {
                    return
                }

                UIApplication.shared.open(url)
            }
        )

        present(alert, animated: true)
    }

    private func showServiceAreaError(
        _ message: String
    ) {
        let alert = UIAlertController(
            title: "Service Area Check Didn't Finish",
            message:
                message +
                "\n\nCheck your connection and location availability, then try again.",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )

        alert.addAction(
            UIAlertAction(
                title: "Try Again",
                style: .default
            ) { [weak self] _ in
                self?.checkServiceArea()
            }
        )

        present(alert, animated: true)
    }

    @objc private func openQuote() { (tabBarController as? RootTabBarController)?.showQuote() }
    @objc private func openSpringQuote() { (tabBarController as? RootTabBarController)?.showQuote(spring2027: true) }
    @objc private func openAppointments() { (tabBarController as? RootTabBarController)?.showAppointments() }
    @objc private func call() { openExternal("tel:+16093136317") }
    @objc private func text() { composeMessage() }
}
