import UIKit

private final class NinjaGradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    override init(frame: CGRect) {
        super.init(frame: frame)

        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.88).cgColor,
            UIColor.black.withAlphaComponent(0.42).cgColor,
            UIColor.clear.cgColor
        ]

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
        formatter.dateFormat = "EEE, MMM d \\u{2022} h:mm a"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mosquito Ninja"
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
        refresh()
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
        let actions = UIStackView(arrangedSubviews: [
            secondaryButton("Appointments", symbol: "calendar.badge.clock", action: #selector(openAppointments)),
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
        hero.layer.masksToBounds = true
        hero.layer.borderWidth = 1
        hero.layer.borderColor = UIColor.white.withAlphaComponent(0.09).cgColor

        hero.heightAnchor.constraint(equalToConstant: 340).isActive = true

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

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
        eyebrow.textColor = NinjaPalette.red
        eyebrow.font = .systemFont(ofSize: 10, weight: .heavy)
        eyebrow.numberOfLines = 0

        let headline = UILabel()
        headline.text = "THEY WON’T\nSEE US COMING."
        headline.textColor = .white
        headline.font = .systemFont(ofSize: 38, weight: .black)
        headline.numberOfLines = 0
        headline.adjustsFontSizeToFitWidth = true
        headline.minimumScaleFactor = 0.78

        let detail = UILabel()
        detail.text = "Targeted mosquito & tick control for South Jersey residential, commercial and government properties."
        detail.textColor = UIColor.white.withAlphaComponent(0.78)
        detail.font = .systemFont(ofSize: 14, weight: .medium)
        detail.numberOfLines = 0

        let audience = UILabel()
        audience.text = "RESIDENTIAL  \\u{2022}  COMMERCIAL  \\u{2022}  GOVERNMENT"
        audience.textColor = NinjaPalette.green
        audience.font = .systemFont(ofSize: 10, weight: .heavy)
        audience.numberOfLines = 0
        audience.adjustsFontSizeToFitWidth = true
        audience.minimumScaleFactor = 0.78

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
        stack.spacing = 10

        hero.addSubview(imageView)
        hero.addSubview(gradient)
        hero.addSubview(stack)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: hero.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: hero.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: hero.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: hero.bottomAnchor),

            gradient.topAnchor.constraint(equalTo: hero.topAnchor),
            gradient.leadingAnchor.constraint(equalTo: hero.leadingAnchor),
            gradient.trailingAnchor.constraint(equalTo: hero.trailingAnchor),
            gradient.bottomAnchor.constraint(equalTo: hero.bottomAnchor),

            stack.leadingAnchor.constraint(equalTo: hero.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(
                lessThanOrEqualTo: hero.trailingAnchor,
                constant: -90
            ),
            stack.bottomAnchor.constraint(
                equalTo: hero.bottomAnchor,
                constant: -22
            )
        ])

        return hero
    }
    private func nextAppointmentCard(_ appointment: ServiceAppointment) -> UIControl {
        let control = NinjaTouchControl()
        control.backgroundColor = NinjaPalette.panel
        control.layer.cornerRadius = 18
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
            self?.navigationController?.pushViewController(WebViewController(page: page, title: titleForPage), animated: true)
        }, for: .touchUpInside)
        return control
    }

    @objc private func openQuote() { tabBarController?.selectedIndex = 3 }
    @objc private func openAppointments() { (tabBarController as? RootTabBarController)?.showAppointments() }
    @objc private func call() { openExternal("tel:+16093136317") }
    @objc private func text() { openExternal("sms:+16093136317") }
}
