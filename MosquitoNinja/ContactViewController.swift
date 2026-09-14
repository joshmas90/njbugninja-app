import UIKit

final class ContactViewController: NinjaBaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contact"
        contentStack.addArrangedSubview(eyebrow("Mosquito Ninja"))
        contentStack.addArrangedSubview(headline("Direct when you need us.", size: 34))
        contentStack.addArrangedSubview(body("Owner-operated service for South Jersey residential, commercial and government properties."))
        contentStack.addArrangedSubview(primaryButton("Call 609-313-6317", symbol: "phone.fill", action: #selector(call)))
        contentStack.addArrangedSubview(secondaryButton("Text Mosquito Ninja", symbol: "message.fill", action: #selector(text)))
        contentStack.addArrangedSubview(secondaryButton("Open ChatGPT", symbol: "sparkles", action: #selector(openChatGPT)))
        contentStack.addArrangedSubview(secondaryButton("Check Service Area", symbol: "map.fill", action: #selector(area)))
        contentStack.addArrangedSubview(secondaryButton("Privacy", symbol: "hand.raised.fill", action: #selector(privacy)))
        contentStack.addArrangedSubview(card(title: "ChatGPT access", detail: "Open ChatGPT in your browser or installed app. ChatGPT account access and conversations stay with that service.", symbol: "sparkles", accent: NinjaPalette.green))
        contentStack.addArrangedSubview(card(title: "Straightforward service", detail: "No account, subscription, or in-app purchase is required. Quote requests stay in your control, and appointment reminders are stored and scheduled on your device.", symbol: "checkmark.circle.fill", accent: NinjaPalette.red))
    }

    @objc private func call() { openExternal("tel:+16093136317") }
    @objc private func text() { composeMessage() }
    @objc private func openChatGPT() { openExternal("https://chatgpt.com/") }
    @objc private func area() { navigationController?.pushViewController(WebViewController(page: "service-area.html", title: "Service Area"), animated: true) }
    @objc private func privacy() { navigationController?.pushViewController(WebViewController(page: "privacy.html", title: "Privacy"), animated: true) }
}
