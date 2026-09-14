import Foundation
import UserNotifications

final class AppointmentNotificationManager {
    static let shared = AppointmentNotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let categoryIdentifier = "MOSQUITO_NINJA_APPOINTMENT"

    private init() {
        let category = UNNotificationCategory(
            identifier: categoryIdentifier,
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([category])
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func authorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async { completion(settings.authorizationStatus) }
        }
    }

    func reschedule(_ appointment: ServiceAppointment) {
        cancel(for: appointment.id)

        if appointment.reminder24Hours {
            schedule(
                appointment,
                offset: -24 * 60 * 60,
                suffix: "24h",
                title: "Mosquito Ninja appointment tomorrow",
                leadText: "Your \(appointment.service.shortName.lowercased()) service is scheduled for"
            )
        }

        if appointment.reminder1Hour {
            schedule(
                appointment,
                offset: -60 * 60,
                suffix: "1h",
                title: "Mosquito Ninja is scheduled in about an hour",
                leadText: "Your \(appointment.service.shortName.lowercased()) service is scheduled for"
            )
        }
    }

    func cancel(for appointmentID: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: identifiers(for: appointmentID))
        center.removeDeliveredNotifications(withIdentifiers: identifiers(for: appointmentID))
    }

    private func identifiers(for appointmentID: UUID) -> [String] {
        ["\(appointmentID.uuidString).24h", "\(appointmentID.uuidString).1h"]
    }

    private func schedule(
        _ appointment: ServiceAppointment,
        offset: TimeInterval,
        suffix: String,
        title: String,
        leadText: String
    ) {
        let fireDate = appointment.startDate.addingTimeInterval(offset)
        guard fireDate > Date().addingTimeInterval(5) else { return }

        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "\(leadText) \(formatter.string(from: appointment.startDate)). Open the app for service-day details."
        content.sound = .default
        content.categoryIdentifier = categoryIdentifier
        content.userInfo = ["appointmentID": appointment.id.uuidString]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "\(appointment.id.uuidString).\(suffix)",
            content: content,
            trigger: trigger
        )
        center.add(request)
    }
}
