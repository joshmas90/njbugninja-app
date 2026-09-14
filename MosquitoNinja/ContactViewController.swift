import UIKit

final class ContactViewController: NinjaBaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contact"
        contentStack.addArrangedSubview(eyebrow("Mosquito Ninja"))
        contentStack.addArrangedSubview(headline("Direct when you need us.", size: 34))
        contentStack.addArrangedSubview(body("Owner-operated service for South Jersey homes and commercial outdoor spaces."))
        contentStack.addArrangedSubview(primaryButton("Call 609-313-6317", symbol: "phone.fill", action: #selector(call)))
        contentStack.addArrangedSubview(secondaryButton("Text Mosquito Ninja", symbol: "message.fill", action: #selector(text)))
        contentStack.addArrangedSubview(secondaryButton("Check Service Area", symbol: "map.fill", action: #selector(area)))
        contentStack.addArrangedSubview(secondaryButton("Privacy", symbol: "hand.raised.fill", action: #selector(privacy)))
        contentStack.addArrangedSubview(card(title: "Straightforward service", detail: "No account, subscription, or in-app purchase is required. Quote requests stay in your control, and appointment reminders are stored and scheduled on your device.", symbol: "checkmark.circle.fill", accent: NinjaPalette.red))
    }

    @objc private func call() { openExternal("tel:+16093136317") }
    @objc private func text() { openExternal("sms:+16093136317") }
    @objc private func area() { navigationController?.pushViewController(WebViewController(page: "service-area.html", title: "Service Area"), animated: true) }
    @objc private func privacy() { navigationController?.pushViewController(WebViewController(page: "privacy.html", title: "Privacy"), animated: true) }
}
