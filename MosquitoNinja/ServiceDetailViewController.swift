import UIKit

// App-owned service content. No website runtime, shared UI or remote content dependency.
enum NinjaService: Int {
    case mosquito = 0
    case tick = 1
    case commercial = 3
    case fly = 4

    init?(page: String) {
        switch page {
        case "mosquito-control.html": self = .mosquito
        case "tick-control.html": self = .tick
        case "commercial.html": self = .commercial
        case "fly-control.html": self = .fly
        default: return nil
        }
    }

    var title: String {
        switch self {
        case .mosquito: return "Mosquito Control"
        case .tick: return "Tick Control"
        case .commercial: return "Commercial & Government"
        case .fly: return "Outdoor Fly Control"
        }
    }

    var introduction: String {
        switch self {
        case .mosquito:
            return "Start with the outdoor spaces you use. Shaded vegetation, damp corners and the places you notice mosquitoes help guide the property assessment."
        case .tick:
            return "Look closely at the places where your lawn meets the woods. Paths, brush and shaded boundaries matter as much as the open space around them."
        case .commercial:
            return "Your outdoor space has a job to do. Service is discussed around the property layout, access arrangements and the way customers, staff or the public use it."
        case .fly:
            return "Outdoor fly pressure usually has a source. Trash and recycling areas, pet areas, exterior moisture, outdoor food-service zones and nearby breeding conditions are considered before treatment is discussed."
        }
    }

    var focus: [(title: String, detail: String, symbol: String)] {
        switch self {
        case .mosquito:
            return [
                ("Shaded vegetation", "Dense foliage, leaf undersides and shaded fence lines are considered during the assessment.", "leaf.fill"),
                ("Outdoor living areas", "Describe activity near seating, patios, pool surroundings and landscaped edges.", "house.fill"),
                ("Water and damp corners", "Point out where water collects and whether it can be removed so the options can be discussed.", "drop.fill")
            ]
        case .tick:
            return [
                ("Wooded transitions", "Woodlines, lawn edges and nearby overgrown areas help define the property discussion.", "leaf.fill"),
                ("Ground-level habitat", "Leaf litter, low brush, stone walls and shaded boundaries are areas to point out.", "scope"),
                ("Paths you use", "Tell us where people and pets spend time and where ticks have been noticed.", "mappin.and.ellipse")
            ]
        case .commercial:
            return [
                ("Business and public spaces", "Dining patios, event lawns, courtyards, pool surroundings and municipal outdoor areas.", "building.2.fill"),
                ("Access and operating hours", "Share site access, operating hours and upcoming events when discussing the visit.", "clock.fill"),
                ("The pest concern", "Describe mosquito, tick or nuisance-fly activity, vegetation, wooded edges and places where water or organic material collects.", "scope")
            ]
        case .fly:
            return [
                ("Breeding and attraction sources", "Trash, recycling, pet waste, decaying organic material and persistent moisture are checked first because source reduction is central to fly control.", "trash.fill"),
                ("Exterior resting areas", "Shaded exterior surfaces, protected corners, dumpster or bin surroundings and other labeled treatment sites may be considered when appropriate.", "scope"),
                ("Outdoor living and service areas", "Tell us where fly activity affects patios, decks, outdoor kitchens, entrances or commercial outdoor-use areas.", "fork.knife")
            ]
        }
    }

    var quotePrompt: String {
        switch self {
        case .mosquito:
            return "Include your town or ZIP, the outdoor areas you use and where mosquito activity is heaviest. Mention ticks too if both are a concern."
        case .tick:
            return "Include your town or ZIP, where ticks have been noticed and nearby woods or brush. Mention mosquitoes too if both are a concern."
        case .commercial:
            return "Include your town or ZIP, property type, pest concerns, access arrangements and scheduling needs."
        case .fly:
            return "Include your town or ZIP, where the flies are worst, nearby trash or recycling areas, pet areas, outdoor food-service areas, moisture or other conditions that may be attracting them."
        }
    }
}

final class ServiceDetailViewController: NinjaBaseViewController {
    private let service: NinjaService

    init(service: NinjaService) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { return nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = service.title
        navigationItem.backButtonTitle = "Service"
        contentStack.addArrangedSubview(eyebrow("Built around your property"))
        contentStack.addArrangedSubview(headline(service.title, size: 34))
        contentStack.addArrangedSubview(body(service.introduction))
        contentStack.addArrangedSubview(primaryButton("Request this service", symbol: "doc.text.fill", action: #selector(requestQuote)))

        contentStack.addArrangedSubview(sectionTitle("Where we focus"))
        for item in service.focus {
            contentStack.addArrangedSubview(card(title: item.title, detail: item.detail, symbol: item.symbol))
        }

        contentStack.addArrangedSubview(sectionTitle("How service works"))
        contentStack.addArrangedSubview(card(title: "01 · Look at the property", detail: "Layout, pest activity, likely source areas and the outdoor spaces you use guide the assessment.", symbol: "mappin.and.ellipse", accent: NinjaPalette.red))
        contentStack.addArrangedSubview(card(title: "02 · Identify the target areas", detail: "Habitat, breeding or attraction sources and the relevant labeled treatment sites guide the service plan.", symbol: "scope", accent: NinjaPalette.red))
        contentStack.addArrangedSubview(card(title: "03 · Treat and explain", detail: "Treatment is focused on relevant areas. You receive written instructions for the actual product and visit.", symbol: "doc.text.fill", accent: NinjaPalette.red))

        contentStack.addArrangedSubview(sectionTitle("Clear expectations"))
        contentStack.addArrangedSubview(body("Your quote and service stay with one point of contact. Availability and scheduling are confirmed directly. Weather, habitat, sanitation conditions and neighboring properties can affect pest pressure; complete elimination is not promised."))
        contentStack.addArrangedSubview(body("Follow the written re-entry instructions for your visit before people or pets return to treated areas."))
        contentStack.addArrangedSubview(secondaryButton("Before & after service", symbol: "checklist", action: #selector(openPrep)))

        contentStack.addArrangedSubview(sectionTitle("Tell us about your property"))
        contentStack.addArrangedSubview(body(service.quotePrompt))
        contentStack.addArrangedSubview(primaryButton("Request this service", symbol: "doc.text.fill", action: #selector(requestQuote)))
        contentStack.addArrangedSubview(secondaryButton("Ask a question", symbol: "message.fill", action: #selector(askQuestion)))
    }

    @objc private func requestQuote() {
        (tabBarController as? RootTabBarController)?.showQuote(service: service)
    }

    @objc private func openPrep() {
        navigationController?.pushViewController(PrepViewController(), animated: true)
    }

    @objc private func askQuestion() {
        composeMessage(body: "Hi Mosquito Ninja, I have a question about \(service.title.lowercased()).")
    }
}
