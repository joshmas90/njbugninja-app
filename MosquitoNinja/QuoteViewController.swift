import UIKit

final class QuoteViewController:
    NinjaBaseViewController,
    UITextFieldDelegate,
    UITextViewDelegate
{
    private let service =
        UISegmentedControl(
            items: [
                "Mosquito",
                "Ticks",
                "Both",
                "Comm/Govt"
            ]
        )

    private let nameField = UITextField()
    private let phoneField = UITextField()
    private let locationField = UITextField()
    private let notesView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Quote"

        buildUI()
    }

    private func style(
        _ field: UITextField,
        placeholder: String,
        contentType: UITextContentType? = nil
    ) {
        field.placeholder = placeholder
        field.textContentType = contentType

        field.backgroundColor =
            NinjaPalette.panel

        field.textColor = .white
        field.tintColor = NinjaPalette.red

        field.layer.cornerRadius = 12
        field.layer.cornerCurve = .continuous

        field.layer.borderWidth = 0.75

        field.layer.borderColor =
            UIColor.white
                .withAlphaComponent(0.12)
                .cgColor

        field.setLeftPadding(14)

        field.heightAnchor.constraint(
            equalToConstant: 52
        ).isActive = true

        field.delegate = self

        let color =
            UIColor.white.withAlphaComponent(0.42)

        field.attributedPlaceholder =
            NSAttributedString(
                string: placeholder,
                attributes: [
                    .foregroundColor: color
                ]
            )
    }

    private func buildUI() {
        contentStack.addArrangedSubview(
            eyebrow("Property quote")
        )

        contentStack.addArrangedSubview(
            headline(
                "Tell us what you’re dealing with.",
                size: 34
            )
        )

        contentStack.addArrangedSubview(
            body(
                "Build your request, review every detail, then choose whether to open it in Messages."
            )
        )

        contentStack.addArrangedSubview(
            sectionTitle("Service")
        )

        service.selectedSegmentIndex = 0

        service.selectedSegmentTintColor =
            NinjaPalette.red

        service.setTitleTextAttributes(
            [
                .foregroundColor:
                    UIColor.white
            ],
            for: .selected
        )

        service.setTitleTextAttributes(
            [
                .foregroundColor:
                    UIColor.white
                        .withAlphaComponent(0.72)
            ],
            for: .normal
        )

        service.addTarget(
            self,
            action: #selector(
                serviceSelectionChanged
            ),
            for: .valueChanged
        )

        contentStack.addArrangedSubview(service)

        contentStack.addArrangedSubview(
            sectionTitle("Contact")
        )

        style(
            nameField,
            placeholder: "Name",
            contentType: .name
        )

        style(
            phoneField,
            placeholder: "Phone",
            contentType: .telephoneNumber
        )

        phoneField.keyboardType = .phonePad

        style(
            locationField,
            placeholder: "Town or ZIP code",
            contentType: .postalCode
        )

        nameField.returnKeyType = .next
        locationField.returnKeyType = .done

        [
            nameField,
            phoneField,
            locationField
        ].forEach(
            contentStack.addArrangedSubview
        )

        contentStack.addArrangedSubview(
            sectionTitle("Property details")
        )

        notesView.backgroundColor =
            NinjaPalette.panel

        notesView.textColor = .white
        notesView.tintColor = NinjaPalette.red

        notesView.font =
            .systemFont(ofSize: 16)

        notesView.layer.cornerRadius = 12
        notesView.layer.cornerCurve =
            .continuous

        notesView.layer.borderWidth = 0.75

        notesView.layer.borderColor =
            UIColor.white
                .withAlphaComponent(0.12)
                .cgColor

        notesView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: 130
        ).isActive = true

        notesView.text =
            "Describe the property, where you notice activity, and any scheduling details."

        notesView.textColor =
            UIColor.white.withAlphaComponent(0.42)

        notesView.delegate = self

        contentStack.addArrangedSubview(
            notesView
        )

        contentStack.addArrangedSubview(
            primaryButton(
                "Review Request",
                symbol:
                    "checkmark.bubble.fill",
                action:
                    #selector(reviewQuote)
            )
        )

        contentStack.addArrangedSubview(
            card(
                title: "You stay in control",
                detail:
                    "Nothing is sent automatically. You will review the request here, confirm it, and then review it again in Messages before you choose Send.",
                symbol:
                    "hand.tap.fill",
                accent:
                    NinjaPalette.green
            )
        )
    }

    @objc private func
        serviceSelectionChanged()
    {
        NinjaHaptics.selection()
    }

    private func resetValidation() {
        [
            nameField,
            phoneField,
            locationField
        ].forEach { field in
            field.layer.borderColor =
                UIColor.white
                    .withAlphaComponent(0.12)
                    .cgColor
        }
    }

    private func markInvalid(
        _ field: UITextField
    ) {
        field.layer.borderColor =
            NinjaPalette.red
                .withAlphaComponent(0.88)
                .cgColor

        field.layer.borderWidth = 1.25
    }

    @objc private func reviewQuote() {
        view.endEditing(true)

        resetValidation()

        let name =
            nameField.text?
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                ) ?? ""

        let phone =
            phoneField.text?
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                ) ?? ""

        let location =
            locationField.text?
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                ) ?? ""

        var issues: [String] = []
        var firstInvalid: UITextField?

        if name.isEmpty {
            issues.append("your name")
            markInvalid(nameField)
            firstInvalid = nameField
        }

        let digitCount =
            phone.reduce(into: 0) {
                count,
                character in

                if character.wholeNumberValue
                    != nil
                {
                    count += 1
                }
            }

        if phone.isEmpty {
            issues.append("your phone number")
            markInvalid(phoneField)

            if firstInvalid == nil {
                firstInvalid = phoneField
            }
        } else if digitCount < 10 {
            issues.append(
                "a complete phone number"
            )

            markInvalid(phoneField)

            if firstInvalid == nil {
                firstInvalid = phoneField
            }
        }

        if location.isEmpty {
            issues.append(
                "your town or ZIP code"
            )

            markInvalid(locationField)

            if firstInvalid == nil {
                firstInvalid = locationField
            }
        }

        guard issues.isEmpty else {
            let missing =
                issues.joined(
                    separator: ", "
                )

            showFeedback(
                title:
                    "More Information Needed",
                detail:
                    "Please add \(missing) before reviewing your quote request.",
                kind: .warning,
                duration: 2.1
            )

            firstInvalid?
                .becomeFirstResponder()

            return
        }

        let selected =
            service.selectedSegmentIndex == 3
            ? "Commercial / Government"
            : (
                service.titleForSegment(
                    at:
                        service
                            .selectedSegmentIndex
                )
                ?? "Mosquito"
            )

        let notes =
            notesView.text.hasPrefix(
                "Describe the property"
            )
            ? ""
            : (
                notesView.text?
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )
                ?? ""
            )

        let message = """
        Hi Mosquito Ninja, I'd like a property quote.

        Name: \(name)
        Phone: \(phone)
        Town/ZIP: \(location)
        Service: \(selected)
        Property: \(notes)
        """

        guard let encoded =
            message.addingPercentEncoding(
                withAllowedCharacters:
                    .urlQueryAllowed
            )
        else {
            showFeedback(
                title:
                    "Request Couldn’t Be Prepared",
                detail:
                    "Please review the information and try again.",
                kind: .error,
                duration: 1.8
            )

            return
        }

        let reviewText = """
        Service: \(selected)
        Name: \(name)
        Phone: \(phone)
        Town/ZIP: \(location)

        \(notes.isEmpty ? "No additional property notes." : notes)

        Nothing has been sent yet.
        """

        let alert =
            UIAlertController(
                title:
                    "Review Quote Request",
                message:
                    reviewText,
                preferredStyle:
                    .alert
            )

        alert.addAction(
            UIAlertAction(
                title: "Keep Editing",
                style: .cancel
            ) { _ in
                NinjaHaptics.selection()
            }
        )

        alert.addAction(
            UIAlertAction(
                title: "Open Messages",
                style: .default
            ) { [weak self] _ in
                guard let self else {
                    return
                }

                self.showFeedback(
                    title:
                        "Request Confirmed",
                    detail:
                        "Opening Messages. Review the prepared text once more before you choose Send.",
                    kind: .success,
                    duration: 0.75
                ) { [weak self] in
                    self?.openExternal(
                        "sms:+16093136317?&body=\(encoded)"
                    )
                }
            }
        )

        present(
            alert,
            animated: true
        )
    }

    func textFieldDidBeginEditing(
        _ textField: UITextField
    ) {
        textField.layer.borderColor =
            UIColor.white
                .withAlphaComponent(0.12)
                .cgColor

        textField.layer.borderWidth = 0.75
    }

    func textFieldShouldReturn(
        _ textField: UITextField
    ) -> Bool {
        if textField === nameField {
            phoneField.becomeFirstResponder()
        } else if textField === locationField {
            textField.resignFirstResponder()
        }

        return true
    }

    func textViewDidBeginEditing(
        _ textView: UITextView
    ) {
        if textView.text.hasPrefix(
            "Describe the property"
        ) {
            textView.text = ""
            textView.textColor = .white
        }
    }
}


private extension UITextField {
    func setLeftPadding(
        _ amount: CGFloat
    ) {
        let padding =
            UIView(
                frame:
                    CGRect(
                        x: 0,
                        y: 0,
                        width: amount,
                        height: 1
                    )
            )

        leftView = padding
        leftViewMode = .always
    }
}
