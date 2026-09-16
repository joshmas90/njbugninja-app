import UIKit

private final class NinjaHeaderItem: UIControl {
    let index: Int

    private let titleLabel = UILabel()
    private let indicator = UIView()

    init(title: String, index: Int) {
        self.index = index
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = title

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.92)
        titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel.textAlignment = .center

        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.backgroundColor = NinjaPalette.red
        indicator.layer.cornerRadius = 1
        indicator.isHidden = true

        addSubview(titleLabel)
        addSubview(indicator)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            indicator.heightAnchor.constraint(equalToConstant: 2),
            indicator.leadingAnchor.constraint(equalTo: leadingAnchor),
            indicator.trailingAnchor.constraint(equalTo: trailingAnchor),
            indicator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelected(_ selected: Bool) {
        indicator.isHidden = !selected
        titleLabel.textColor = selected ? .white : UIColor.white.withAlphaComponent(0.86)
        accessibilityTraits = selected ? [.button, .selected] : .button
    }
}

private final class NinjaWebsiteHeaderView: UIView {
    var onSelectTab: ((Int) -> Void)?
    var onCall: (() -> Void)?

    private let items: [NinjaHeaderItem]

    override init(frame: CGRect) {
        items = [
            NinjaHeaderItem(title: "Home", index: 0),
            NinjaHeaderItem(title: "Services", index: 1),
            NinjaHeaderItem(title: "My Service", index: 2),
            NinjaHeaderItem(title: "Quote", index: 3),
            NinjaHeaderItem(title: "Contact", index: 4)
        ]

        super.init(frame: frame)

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = NinjaPalette.ink
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor

        let brand = UIControl()
        brand.translatesAutoresizingMaskIntoConstraints = false
        brand.accessibilityLabel = "Mosquito Ninja home"
        brand.accessibilityTraits = .button
        brand.addAction(UIAction { [weak self] _ in
            self?.onSelectTab?(0)
        }, for: .touchUpInside)

        let mark = UIImageView()
        mark.translatesAutoresizingMaskIntoConstraints = false
        mark.contentMode = .scaleAspectFit

        if let root = Bundle.main.resourceURL {
            let url = root.appendingPathComponent("Web/assets/mark-v20.webp")
            mark.image = UIImage(contentsOfFile: url.path)
        }

        if mark.image == nil {
            mark.image = UIImage(named: "LaunchMark")
        }

        let brandName = UILabel()
        brandName.translatesAutoresizingMaskIntoConstraints = false
        brandName.numberOfLines = 1

        let brandText = NSMutableAttributedString(
            string: "MOSQUITO ",
            attributes: [
                .foregroundColor: NinjaPalette.red,
                .font: UIFont.systemFont(ofSize: 20, weight: .black)
            ]
        )
        brandText.append(
            NSAttributedString(
                string: "NINJA",
                attributes: [
                    .foregroundColor: UIColor.white,
                    .font: UIFont.systemFont(ofSize: 20, weight: .black)
                ]
            )
        )
        brandName.attributedText = brandText

        let brandSubtitle = UILabel()
        brandSubtitle.translatesAutoresizingMaskIntoConstraints = false
        brandSubtitle.text = "MOSQUITO & TICK CONTROL"
        brandSubtitle.textColor = UIColor.white.withAlphaComponent(0.70)
        brandSubtitle.font = .systemFont(ofSize: 7.5, weight: .bold)
        brandSubtitle.adjustsFontSizeToFitWidth = true
        brandSubtitle.minimumScaleFactor = 0.8

        let brandCopy = UIStackView(arrangedSubviews: [brandName, brandSubtitle])
        brandCopy.translatesAutoresizingMaskIntoConstraints = false
        brandCopy.axis = .vertical
        brandCopy.spacing = 3
        brandCopy.alignment = .leading

        brand.addSubview(mark)
        brand.addSubview(brandCopy)

        NSLayoutConstraint.activate([
            mark.leadingAnchor.constraint(equalTo: brand.leadingAnchor),
            mark.centerYAnchor.constraint(equalTo: brand.centerYAnchor),
            mark.widthAnchor.constraint(equalToConstant: 44),
            mark.heightAnchor.constraint(equalToConstant: 44),

            brandCopy.leadingAnchor.constraint(equalTo: mark.trailingAnchor, constant: 10),
            brandCopy.trailingAnchor.constraint(equalTo: brand.trailingAnchor),
            brandCopy.centerYAnchor.constraint(equalTo: brand.centerYAnchor),
            brand.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ])

        let nav = UIStackView(arrangedSubviews: items)
        nav.translatesAutoresizingMaskIntoConstraints = false
        nav.axis = .horizontal
        nav.alignment = .center
        nav.spacing = 26

        for item in items {
            item.addAction(UIAction { [weak self, weak item] _ in
                guard let index = item?.index else { return }
                self?.onSelectTab?(index)
            }, for: .touchUpInside)
        }

        let callButton = NinjaButton(type: .system)
        callButton.translatesAutoresizingMaskIntoConstraints = false
        callButton.setTitle("CALL  •  609-313-6317", for: .normal)
        callButton.setTitleColor(.white, for: .normal)
        callButton.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        callButton.tintColor = .white
        callButton.titleLabel?.font = .systemFont(ofSize: 11, weight: .heavy)
        callButton.backgroundColor = NinjaPalette.red
        callButton.layer.borderWidth = 1
        callButton.layer.borderColor = UIColor.white.withAlphaComponent(0.24).cgColor
        callButton.layer.cornerRadius = 12
        callButton.layer.cornerCurve = .continuous
        callButton.layer.shadowColor = NinjaPalette.red.cgColor
        callButton.layer.shadowOpacity = 0.28
        callButton.layer.shadowRadius = 11
        callButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        callButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        callButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -3, bottom: 0, right: 5)
        callButton.accessibilityLabel = "Call Mosquito Ninja at 609-313-6317"
        callButton.addAction(UIAction { [weak self] _ in
            self?.onCall?()
        }, for: .touchUpInside)

        let shell = UIView()
        shell.translatesAutoresizingMaskIntoConstraints = false
        addSubview(shell)
        shell.addSubview(brand)
        shell.addSubview(nav)
        shell.addSubview(callButton)

        NSLayoutConstraint.activate([
            shell.topAnchor.constraint(equalTo: topAnchor),
            shell.bottomAnchor.constraint(equalTo: bottomAnchor),
            shell.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            shell.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),

            brand.leadingAnchor.constraint(equalTo: shell.leadingAnchor),
            brand.centerYAnchor.constraint(equalTo: shell.centerYAnchor),

            callButton.trailingAnchor.constraint(equalTo: shell.trailingAnchor),
            callButton.centerYAnchor.constraint(equalTo: shell.centerYAnchor),
            callButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),

            nav.trailingAnchor.constraint(equalTo: callButton.leadingAnchor, constant: -24),
            nav.centerYAnchor.constraint(equalTo: shell.centerYAnchor),
            nav.leadingAnchor.constraint(greaterThanOrEqualTo: brand.trailingAnchor, constant: 28)
        ])

        setSelectedIndex(0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelectedIndex(_ index: Int) {
        for item in items {
            item.setSelected(item.index == index)
        }
    }
}

final class RootTabBarController: UITabBarController, UITabBarControllerDelegate {
    private let accent = UIColor(red: 0.878, green: 0.125, blue: 0.153, alpha: 1)
    private let websiteHeader = NinjaWebsiteHeaderView()
    private let websiteHeaderHeight: CGFloat = 82

    private var usesWebsiteHeader: Bool {
        traitCollection.userInterfaceIdiom == .pad
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configureAppearance()

        viewControllers = [
            makeNavigation(
                root: HomeViewController(),
                title: "Home",
                symbol: "house.fill"
            ),
            makeNavigation(
                root: ServicesViewController(),
                title: "Services",
                symbol: "shield.lefthalf.filled"
            ),
            makeNavigation(
                root: CustomerServiceViewController(),
                title: "My Service",
                symbol: "clock.arrow.circlepath"
            ),
            makeNavigation(
                root: QuoteViewController(),
                title: "Quote",
                symbol: "doc.text.fill"
            ),
            makeNavigation(
                root: ContactViewController(),
                title: "Contact",
                symbol: "phone.fill"
            )
        ]

        configureWebsiteStyleHeaderIfNeeded()
    }

    func showQuote(
        service: NinjaService? = nil,
        spring2027: Bool = false
    ) {
        selectedIndex = 3
        syncWebsiteHeaderSelection()

        if let nav = selectedViewController as? UINavigationController {
            nav.popToRootViewController(animated: false)

            if let service,
               let quote = nav.viewControllers.first as? QuoteViewController {
                quote.selectService(service)
            }

            if spring2027,
               let quote = nav.viewControllers.first as? QuoteViewController {
                quote.prepareForSpring2027Request()
            }
        }
    }

    func showAppointments() {
        selectedIndex = 2
        syncWebsiteHeaderSelection()

        guard let nav = selectedViewController as? UINavigationController else {
            return
        }

        nav.popToRootViewController(animated: false)

        if nav.viewControllers.first is CustomerServiceViewController {
            nav.pushViewController(
                AppointmentsViewController(),
                animated: false
            )
        }
    }

    private func makeNavigation(
        root: UIViewController,
        title: String,
        symbol: String
    ) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)

        nav.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: symbol),
            selectedImage: nil
        )

        nav.navigationBar.prefersLargeTitles = false
        return nav
    }

    private func configureWebsiteStyleHeaderIfNeeded() {
        guard usesWebsiteHeader else { return }

        tabBar.isHidden = true

        websiteHeader.onSelectTab = { [weak self] index in
            self?.selectWebsiteHeaderTab(index)
        }

        websiteHeader.onCall = {
            guard let url = URL(string: "tel:+16093136317") else { return }
            UIApplication.shared.open(url)
        }

        view.addSubview(websiteHeader)

        NSLayoutConstraint.activate([
            websiteHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            websiteHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            websiteHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            websiteHeader.heightAnchor.constraint(equalToConstant: websiteHeaderHeight)
        ])

        viewControllers?.forEach { controller in
            controller.additionalSafeAreaInsets.top = websiteHeaderHeight
        }

        syncWebsiteHeaderSelection()
    }

    private func selectWebsiteHeaderTab(_ index: Int) {
        guard let controllers = viewControllers,
              controllers.indices.contains(index) else {
            return
        }

        if selectedIndex == index,
           let nav = controllers[index] as? UINavigationController {
            nav.popToRootViewController(animated: true)
        } else {
            selectedIndex = index
        }

        websiteHeader.setSelectedIndex(index)
        NinjaHaptics.selection()
    }

    private func syncWebsiteHeaderSelection() {
        guard usesWebsiteHeader else { return }
        websiteHeader.setSelectedIndex(selectedIndex)
    }

    private func configureAppearance() {
        view.backgroundColor = NinjaPalette.ink
        tabBar.tintColor = accent
        tabBar.unselectedItemTintColor =
            UIColor.white.withAlphaComponent(0.52)
        tabBar.isTranslucent = false

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = NinjaPalette.ink
        tabAppearance.shadowColor =
            UIColor.white.withAlphaComponent(0.07)

        let itemAppearances = [
            tabAppearance.stackedLayoutAppearance,
            tabAppearance.inlineLayoutAppearance,
            tabAppearance.compactInlineLayoutAppearance
        ]

        for itemAppearance in itemAppearances {
            itemAppearance.normal.iconColor =
                UIColor.white.withAlphaComponent(0.50)

            itemAppearance.normal.titleTextAttributes = [
                .foregroundColor:
                    UIColor.white.withAlphaComponent(0.52),
                .font:
                    UIFont.systemFont(
                        ofSize: 10,
                        weight: .semibold
                    )
            ]

            itemAppearance.selected.iconColor = accent

            itemAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font:
                    UIFont.systemFont(
                        ofSize: 10,
                        weight: .bold
                    )
            ]
        }

        tabBar.standardAppearance = tabAppearance

        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = tabAppearance
        }

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = NinjaPalette.ink
        navAppearance.shadowColor =
            UIColor.white.withAlphaComponent(0.06)

        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font:
                UIFont.systemFont(
                    ofSize: 17,
                    weight: .bold
                )
        ]

        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        UINavigationBar.appearance().standardAppearance =
            navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance =
            navAppearance
        UINavigationBar.appearance().compactAppearance =
            navAppearance
        UINavigationBar.appearance().tintColor =
            UIColor.white
    }

    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {
        syncWebsiteHeaderSelection()
        NinjaHaptics.selection()
    }
}
