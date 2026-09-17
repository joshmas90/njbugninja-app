import Foundation
import UIKit

struct ServiceAppointment: Codable, Equatable, Identifiable {
    enum Service: String, Codable, CaseIterable {
        case mosquito = "Mosquito Control"
        case tick = "Tick Control"
        case both = "Mosquito + Tick"
        case commercial = "Commercial Service"
        case fly = "Outdoor Fly Control"

        var shortName: String {
            switch self {
            case .mosquito: return "Mosquito"
            case .tick: return "Tick"
            case .both: return "Mosquito + Tick"
            case .commercial: return "Commercial/Govt"
            case .fly: return "Fly Control"
            }
        }

        var displayName: String {
            switch self {
            case .commercial: return "Commercial / Government Service"
            default: return rawValue
            }
        }
    }

    let id: UUID
    var service: Service
    var startDate: Date
    var propertyLabel: String
    var notes: String
    var reminder24Hours: Bool
    var reminder1Hour: Bool

    init(
        id: UUID = UUID(),
        service: Service,
        startDate: Date,
        propertyLabel: String = "",
        notes: String = "",
        reminder24Hours: Bool = true,
        reminder1Hour: Bool = true
    ) {
        self.id = id
        self.service = service
        self.startDate = startDate
        self.propertyLabel = propertyLabel
        self.notes = notes
        self.reminder24Hours = reminder24Hours
        self.reminder1Hour = reminder1Hour
    }
}

extension Notification.Name {
    static let mosquitoNinjaAppointmentsDidChange =
        Notification.Name("mosquitoNinjaAppointmentsDidChange")
}

final class AppointmentStore {
    static let shared = AppointmentStore()

    private let defaults = UserDefaults.standard
    private let storageKey = "mosquitoNinja.serviceAppointments.v1"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private(set) var appointments: [ServiceAppointment] = []

    private init() {
        load()
    }

    var upcoming: [ServiceAppointment] {
        appointments
            .filter { $0.startDate > Date().addingTimeInterval(-3_600) }
            .sorted { $0.startDate < $1.startDate }
    }

    var nextAppointment: ServiceAppointment? {
        upcoming.first
    }

    var past: [ServiceAppointment] {
        appointments
            .filter { $0.startDate <= Date().addingTimeInterval(-3_600) }
            .sorted { $0.startDate > $1.startDate }
    }

    func appointment(id: UUID) -> ServiceAppointment? {
        appointments.first { $0.id == id }
    }

    func save(_ appointment: ServiceAppointment) {
        if let index = appointments.firstIndex(where: { $0.id == appointment.id }) {
            appointments[index] = appointment
        } else {
            appointments.append(appointment)
        }

        appointments.sort { $0.startDate < $1.startDate }
        persist()
        AppointmentNotificationManager.shared.reschedule(appointment)
        NotificationCenter.default.post(
            name: .mosquitoNinjaAppointmentsDidChange,
            object: appointment.id
        )
    }

    func delete(_ appointment: ServiceAppointment) {
        appointments.removeAll { $0.id == appointment.id }
        persist()
        AppointmentNotificationManager.shared.cancel(for: appointment.id)
        NotificationCenter.default.post(
            name: .mosquitoNinjaAppointmentsDidChange,
            object: appointment.id
        )
    }

    private func load() {
        guard
            let data = defaults.data(forKey: storageKey),
            let decoded = try? decoder.decode([ServiceAppointment].self, from: data)
        else {
            appointments = []
            return
        }

        appointments = decoded.sorted { $0.startDate < $1.startDate }
    }

    private func persist() {
        guard let data = try? encoder.encode(appointments) else { return }
        defaults.set(data, forKey: storageKey)
    }
}

// MARK: - Native customer dashboard

final class CustomerServiceViewController: NinjaBaseViewController {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Service"

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
        contentStack.addArrangedSubview(eyebrow("Customer dashboard"))
        contentStack.addArrangedSubview(
            headline("Your service.\nOne clean view.", size: 34)
        )
        contentStack.addArrangedSubview(
            body(
                "Keep upcoming visits, recent appointment history, rebooking, preparation, and follow-up together in the native app."
            )
        )

        contentStack.addArrangedSubview(summaryPanel())

        contentStack.addArrangedSubview(sectionTitle("Upcoming service"))

        if let next = AppointmentStore.shared.nextAppointment {
            contentStack.addArrangedSubview(
                premiumServiceCard(
                    appointment: next,
                    status: "UPCOMING",
                    accent: NinjaPalette.red,
                    symbol: "calendar.badge.clock"
                )
            )
        } else {
            contentStack.addArrangedSubview(
                card(
                    title: "No upcoming visit saved",
                    detail:
                        "Once a service time is confirmed, save it in Appointments to keep reminders and service-day tools together.",
                    symbol: "calendar",
                    accent: NinjaPalette.green
                )
            )
        }

        contentStack.addArrangedSubview(
            primaryButton(
                "Manage Appointments",
                symbol: "calendar.badge.clock",
                action: #selector(manageAppointments)
            )
        )

        contentStack.addArrangedSubview(sectionTitle("Recent service history"))

        let history = AppointmentStore.shared.past

        if history.isEmpty {
            contentStack.addArrangedSubview(
                card(
                    title: "History starts here",
                    detail:
                        "Past confirmed appointment times will appear here automatically after the scheduled visit time passes.",
                    symbol: "clock.arrow.circlepath",
                    accent: NinjaPalette.green
                )
            )
        } else {
            history.prefix(5).forEach { appointment in
                contentStack.addArrangedSubview(
                    premiumServiceCard(
                        appointment: appointment,
                        status: "PAST APPOINTMENT",
                        accent: NinjaPalette.green,
                        symbol: "checkmark.circle.fill"
                    )
                )
            }
        }

        contentStack.addArrangedSubview(sectionTitle("Follow-up"))

        if let latest = history.first {
            contentStack.addArrangedSubview(
                card(
                    title: "Most recent appointment",
                    detail: followUpDetail(latest),
                    symbol: "doc.text.magnifyingglass",
                    accent: NinjaPalette.red
                )
            )

            let actions = UIStackView(arrangedSubviews: [
                secondaryButton(
                    "Rebook",
                    symbol: "arrow.clockwise.circle.fill",
                    action: #selector(rebookLastService)
                ),
                secondaryButton(
                    "Feedback",
                    symbol: "star.bubble.fill",
                    action: #selector(shareServiceFeedback)
                )
            ])
            actions.axis = .horizontal
            actions.distribution = .fillEqually
            actions.spacing = 8
            contentStack.addArrangedSubview(actions)
        } else {
            contentStack.addArrangedSubview(
                card(
                    title: "Ready after your first visit",
                    detail:
                        "Once a saved appointment moves into history, this area will surface rebooking and feedback shortcuts.",
                    symbol: "sparkles",
                    accent: NinjaPalette.red
                )
            )
        }

        contentStack.addArrangedSubview(
            secondaryButton(
                "Before & After Service Guide",
                symbol: "checklist",
                action: #selector(openPrep)
            )
        )

        contentStack.addArrangedSubview(
            card(
                title: "Private by design",
                detail:
                    "This dashboard uses appointment information saved on this iPhone. It does not claim a treatment was completed and does not invent product-specific re-entry instructions.",
                symbol: "hand.raised.fill",
                accent: NinjaPalette.green
            )
        )
    }

    private func summaryPanel() -> UIView {
        let container = UIView()
        container.backgroundColor = NinjaPalette.panel
        container.layer.cornerRadius = 20
        container.layer.cornerCurve = .continuous
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.10).cgColor

        let upcomingCount = AppointmentStore.shared.upcoming.count
        let pastCount = AppointmentStore.shared.past.count

        let upcoming = metric(
            value: "\(upcomingCount)",
            label: upcomingCount == 1 ? "UPCOMING" : "UPCOMING"
        )

        let previous = metric(
            value: "\(pastCount)",
            label: pastCount == 1 ? "PAST" : "PAST"
        )

        let divider = UIView()
        divider.backgroundColor = UIColor.white.withAlphaComponent(0.09)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.widthAnchor.constraint(equalToConstant: 1).isActive = true

        let row = UIStackView(arrangedSubviews: [upcoming, divider, previous])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .fill
        row.distribution = .fillEqually
        row.spacing = 12

        container.addSubview(row)

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -18)
        ])

        container.isAccessibilityElement = true
        container.accessibilityLabel =
            "\(upcomingCount) upcoming appointments. \(pastCount) past appointments saved on this iPhone."

        return container
    }

    private func metric(value: String, label: String) -> UIView {
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.textColor = .white
        valueLabel.font = UIFontMetrics(forTextStyle: .title1)
            .scaledFont(for: .systemFont(ofSize: 30, weight: .black))
        valueLabel.adjustsFontForContentSizeCategory = true
        valueLabel.textAlignment = .center

        let labelLabel = UILabel()
        labelLabel.text = label
        labelLabel.textColor = NinjaPalette.muted
        labelLabel.font = UIFontMetrics(forTextStyle: .caption1)
            .scaledFont(for: .systemFont(ofSize: 11, weight: .heavy))
        labelLabel.adjustsFontForContentSizeCategory = true
        labelLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [valueLabel, labelLabel])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 2
        return stack
    }

    private func premiumServiceCard(
        appointment: ServiceAppointment,
        status: String,
        accent: UIColor,
        symbol: String
    ) -> UIView {
        let container = UIView()
        container.backgroundColor = NinjaPalette.panel
        container.layer.cornerRadius = 18
        container.layer.cornerCurve = .continuous
        container.layer.borderWidth = 1
        container.layer.borderColor = accent.withAlphaComponent(0.30).cgColor

        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = accent
        icon.contentMode = .scaleAspectFit

        let kicker = UILabel()
        kicker.text = status
        kicker.textColor = accent
        kicker.font = UIFontMetrics(forTextStyle: .caption1)
            .scaledFont(for: .systemFont(ofSize: 11, weight: .heavy))
        kicker.adjustsFontForContentSizeCategory = true

        let title = UILabel()
        title.text = appointment.service.displayName.uppercased()
        title.textColor = .white
        title.font = UIFontMetrics(forTextStyle: .headline)
            .scaledFont(for: .systemFont(ofSize: 16, weight: .black))
        title.adjustsFontForContentSizeCategory = true
        title.numberOfLines = 0

        let date = UILabel()
        date.text = dateFormatter.string(from: appointment.startDate)
        date.textColor = NinjaPalette.muted
        date.font = .preferredFont(forTextStyle: .subheadline)
        date.adjustsFontForContentSizeCategory = true
        date.numberOfLines = 0

        let property = UILabel()
        property.text = appointment.propertyLabel.isEmpty
            ? "South Jersey service appointment"
            : appointment.propertyLabel
        property.textColor = UIColor.white.withAlphaComponent(0.82)
        property.font = .preferredFont(forTextStyle: .footnote)
        property.adjustsFontForContentSizeCategory = true
        property.numberOfLines = 0

        let labels = UIStackView(arrangedSubviews: [kicker, title, date, property])
        labels.axis = .vertical
        labels.spacing = 5

        let row = UIStackView(arrangedSubviews: [icon, labels])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 14

        container.addSubview(row)

        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 28),
            icon.heightAnchor.constraint(equalToConstant: 28),
            row.topAnchor.constraint(equalTo: container.topAnchor, constant: 17),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 17),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -17),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -17)
        ])

        container.isAccessibilityElement = true
        container.accessibilityLabel =
            "\(status). \(appointment.service.displayName). \(dateFormatter.string(from: appointment.startDate))."

        return container
    }

    private func followUpDetail(_ appointment: ServiceAppointment) -> String {
        var lines = [
            "\(appointment.service.displayName) • \(dateFormatter.string(from: appointment.startDate))"
        ]

        if !appointment.propertyLabel.isEmpty {
            lines.append(appointment.propertyLabel)
        }

        lines.append(
            "Review any visit-specific instructions you received and use the guide below for general before/after-service reminders."
        )

        return lines.joined(separator: "\n")
    }

    @objc private func manageAppointments() {
        navigationController?.pushViewController(
            AppointmentsViewController(),
            animated: true
        )
    }

    @objc private func openPrep() {
        navigationController?.pushViewController(
            PrepViewController(),
            animated: true
        )
    }

    @objc private func rebookLastService() {
        guard let appointment = AppointmentStore.shared.past.first else { return }

        var message = """
        Hi Mosquito Ninja, I'd like to rebook my \(appointment.service.displayName) service.

        Previous appointment: \(dateFormatter.string(from: appointment.startDate))
        """

        if !appointment.propertyLabel.isEmpty {
            message += "\nProperty: \(appointment.propertyLabel)"
        }

        message += "\n\nPlease let me know the next available options."
        composeMessage(body: message)
    }

    @objc private func shareServiceFeedback() {
        guard let appointment = AppointmentStore.shared.past.first else { return }

        let message = """
        Hi Mosquito Ninja, I wanted to share feedback about my \(appointment.service.displayName) appointment on \(dateFormatter.string(from: appointment.startDate)).

        Feedback:
        """

        composeMessage(body: message)
    }
}
