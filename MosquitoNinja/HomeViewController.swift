import UIKit

final class HomeViewController: NinjaBaseViewController {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d • h:mm a"
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
        contentStack.addArrangedSubview(eyebrow("South Jersey mosquito & tick control"))
        contentStack.addArrangedSubview(headline("Your outdoor space.\nProtected."))
        contentStack.addArrangedSubview(body("Fast access to service, appointment reminders, property guidance, quote requests and treatment-day information."))

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
        let commercial = tappableCard(title: "Commercial", detail: "Outdoor service for business spaces, hospitality and event areas.", symbol: "building.2.fill", page: "commercial.html", titleForPage: "Commercial")
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

    private func nextAppointmentCard(_ appointment: ServiceAppointment) -> UIControl {
        let control = UIControl()
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
        service.text = appointment.service.rawValue
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
        let control = UIControl()
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
        let control = UIControl()
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
