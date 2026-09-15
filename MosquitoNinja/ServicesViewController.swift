import UIKit

final class ServicesViewController:
    NinjaBaseViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Services"

        contentStack.addArrangedSubview(
            eyebrow("Choose a service")
        )

        contentStack.addArrangedSubview(
            headline(
                "Built around the property.",
                size: 34
            )
        )

        contentStack.addArrangedSubview(
            body(
                "Select a service for focused treatment information, expectations and next steps."
            )
        )

        addService(
            "Mosquito Control",
            "Target mosquito resting and harborage areas around the property.",
            "drop.fill",
            "mosquito-control.html",
            kicker: "TARGETED CONTROL",
            accent: NinjaPalette.red
        )

        addService(
            "Tick Control",
            "Focus on wooded edges, brush, leaf litter and transition zones.",
            "scope",
            "tick-control.html",
            kicker: "PERIMETER DEFENSE",
            accent: NinjaPalette.green
        )

        addService(
            "Commercial & Government",
            "Outdoor pest service for business, hospitality, municipal and government-managed properties.",
            "building.2.fill",
            "commercial.html",
            kicker: "PROPERTY PROGRAMS",
            accent: NinjaPalette.red
        )

        contentStack.addArrangedSubview(
            eyebrow("Professional products")
        )

        contentStack.addArrangedSubview(
            headline(
                "Right product. Right target.",
                size: 30
            )
        )

        contentStack.addArrangedSubview(
            body(
                "Our core liquid products are OneGuard Multi MoA and Demand CS. We also use professional larval-control tools for standing water that cannot simply be removed. Product choice follows the pest, habitat, site conditions and the current product label."
            )
        )

        contentStack.addArrangedSubview(
            card(
                title: "OneGuard Multi MoA",
                detail:
                    "A multi-action concentrate for mosquito-focused outdoor treatment, combining adult control, quick knockdown, a synergist and an insect growth regulator in one formulation.",
                symbol:
                    "drop.fill",
                accent:
                    NinjaPalette.red
            )
        )

        contentStack.addArrangedSubview(
            card(
                title: "Demand CS",
                detail:
                    "A microencapsulated lambda-cyhalothrin residual option for labeled mosquito and tick treatment sites, including foliage, shrubs, perimeter areas and transition zones.",
                symbol:
                    "shield.fill",
                accent:
                    NinjaPalette.green
            )
        )

        contentStack.addArrangedSubview(
            card(
                title: "Bti Larvicides",
                detail:
                    "Biological granules or briquets can be used in label-permitted standing water that cannot be eliminated, targeting mosquito larvae before they emerge as adults.",
                symbol:
                    "leaf.fill",
                accent:
                    NinjaPalette.red
            )
        )

        contentStack.addArrangedSubview(
            card(
                title: "IGR Larvicide Granules",
                detail:
                    "Methoprene-based granular larvicides are another professional tool for suitable standing-water habitats when longer-duration larval control is appropriate.",
                symbol:
                    "clock.fill",
                accent:
                    NinjaPalette.green
            )
        )

        contentStack.addArrangedSubview(
            body(
                "Not every product is used on every visit. Application sites, rates, PPE and re-entry instructions follow the current product label and applicable requirements."
            )
        )

        addService(
            "Service Area",
            "Review South Jersey coverage and route availability.",
            "map.fill",
            "service-area.html",
            kicker: "COVERAGE",
            accent: NinjaPalette.green
        )

        addService(
            "FAQs",
            "Straight answers about quotes, service, preparation and expectations.",
            "questionmark.bubble.fill",
            "faq.html",
            kicker: "QUICK ANSWERS",
            accent: NinjaPalette.red
        )

        contentStack.addArrangedSubview(secondaryButton("Before & after service", symbol: "checklist", action: #selector(openPrep)))

        contentStack.addArrangedSubview(
            card(
                title: "One point of contact",
                detail:
                    "Your quote and treatment stay with Josh. Discuss the property, confirm the route and agree on the visit directly.",
                symbol:
                    "bolt.shield.fill",
                accent:
                    NinjaPalette.green
            )
        )
    }

    @objc private func openPrep() {
        navigationController?.pushViewController(PrepViewController(), animated: true)
    }

    private func addService(
        _ title: String,
        _ detail: String,
        _ symbol: String,
        _ page: String,
        kicker: String,
        accent: UIColor
    ) {
        let control = NinjaTouchControl()

        control.backgroundColor =
            NinjaPalette.panel

        control.layer.cornerRadius = 18
        control.layer.cornerCurve =
            .continuous

        control.layer.borderWidth = 1

        control.layer.borderColor =
            accent
                .withAlphaComponent(0.26)
                .cgColor

        control.accessibilityLabel = title
        control.accessibilityValue = detail

        control.accessibilityHint =
            "Opens \(title) details"

        let iconPlate = UIView()

        iconPlate.translatesAutoresizingMaskIntoConstraints =
            false

        iconPlate.backgroundColor =
            accent.withAlphaComponent(0.12)

        iconPlate.layer.cornerRadius = 14
        iconPlate.layer.cornerCurve =
            .continuous

        iconPlate.layer.borderWidth = 1

        iconPlate.layer.borderColor =
            accent
                .withAlphaComponent(0.22)
                .cgColor

        let icon =
            UIImageView(
                image:
                    UIImage(systemName: symbol)
            )

        icon.translatesAutoresizingMaskIntoConstraints =
            false

        icon.tintColor = accent
        icon.contentMode = .scaleAspectFit

        iconPlate.addSubview(icon)

        let kickerLabel = UILabel()

        kickerLabel.text =
            kicker.uppercased()

        kickerLabel.textColor = accent

        kickerLabel.font =
            .systemFont(
                ofSize: 10,
                weight: .heavy
            )

        let titleLabel = UILabel()

        titleLabel.text =
            title.uppercased()

        titleLabel.textColor = .white

        titleLabel.font =
            .systemFont(
                ofSize: 16,
                weight: .black
            )

        titleLabel.numberOfLines = 0

        let detailLabel = UILabel()

        detailLabel.text = detail

        detailLabel.textColor =
            NinjaPalette.muted

        detailLabel.font =
            .systemFont(
                ofSize: 14,
                weight: .regular
            )

        detailLabel.numberOfLines = 0

        let textStack =
            UIStackView(
                arrangedSubviews: [
                    kickerLabel,
                    titleLabel,
                    detailLabel
                ]
            )

        textStack.axis = .vertical
        textStack.spacing = 5

        let chevron =
            UIImageView(
                image:
                    UIImage(
                        systemName:
                            "chevron.right"
                    )
            )

        chevron.translatesAutoresizingMaskIntoConstraints =
            false

        chevron.tintColor =
            UIColor.white
                .withAlphaComponent(0.42)

        chevron.contentMode = .scaleAspectFit

        let row =
            UIStackView(
                arrangedSubviews: [
                    iconPlate,
                    textStack,
                    chevron
                ]
            )

        row.translatesAutoresizingMaskIntoConstraints =
            false

        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 14

        control.addSubview(row)

        NSLayoutConstraint.activate([
            iconPlate.widthAnchor.constraint(
                equalToConstant: 50
            ),

            iconPlate.heightAnchor.constraint(
                equalToConstant: 50
            ),

            icon.centerXAnchor.constraint(
                equalTo:
                    iconPlate.centerXAnchor
            ),

            icon.centerYAnchor.constraint(
                equalTo:
                    iconPlate.centerYAnchor
            ),

            icon.widthAnchor.constraint(
                equalToConstant: 25
            ),

            icon.heightAnchor.constraint(
                equalToConstant: 25
            ),

            chevron.widthAnchor.constraint(
                equalToConstant: 12
            ),

            row.topAnchor.constraint(
                equalTo:
                    control.topAnchor,
                constant: 17
            ),

            row.leadingAnchor.constraint(
                equalTo:
                    control.leadingAnchor,
                constant: 16
            ),

            row.trailingAnchor.constraint(
                equalTo:
                    control.trailingAnchor,
                constant: -16
            ),

            row.bottomAnchor.constraint(
                equalTo:
                    control.bottomAnchor,
                constant: -17
            )
        ])

        control.addAction(
            UIAction {
                [weak self] _ in

                guard let self else {
                    return
                }

                let destination: UIViewController
                if let service = NinjaService(page: page) {
                    destination = ServiceDetailViewController(service: service)
                } else {
                    destination = WebViewController(page: page, title: title)
                }
                self.navigationController?.pushViewController(destination, animated: true)
            },
            for: .touchUpInside
        )

        contentStack.addArrangedSubview(
            control
        )
    }
}
