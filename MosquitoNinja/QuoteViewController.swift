import UIKit

final class QuoteViewController: NinjaBaseViewController, UITextFieldDelegate, UITextViewDelegate {
    private let service = UISegmentedControl(items: ["Mosquito", "Ticks", "Both", "Commercial"])
    private let nameField = UITextField()
    private let phoneField = UITextField()
    private let locationField = UITextField()
    private let notesView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Quote"
        buildUI()
    }

    private func style(_ field: UITextField, placeholder: String, contentType: UITextContentType? = nil) {
        field.placeholder = placeholder
        field.textContentType = contentType
        field.backgroundColor = NinjaPalette.panel
        field.textColor = .white
        field.tintColor = NinjaPalette.red
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 0.5
        field.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        field.setLeftPadding(14)
        field.heightAnchor.constraint(equalToConstant: 52).isActive = true
        field.delegate = self
        let color = UIColor.white.withAlphaComponent(0.42)
        field.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: color])
    }

    private func buildUI() {
        contentStack.addArrangedSubview(eyebrow("Property quote"))
        contentStack.addArrangedSubview(headline("Tell us what you’re dealing with.", size: 34))
        contentStack.addArrangedSubview(body("Build a clean service request in the app, review it, then send it through Messages."))

        service.selectedSegmentIndex = 0
        service.selectedSegmentTintColor = NinjaPalette.red
        service.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        service.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.72)], for: .normal)
        contentStack.addArrangedSubview(service)

        style(nameField, placeholder: "Name", contentType: .name)
        style(phoneField, placeholder: "Phone", contentType: .telephoneNumber)
        phoneField.keyboardType = .phonePad
        style(locationField, placeholder: "Town or ZIP code", contentType: .postalCode)
        [nameField, phoneField, locationField].forEach(contentStack.addArrangedSubview)

        notesView.backgroundColor = NinjaPalette.panel
        notesView.textColor = .white
        notesView.tintColor = NinjaPalette.red
        notesView.font = .systemFont(ofSize: 16)
        notesView.layer.cornerRadius = 12
        notesView.layer.borderWidth = 0.5
        notesView.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        notesView.heightAnchor.constraint(greaterThanOrEqualToConstant: 130).isActive = true
        notesView.text = "Describe the property, where you notice activity, and any scheduling details."
        notesView.delegate = self
        contentStack.addArrangedSubview(notesView)

        contentStack.addArrangedSubview(primaryButton("Review & Send", symbol: "paperplane.fill", action: #selector(sendQuote)))
        contentStack.addArrangedSubview(body("No account is required. The app prepares the message on your device so you can review it before sending."))
    }

    @objc private func sendQuote() {
        view.endEditing(true)
        let selected = service.titleForSegment(at: service.selectedSegmentIndex) ?? "Mosquito"
        let notes = notesView.text.hasPrefix("Describe the property") ? "" : notesView.text ?? ""
        let message = """
        Hi Mosquito Ninja, I'd like a property quote.

        Name: \(nameField.text ?? "")
        Phone: \(phoneField.text ?? "")
        Town/ZIP: \(locationField.text ?? "")
        Service: \(selected)
        Property: \(notes)
        """
        guard let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        openExternal("sms:+16093136317?&body=\(encoded)")
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.hasPrefix("Describe the property") { textView.text = "" }
    }
}

private extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 1))
        leftView = padding
        leftViewMode = .always
    }
}
