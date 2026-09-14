import Foundation

struct ServiceAppointment: Codable, Equatable, Identifiable {
    enum Service: String, Codable, CaseIterable {
        case mosquito = "Mosquito Control"
        case tick = "Tick Control"
        case both = "Mosquito + Tick"
        case commercial = "Commercial Service"

        var shortName: String {
            switch self {
            case .mosquito: return "Mosquito"
            case .tick: return "Tick"
            case .both: return "Mosquito + Tick"
            case .commercial: return "Commercial"
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
    static let mosquitoNinjaAppointmentsDidChange = Notification.Name("mosquitoNinjaAppointmentsDidChange")
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
        NotificationCenter.default.post(name: .mosquitoNinjaAppointmentsDidChange, object: appointment.id)
    }

    func delete(_ appointment: ServiceAppointment) {
        appointments.removeAll { $0.id == appointment.id }
        persist()
        AppointmentNotificationManager.shared.cancel(for: appointment.id)
        NotificationCenter.default.post(name: .mosquitoNinjaAppointmentsDidChange, object: appointment.id)
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? decoder.decode([ServiceAppointment].self, from: data) else {
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
