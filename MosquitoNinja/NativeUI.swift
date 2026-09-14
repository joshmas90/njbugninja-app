import UIKit

struct NinjaPalette {
    static let ink = UIColor(red: 0.025, green: 0.03, blue: 0.027, alpha: 1)
    static let panel = UIColor(red: 0.055, green: 0.065, blue: 0.058, alpha: 1)
    static let paper = UIColor(red: 0.953, green: 0.937, blue: 0.898, alpha: 1)
    static let red = UIColor(red: 0.878, green: 0.125, blue: 0.153, alpha: 1)
    static let green = UIColor(red: 0.561, green: 0.741, blue: 0.180, alpha: 1)
    static let muted = UIColor.white.withAlphaComponent(0.68)
}

class NinjaBaseViewController: UIViewController {
    let scrollView = UIScrollView()
    let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = NinjaPalette.ink
        configureScroll()
    }

    private func configureScroll() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 18
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 22, left: 20, bottom: 34, right: 20)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    func eyebrow(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.textColor = NinjaPalette.red
        label.font = .systemFont(ofSize: 12, weight: .heavy)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }

    func headline(_ text: String, size: CGFloat = 40) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.textColor = .white
        label.font = .systemFont(ofSize: size, weight: .black)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = false
        return label
    }

    func body(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = NinjaPalette.muted
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        return label
    }

    func sectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 0
        return label
    }

    func primaryButton(_ title: String, symbol: String? = nil, action: Selector) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title.uppercased()
        config.baseBackgroundColor = NinjaPalette.red
        config.baseForegroundColor = .white
        config.cornerStyle = .small
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
        if let symbol { config.image = UIImage(systemName: symbol); config.imagePadding = 8 }
        let button = UIButton(configuration: config)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .heavy)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    func secondaryButton(_ title: String, symbol: String? = nil, action: Selector) -> UIButton {
        var config = UIButton.Configuration.gray()
        config.title = title.uppercased()
        config.baseBackgroundColor = NinjaPalette.panel
        config.baseForegroundColor = .white
        config.cornerStyle = .small
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
        if let symbol { config.image = UIImage(systemName: symbol); config.imagePadding = 8 }
        let button = UIButton(configuration: config)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    func card(title: String, detail: String, symbol: String, accent: UIColor = NinjaPalette.green) -> UIView {
        let container = UIView()
        container.backgroundColor = NinjaPalette.panel
        container.layer.cornerRadius = 16
        container.layer.borderWidth = 0.5
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.10).cgColor

        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = accent
        icon.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = title.uppercased()
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.numberOfLines = 0

        let detailLabel = UILabel()
        detailLabel.text = detail
        detailLabel.textColor = NinjaPalette.muted
        detailLabel.font = .systemFont(ofSize: 14)
        detailLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let row = UIStackView(arrangedSubviews: [icon, textStack])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 14
        container.addSubview(row)

        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 26),
            icon.heightAnchor.constraint(equalToConstant: 26),
            row.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        return container
    }

    func openExternal(_ value: String) {
        guard let url = URL(string: value) else { return }
        UIApplication.shared.open(url)
    }
}
