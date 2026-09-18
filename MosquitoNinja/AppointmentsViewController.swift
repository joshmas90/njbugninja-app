import UIKit
import UserNotifications

final class AppointmentsViewController: NinjaBaseViewController {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Appointments"
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .mosquitoNinjaAppointmentsDidChange, object: nil)
        buildUI()
    }

    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated); refresh() }
    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func refresh() {
        for view in contentStack.arrangedSubviews { contentStack.removeArrangedSubview(view); view.removeFromSuperview() }
        buildUI()
    }

    private func buildUI() {
        contentStack.addArrangedSubview(eyebrow("Service day"))
        contentStack.addArrangedSubview(headline("Your next visit.\nClear and on time.", size: 34))
        contentStack.addArrangedSubview(body("Keep confirmed Mosquito Ninja appointments in one place and receive private reminders before service."))
        contentStack.addArrangedSubview(card(title: "Confirmed appointments only", detail: "Saving an appointment here does not book service or send anything to Mosquito Ninja. Add it only after the date and time have been confirmed directly.", symbol: "checkmark.shield.fill", accent: NinjaPalette.green))

        if let next = AppointmentStore.shared.nextAppointment {
            contentStack.addArrangedSubview(appointmentHero(next))
            contentStack.addArrangedSubview(primaryButton("View / Edit Appointment", symbol: "calendar.badge.clock", action: #selector(editNext)))
        } else {
            contentStack.addArrangedSubview(emptyAppointmentCard())
            contentStack.addArrangedSubview(primaryButton("Save Confirmed Appointment", symbol: "calendar.badge.plus", action: #selector(addAppointment)))
        }

        contentStack.addArrangedSubview(sectionTitle("Appointment alerts"))
        contentStack.addArrangedSubview(alertStatusCard())
        contentStack.addArrangedSubview(secondaryButton("Notification Settings", symbol: "bell.badge.fill", action: #selector(notificationSettings)))

        let future = AppointmentStore.shared.upcoming.dropFirst()
        if !future.isEmpty {
            contentStack.addArrangedSubview(sectionTitle("Later appointments"))
            for appointment in future { contentStack.addArrangedSubview(compactAppointmentCard(appointment)) }
        }

        contentStack.addArrangedSubview(sectionTitle("Service-day tools"))
        contentStack.addArrangedSubview(secondaryButton("Before & After Service Guide", symbol: "checklist", action: #selector(openPrep)))
        contentStack.addArrangedSubview(secondaryButton("Call Mosquito Ninja", symbol: "phone.fill", action: #selector(call)))
        contentStack.addArrangedSubview(secondaryButton("Text Mosquito Ninja", symbol: "message.fill", action: #selector(text)))
        contentStack.addArrangedSubview(card(title: "Private by design", detail: "Appointment reminders are scheduled on your iPhone. No live location sharing is used, requested, or needed.", symbol: "hand.raised.fill", accent: NinjaPalette.green))
    }

    private func appointmentHero(_ appointment: ServiceAppointment) -> UIView {
        let container = UIView(); container.backgroundColor = NinjaPalette.panel; container.layer.cornerRadius = 20; container.layer.cornerCurve = .continuous; container.layer.borderWidth = 1; container.layer.borderColor = NinjaPalette.red.withAlphaComponent(0.42).cgColor
        let status = UILabel(); status.text = "CONFIRMED"; status.textColor = NinjaPalette.green; status.font = .systemFont(ofSize: 11, weight: .heavy)
        let date = UILabel(); date.text = dateFormatter.string(from: appointment.startDate).uppercased(); date.textColor = .white; date.font = .systemFont(ofSize: 20, weight: .black); date.numberOfLines = 0
        let time = UILabel(); time.text = timeFormatter.string(from: appointment.startDate); time.textColor = NinjaPalette.red; time.font = .systemFont(ofSize: 36, weight: .black)
        let service = UILabel(); service.text = appointment.service.displayName.uppercased(); service.textColor = .white; service.font = .systemFont(ofSize: 14, weight: .bold)
        let property = UILabel(); property.text = appointment.propertyLabel.isEmpty ? "South Jersey service appointment" : appointment.propertyLabel; property.textColor = NinjaPalette.muted; property.font = .systemFont(ofSize: 14); property.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [status,date,time,service,property]); stack.translatesAutoresizingMaskIntoConstraints = false; stack.axis = .vertical; stack.spacing = 6; container.addSubview(stack)
        NSLayoutConstraint.activate([stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 20), stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20), stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20), stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20)])
        return container
    }

    private func compactAppointmentCard(_ appointment: ServiceAppointment) -> UIControl {
        let control = NinjaTouchControl(); control.backgroundColor = NinjaPalette.panel; control.layer.cornerRadius = 16; control.layer.cornerCurve = .continuous; control.layer.borderWidth = 0.5; control.layer.borderColor = UIColor.white.withAlphaComponent(0.10).cgColor
        let date = UILabel(); date.text = dateFormatter.string(from: appointment.startDate); date.textColor = .white; date.font = .systemFont(ofSize: 14, weight: .bold)
        let detail = UILabel(); detail.text = "\(timeFormatter.string(from: appointment.startDate))  •  \(appointment.service.shortName)"; detail.textColor = NinjaPalette.muted; detail.font = .systemFont(ofSize: 13)
        let labels = UIStackView(arrangedSubviews: [date,detail]); labels.axis = .vertical; labels.spacing = 3
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right")); chevron.tintColor = UIColor.white.withAlphaComponent(0.42); chevron.setContentHuggingPriority(.required, for: .horizontal)
        let row = UIStackView(arrangedSubviews: [labels,chevron]); row.translatesAutoresizingMaskIntoConstraints = false; row.axis = .horizontal; row.alignment = .center; row.spacing = 12; control.addSubview(row)
        NSLayoutConstraint.activate([row.topAnchor.constraint(equalTo: control.topAnchor, constant: 15), row.leadingAnchor.constraint(equalTo: control.leadingAnchor, constant: 16), row.trailingAnchor.constraint(equalTo: control.trailingAnchor, constant: -16), row.bottomAnchor.constraint(equalTo: control.bottomAnchor, constant: -15)])
        control.addAction(UIAction { [weak self] _ in self?.navigationController?.pushViewController(AppointmentEditorViewController(appointment: appointment), animated: true) }, for: .touchUpInside)
        return control
    }

    private func emptyAppointmentCard() -> UIView { card(title: "No appointment saved", detail: "Once your service time is confirmed, save it here to keep the date, preparation guide, and reminders together. Saving it here does not book or change service.", symbol: "calendar", accent: NinjaPalette.red) }

    private func alertStatusCard() -> UIView {
        let container = UIView(); container.backgroundColor = NinjaPalette.panel; container.layer.cornerRadius = 16; container.layer.cornerCurve = .continuous; container.layer.borderWidth = 0.75; container.layer.borderColor = UIColor.white.withAlphaComponent(0.10).cgColor
        let iconHolder = UIView(); iconHolder.translatesAutoresizingMaskIntoConstraints = false
        let loader = NinjaActivityIndicator(frame: .zero); loader.translatesAutoresizingMaskIntoConstraints = false; loader.startAnimating()
        let icon = UIImageView(image: UIImage(systemName: "bell.fill")); icon.translatesAutoresizingMaskIntoConstraints = false; icon.tintColor = NinjaPalette.green; icon.alpha = 0
        iconHolder.addSubview(loader); iconHolder.addSubview(icon)
        let title = UILabel(); title.text = "CHECKING ALERT STATUS…"; title.textColor = .white; title.font = .systemFont(ofSize: 14, weight: .bold)
        let detail = UILabel(); detail.text = "Checking whether 24-hour and 1-hour appointment reminders are available."; detail.textColor = NinjaPalette.muted; detail.font = .systemFont(ofSize: 13); detail.numberOfLines = 0
        let labels = UIStackView(arrangedSubviews: [title,detail]); labels.axis = .vertical; labels.spacing = 4
        let row = UIStackView(arrangedSubviews: [iconHolder,labels]); row.translatesAutoresizingMaskIntoConstraints = false; row.axis = .horizontal; row.alignment = .top; row.spacing = 14; container.addSubview(row)
        NSLayoutConstraint.activate([iconHolder.widthAnchor.constraint(equalToConstant: 26),iconHolder.heightAnchor.constraint(equalToConstant: 26),loader.topAnchor.constraint(equalTo: iconHolder.topAnchor),loader.leadingAnchor.constraint(equalTo: iconHolder.leadingAnchor),loader.trailingAnchor.constraint(equalTo: iconHolder.trailingAnchor),loader.bottomAnchor.constraint(equalTo: iconHolder.bottomAnchor),icon.centerXAnchor.constraint(equalTo: iconHolder.centerXAnchor),icon.centerYAnchor.constraint(equalTo: iconHolder.centerYAnchor),icon.widthAnchor.constraint(equalToConstant: 24),icon.heightAnchor.constraint(equalToConstant: 24),row.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),row.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),row.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)])
        AppointmentNotificationManager.shared.authorizationStatus { status in DispatchQueue.main.async {
            loader.stopAnimating()
            switch status {
            case .authorized,.provisional,.ephemeral: title.text="APPOINTMENT ALERTS ON"; detail.text="Notification access is available for saved appointment reminders."; icon.tintColor=NinjaPalette.green
            case .denied: title.text="APPOINTMENT ALERTS OFF"; detail.text="Notification permission is off. Open Notification Settings to enable reminders."; icon.tintColor=NinjaPalette.red
            case .notDetermined: title.text="APPOINTMENT ALERTS AVAILABLE"; detail.text="Enable reminders when you save an appointment or open Notification Settings below."; icon.tintColor=NinjaPalette.green
            @unknown default: title.text="APPOINTMENT ALERT STATUS"; detail.text="Use Notification Settings below to review reminder access."; icon.tintColor=NinjaPalette.red }
            UIView.animate(withDuration: 0.20) { loader.alpha=0; icon.alpha=1 }
        }}
        return container
    }

    @objc private func addAppointment() { navigationController?.pushViewController(AppointmentEditorViewController(), animated: true) }
    @objc private func editNext() { guard let appointment=AppointmentStore.shared.nextAppointment else{return}; navigationController?.pushViewController(AppointmentEditorViewController(appointment: appointment), animated: true) }
    @objc private func notificationSettings() {
        AppointmentNotificationManager.shared.authorizationStatus { [weak self] status in DispatchQueue.main.async { guard let self else{return}
            switch status {
            case .notDetermined:
                self.showFeedback(title:"Notification Permission", detail:"iOS will ask whether Mosquito Ninja can show appointment reminders.", kind:.info, duration:0.65)
                AppointmentNotificationManager.shared.requestAuthorization { [weak self] granted in DispatchQueue.main.async { guard let self else{return}; self.refresh(); self.showFeedback(title: granted ? "Appointment Alerts On":"Appointment Alerts Off", detail: granted ? "Notification permission is enabled for appointment reminders.":"Permission was not enabled. You can change this later in iPhone Settings.", kind: granted ? .success:.warning, duration: granted ? 1.5:1.8) }}
            case .denied:
                NinjaHaptics.warning(); let alert=UIAlertController(title:"Notification Access Is Off", message:"To receive appointment reminders, open Settings, choose Notifications, and allow notifications for Mosquito Ninja.", preferredStyle:.alert); alert.addAction(UIAlertAction(title:"Not Now",style:.cancel){_ in NinjaHaptics.selection()}); alert.addAction(UIAlertAction(title:"Open Settings",style:.default){[weak self]_ in self?.openExternal(UIApplication.openSettingsURLString)}); self.present(alert,animated:true)
            case .authorized,.provisional,.ephemeral:
                self.showFeedback(title:"Opening Settings",detail:"Notification access is already enabled. Opening iPhone Settings for additional controls.",kind:.info,duration:0.55){[weak self] in self?.openExternal(UIApplication.openSettingsURLString)}
            @unknown default: self.showFeedback(title:"Notification Status Unavailable",detail:"Please try again or review Mosquito Ninja permissions in iPhone Settings.",kind:.error,duration:1.8)
            }
        }}
    }
    @objc private func openPrep(){ navigationController?.pushViewController(PrepViewController(),animated:true) }
    @objc private func call(){ openExternal("tel:+16093136317") }
    @objc private func text(){ composeMessage() }
}
