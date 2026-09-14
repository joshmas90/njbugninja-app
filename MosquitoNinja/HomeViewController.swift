import UIKit

private final class NinjaGradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    override init(frame: CGRect) {
        super.init(frame: frame)

        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.94).cgColor,
            UIColor.black.withAlphaComponent(0.72).cgColor,
            UIColor.black.withAlphaComponent(0.22).cgColor
        ]
        gradientLayer.locations = [0, 0.7, 1]

        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        contentStack.layoutMargins.top = 12
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
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        let commercial = tappableCard(title: "Commercial & Government", detail: "Business, hospitality, municipal and government-managed outdoor properties.", symbol: "building.2.fill", page: "commercial.html", titleForPage: "Commercial & Government")
        [mosquito, ticks, commercial].forEach(contentStack.addArrangedSubview)

        contentStack.addArrangedSubview(sectionTitle("Quick Actions"))
        contentStack.addArrangedSubview(
            secondaryButton("Appointments", symbol: "calendar.badge.clock", action: #selector(openAppointments))
        )
        let actions = UIStackView(arrangedSubviews: [
            secondaryButton("Call", symbol: "phone.fill", action: #selector(call)),
            secondaryButton("Text", symbol: "message.fill", action: #selector(text))
        ])
        actions.axis = .horizontal
        actions.distribution = .fillEqually
        actions.spacing = 8
        contentStack.addArrangedSubview(actions)

        contentStack.addArrangedSubview(card(title: "Owner-operated", detail: "Your quote and treatment stay with one point of contact from the first conversation through service.", symbol: "person.crop.circle.badge.checkmark", accent: NinjaPalette.red))
    }

    private func ninjaHero() -> UIView {
        let hero = UIView()
        hero.translatesAutoresizingMaskIntoConstraints = false
        hero.backgroundColor = .black
        hero.layer.cornerRadius = 24
        hero.layer.cornerCurve = .continuous
        hero.layer.masksToBounds = true
        hero.layer.borderWidth = 1
        hero.layer.borderColor = UIColor.white.withAlphaComponent(0.09).cgColor

        hero.heightAnchor.constraint(greaterThanOrEqualToConstant: 400).isActive = true
        let preferredHeight = hero.heightAnchor.constraint(equalToConstant: 400)
        preferredHeight.priority = .defaultLow
        preferredHeight.isActive = true

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        // Text determines expansion; the artwork's pixel height must not size the card.
        imageView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)

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
        eyebrow.text = "MOSQUITOES. TICKS. CONSIDER THEM WARNED."
        eyebrow.textColor = UIColor.white.withAlphaComponent(0.85)
        eyebrow.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: .systemFont(ofSize: 12, weight: .bold))
        eyebrow.adjustsFontForContentSizeCategory = true
        eyebrow.numberOfLines = 0

        let headline = UILabel()
        headline.text = "THEY WON’T\nSEE US COMING."
        headline.textColor = .white
        headline.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: .systemFont(ofSize: 34, weight: .black))
        headline.adjustsFontForContentSizeCategory = true
        headline.numberOfLines = 0

        let detail = UILabel()
        detail.text = "Targeted mosquito & tick control for South Jersey residential, commercial and government properties."
        detail.textColor = UIColor.white.withAlphaComponent(0.88)
        detail.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: .systemFont(ofSize: 15, weight: .medium))
        detail.adjustsFontForContentSizeCategory = true
        detail.numberOfLines = 0

        let audience = UILabel()
        audience.text = "RESIDENTIAL - COMMERCIAL - GOVERNMENT"
        audience.textColor = NinjaPalette.green
        audience.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: .systemFont(ofSize: 11, weight: .bold), maximumPointSize: 14)
        audience.adjustsFontForContentSizeCategory = true
        audience.numberOfLines = 1
        audience.adjustsFontSizeToFitWidth = true
        audience.minimumScaleFactor = 0.5
        audience.accessibilityLabel = "Residential, Commercial, Government"

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
        stack.spacing = 12

        hero.addSubview(imageView)
        hero.addSubview(gradient)
        hero.addSubview(stack)

        // Use the available phone width; keep tablet text comfortably readable.
        let preferredTrailing = stack.trailingAnchor.constraint(equalTo: hero.trailingAnchor, constant: -24)
        preferredTrailing.priority = .defaultHigh

        NSLayoutConstraint.activate([
            audience.widthAnchor.constraint(equalTo: stack.widthAnchor),
            imageView.topAnchor.constraint(equalTo: hero.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: hero.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: hero.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: hero.bottomAnchor),

            gradient.topAnchor.constraint(equalTo: hero.topAnchor),
            gradient.leadingAnchor.constraint(equalTo: hero.leadingAnchor),
            gradient.trailingAnchor.constraint(equalTo: hero.trailingAnchor),
            gradient.bottomAnchor.constraint(equalTo: hero.bottomAnchor),

            stack.topAnchor.constraint(greaterThanOrEqualTo: hero.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: hero.leadingAnchor, constant: 24),
            stack.widthAnchor.constraint(lessThanOrEqualToConstant: 480),
            preferredTrailing,
            stack.trailingAnchor.constraint(
                lessThanOrEqualTo: hero.trailingAnchor,
                constant: -24
            ),
            stack.bottomAnchor.constraint(
                equalTo: hero.bottomAnchor,
                constant: -24
            )
        ])

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
        detail.text = "Add a confirmed service time for 24-hour and 1-hour reminders."
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
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.numberOfLines = 0
        let detailLabel = UILabel()
        detailLabel.text = detail
        detailLabel.textColor = NinjaPalette.muted
        detailLabel.font = .systemFont(ofSize: 14)
        detailLabel.numberOfLines = 0
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = UIColor.white.withAlphaComponent(0.45)

        let text = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        text.axis = .vertical; text.spacing = 4
        let row = UIStackView(arrangedSubviews: [icon, text, chevron])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal; row.alignment = .center; row.spacing = 14
        control.addSubview(row)
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 26), icon.heightAnchor.constraint(equalToConstant: 26),
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
    @objc private func openAppointments() { (tabBarController as? RootTabBarController)?.showAppointments() }
    @objc private func call() { openExternal("tel:+16093136317") }
    @objc private func text() { composeMessage() }
}
