import UIKit
import UserNotifications

final class AppointmentEditorViewController: NinjaBaseViewController, UITextFieldDelegate, UITextViewDelegate {
    private var appointment: ServiceAppointment?
    private let serviceControl = UISegmentedControl(items: ["Mosquito", "Ticks", "Both", "Commercial"])
    private let datePicker = UIDatePicker()
    private let propertyField = UITextField()
    private let notesView = UITextView()
    private let reminder24Switch = UISwitch()
    private let reminder1Switch = UISwitch()

    init(appointment: ServiceAppointment? = nil) {
        self.appointment = appointment
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = appointment == nil ? "Add Appointment" : "Edit Appointment"
        buildUI()
        applyExistingAppointment()
    }

    private func buildUI() {
        contentStack.addArrangedSubview(eyebrow("Confirmed service"))
        contentStack.addArrangedSubview(headline("Keep service day simple.", size: 34))
        contentStack.addArrangedSubview(body("Save a confirmed Mosquito Ninja appointment on this device and receive private reminders before service."))

        contentStack.addArrangedSubview(sectionTitle("Service"))
        serviceControl.selectedSegmentIndex = 0
        serviceControl.selectedSegmentTintColor = NinjaPalette.red
        serviceControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        serviceControl.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.70)], for: .normal)
        serviceControl.addTarget(
            self,
            action: #selector(serviceSelectionChanged),
            for: .valueChanged
        )
        contentStack.addArrangedSubview(serviceControl)

        contentStack.addArrangedSubview(sectionTitle("Appointment time"))
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .inline
        datePicker.minimumDate = Date().addingTimeInterval(-300)
        datePicker.tintColor = NinjaPalette.red
        datePicker.overrideUserInterfaceStyle = .dark
        contentStack.addArrangedSubview(datePicker)

        contentStack.addArrangedSubview(sectionTitle("Property"))
        style(propertyField, placeholder: "Street, town, or property label (optional)")
        propertyField.textContentType = .fullStreetAddress
        contentStack.addArrangedSubview(propertyField)

        notesView.backgroundColor = NinjaPalette.panel
        notesView.textColor = .white
        notesView.tintColor = NinjaPalette.red
        notesView.font = .systemFont(ofSize: 16)
        notesView.layer.cornerRadius = 12
        notesView.layer.borderWidth = 0.5
        notesView.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        notesView.heightAnchor.constraint(greaterThanOrEqualToConstant: 110).isActive = true
        notesView.text = "Optional appointment notes"
        notesView.textColor = UIColor.white.withAlphaComponent(0.42)
        notesView.delegate = self
        contentStack.addArrangedSubview(notesView)

        contentStack.addArrangedSubview(sectionTitle("Reminders"))
        reminder24Switch.isOn = true
        reminder1Switch.isOn = true
        reminder24Switch.onTintColor = NinjaPalette.red
        reminder1Switch.onTintColor = NinjaPalette.red
        reminder24Switch.addTarget(
            self,
            action: #selector(reminderSwitchChanged),
            for: .valueChanged
        )
        reminder1Switch.addTarget(
            self,
            action: #selector(reminderSwitchChanged),
            for: .valueChanged
        )
        contentStack.addArrangedSubview(switchRow(title: "24 hours before", detail: "A day-before service reminder.", toggle: reminder24Switch))
        contentStack.addArrangedSubview(switchRow(title: "1 hour before", detail: "A final reminder shortly before the appointment.", toggle: reminder1Switch))

        contentStack.addArrangedSubview(card(
            title: "Privacy first",
            detail: "Appointment details stay on this device. Mosquito Ninja does not request or share your location for reminders.",
            symbol: "lock.shield.fill",
            accent: NinjaPalette.green
        ))

        contentStack.addArrangedSubview(primaryButton("Save Appointment", symbol: "calendar.badge.checkmark", action: #selector(saveAppointment)))

        if appointment != nil {
            let delete = secondaryButton("Delete Appointment", symbol: "trash.fill", action: #selector(deleteAppointment))
            delete.configuration?.baseForegroundColor = NinjaPalette.red
            contentStack.addArrangedSubview(delete)
        }
    }

    private func style(_ field: UITextField, placeholder: String) {
        field.placeholder = placeholder
        field.backgroundColor = NinjaPalette.panel
        field.textColor = .white
        field.tintColor = NinjaPalette.red
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 0.5
        field.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        field.heightAnchor.constraint(equalToConstant: 52).isActive = true
        field.delegate = self
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        field.leftView = padding
        field.leftViewMode = .always
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.42)]
        )
    }

    private func switchRow(title: String, detail: String, toggle: UISwitch) -> UIView {
        let container = UIView()
        container.backgroundColor = NinjaPalette.panel
        container.layer.cornerRadius = 14
        container.layer.borderWidth = 0.5
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.10).cgColor

        let titleLabel = UILabel()
        titleLabel.text = title.uppercased()
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)

        let detailLabel = UILabel()
        detailLabel.text = detail
        detailLabel.textColor = NinjaPalette.muted
        detailLabel.font = .systemFont(ofSize: 13)
        detailLabel.numberOfLines = 0

        let labels = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        labels.axis = .vertical
        labels.spacing = 3

        let row = UIStackView(arrangedSubviews: [labels, toggle])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 14
        container.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14)
        ])
        return container
    }

    private func applyExistingAppointment() {
        guard let appointment else { return }
        serviceControl.selectedSegmentIndex = ServiceAppointment.Service.allCases.firstIndex(of: appointment.service) ?? 0
        datePicker.date = appointment.startDate
        propertyField.text = appointment.propertyLabel
        reminder24Switch.isOn = appointment.reminder24Hours
        reminder1Switch.isOn = appointment.reminder1Hour
        if !appointment.notes.isEmpty {
            notesView.text = appointment.notes
            notesView.textColor = .white
        }
    }

    @objc private func serviceSelectionChanged() {
        NinjaHaptics.selection()
    }

    @objc private func reminderSwitchChanged() {
        NinjaHaptics.selection()
    }

    @objc private func saveAppointment() {
        view.endEditing(true)

        let serviceIndex = min(max(serviceControl.selectedSegmentIndex, 0), ServiceAppointment.Service.allCases.count - 1)
        let service = ServiceAppointment.Service.allCases[serviceIndex]
        let notes = notesView.text == "Optional appointment notes" ? "" : (notesView.text ?? "")

        var updated = appointment ?? ServiceAppointment(service: service, startDate: datePicker.date)
        updated.service = service
        updated.startDate = datePicker.date
        updated.propertyLabel = propertyField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        updated.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.reminder24Hours = reminder24Switch.isOn
        updated.reminder1Hour = reminder1Switch.isOn
        appointment = updated

        let wantsReminders = updated.reminder24Hours || updated.reminder1Hour
        if wantsReminders {
            AppointmentNotificationManager.shared.authorizationStatus { [weak self] status in
                guard let self else { return }
                switch status {
                case .authorized, .provisional, .ephemeral:
                    self.finishSave(updated, alertsEnabled: true)
                case .notDetermined:
                    AppointmentNotificationManager.shared.requestAuthorization { granted in
                        self.finishSave(updated, alertsEnabled: granted)
                    }
                case .denied:
                    self.finishSave(updated, alertsEnabled: false)
                @unknown default:
                    self.finishSave(updated, alertsEnabled: false)
                }
            }
        } else {
            finishSave(updated, alertsEnabled: false)
        }
    }

    private func finishSave(_ appointment: ServiceAppointment, alertsEnabled: Bool) {
        NinjaHaptics.success()
        AppointmentStore.shared.save(appointment)
        if (appointment.reminder24Hours || appointment.reminder1Hour) && !alertsEnabled {
            let alert = UIAlertController(
                title: "Appointment Saved",
                message: "The appointment is saved, but notification permission is off. You can enable alerts in iPhone Settings at any time.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { [weak self] _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
                self?.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @objc private func deleteAppointment() {
        guard let appointment else { return }
        let alert = UIAlertController(
            title: "Delete Appointment?",
            message: "This removes the appointment and its scheduled reminders from this device.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            NinjaHaptics.warning()
            AppointmentStore.shared.delete(appointment)
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Optional appointment notes" {
            textView.text = ""
            textView.textColor = .white
        }
    }
}
