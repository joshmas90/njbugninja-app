import UIKit

final class ServicesViewController: NinjaBaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Services"
        contentStack.addArrangedSubview(eyebrow("Choose a service"))
        contentStack.addArrangedSubview(headline("Built around the property.", size: 34))
        contentStack.addArrangedSubview(body("Open a service for focused information without the marketing-site navigation."))
        addService("Mosquito Control", "Mosquito resting and harborage areas.", "drop.fill", "mosquito-control.html")
        addService("Tick Control", "Wooded edges, brush, leaf litter and transition zones.", "scope", "tick-control.html")
        addService("Commercial", "Outdoor business, hospitality and event spaces.", "building.2.fill", "commercial.html")
        addService("Service Area", "Check South Jersey route availability.", "map.fill", "service-area.html")
        addService("FAQs", "Straight answers about quotes, service and expectations.", "questionmark.bubble.fill", "faq.html")
    }

    private func addService(_ title: String, _ detail: String, _ symbol: String, _ page: String) {
        let button = secondaryButton(title, symbol: symbol, action: #selector(noop))
        button.contentHorizontalAlignment = .leading
        button.addAction(UIAction { [weak self] _ in
            self?.navigationController?.pushViewController(WebViewController(page: page, title: title), animated: true)
        }, for: .touchUpInside)
        contentStack.addArrangedSubview(button)
        contentStack.addArrangedSubview(body(detail))
    }

    @objc private func noop() {}
}
