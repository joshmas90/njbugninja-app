import UIKit

final class PrepViewController: NinjaBaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Service Prep"
        contentStack.addArrangedSubview(eyebrow("Treatment-day guide"))
        contentStack.addArrangedSubview(headline("Ready before we arrive.", size: 34))
        contentStack.addArrangedSubview(body("A practical checklist for property access and communication. Product-specific instructions provided for your visit always control."))

        contentStack.addArrangedSubview(sectionTitle("Before service"))
        add("Confirm property access", "Make sure gates and treatment areas can be reached.", "lock.open.fill")
        add("Identify problem areas", "Note where mosquitoes or ticks are most noticeable.", "mappin.and.ellipse")
        add("Share property details", "Mention pets, events, sensitive areas or scheduling constraints that matter to the visit.", "text.bubble.fill")
        add("Review written instructions", "Follow any product- or visit-specific preparation provided to you.", "doc.text.fill")

        contentStack.addArrangedSubview(sectionTitle("After service"))
        add("Follow re-entry instructions", "Use the written product-specific instructions provided for your treatment.", "checkmark.shield.fill")
        add("Keep notes handy", "Weather, habitat and neighboring properties can affect outdoor pest pressure.", "note.text")
        add("Questions? Contact us", "Call or text directly if anything about your visit needs clarification.", "phone.bubble.fill")
    }

    private func add(_ title: String, _ detail: String, _ symbol: String) {
        contentStack.addArrangedSubview(card(title: title, detail: detail, symbol: symbol))
    }
}
