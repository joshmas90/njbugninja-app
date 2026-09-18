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

    override var intrinsicContentSize: CGSize {
        CGSize(width: max(44, ceil(titleLabel.intrinsicContentSize.width)), height: 44)
    }

    func setSelected(_ selected: Bool) {
        indicator.isHidden = !selected
        titleLabel.textColor = selected ? .white : UIColor.white.withAlphaComponent(0.86)
        accessibilityTraits = selected ? [.button, .selected] : .button
    }
}

private final class NinjaWebsiteHeaderView: UIView {
    private enum LayoutStyle: Equatable {
        case full, condensed, menu
    }

    var onSelectTab: ((Int) -> Void)?
    var onCall: (() -> Void)?

    private let menuEntries: [
        (title: String, symbol: String, index: Int)
    ]
    private let items: [NinjaHeaderItem]
    private let brandCopy = UIStackView()
    private let nav = UIStackView()
    private let shell = UIStackView()
    private let callButton = NinjaButton(type: .system)
    private let menuButton = NinjaButton(type: .system)
    private let brandMarkSize: CGFloat = 44
    private let brandCopySpacing: CGFloat = 10
    private let horizontalPadding: CGFloat = 28
    private let fullCallTitle = "CALL  •  609-313-6317"
    private var fullCallWidth: CGFloat = 0
    private var condensedCallWidthConstraint: NSLayoutConstraint?
    private var selectedIndex = 0
    private var layoutStyle: LayoutStyle?

    override init(frame: CGRect) {
        let entries: [
            (title: String, symbol: String, index: Int)
        ] = [
            ("Home", "house.fill", 0),
            ("Services", "shield.lefthalf.filled", 1),
            ("Fly Control", "ant.fill", 5),
            ("My Service", "clock.arrow.circlepath", 2),
            ("Quote", "doc.text.fill", 3),
            ("Contact", "phone.fill", 4)
        ]

        menuEntries = entries
        items = entries.map {
            NinjaHeaderItem(title: $0.title, index: $0.index)
        }

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
        brand.setContentCompressionResistancePriority(.required, for: .horizontal)

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
        brandName.adjustsFontSizeToFitWidth = true
        brandName.minimumScaleFactor = 0.82

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
        brandSubtitle.text = "OUTDOOR PEST CONTROL"
        brandSubtitle.textColor = UIColor.white.withAlphaComponent(0.70)
        brandSubtitle.font = .systemFont(ofSize: 7.5, weight: .bold)
        brandSubtitle.adjustsFontSizeToFitWidth = true
        brandSubtitle.minimumScaleFactor = 0.8

        brandCopy.addArrangedSubview(brandName)
        brandCopy.addArrangedSubview(brandSubtitle)
        brandCopy.translatesAutoresizingMaskIntoConstraints = false
        brandCopy.axis = .vertical
        brandCopy.spacing = 3
        brandCopy.alignment = .leading

        let brandContent = UIStackView(arrangedSubviews: [mark, brandCopy])
        brandContent.translatesAutoresizingMaskIntoConstraints = false
        brandContent.axis = .horizontal
        brandContent.alignment = .center
        brandContent.spacing = brandCopySpacing
        brand.addSubview(brandContent)

        NSLayoutConstraint.activate([
            brandContent.leadingAnchor.constraint(equalTo: brand.leadingAnchor),
            brandContent.trailingAnchor.constraint(equalTo: brand.trailingAnchor),
            brandContent.centerYAnchor.constraint(equalTo: brand.centerYAnchor),
            mark.widthAnchor.constraint(equalToConstant: brandMarkSize),
            mark.heightAnchor.constraint(equalToConstant: brandMarkSize),
            brand.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ])

        nav.translatesAutoresizingMaskIntoConstraints = false
        nav.axis = .horizontal
        nav.alignment = .center
        nav.spacing = 26
        nav.accessibilityIdentifier = "header-inline-navigation"
        nav.setContentCompressionResistancePriority(.required, for: .horizontal)

        for item in items {
            nav.addArrangedSubview(item)
            item.addAction(UIAction { [weak self, weak item] _ in
                guard let index = item?.index else { return }
                self?.onSelectTab?(index)
            }, for: .touchUpInside)
        }

        callButton.translatesAutoresizingMaskIntoConstraints = false
        callButton.setTitle(fullCallTitle, for: .normal)
        callButton.setTitleColor(.white, for: .normal)
        callButton.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        callButton.tintColor = NinjaPalette.red
        callButton.titleLabel?.font = .systemFont(ofSize: 11, weight: .heavy)
        callButton.backgroundColor = UIColor(
            red: 0.035,
            green: 0.055,
            blue: 0.043,
            alpha: 0.96
        )
        callButton.layer.borderWidth = 1
        callButton.layer.borderColor = NinjaPalette.red.withAlphaComponent(0.48).cgColor
        callButton.layer.cornerRadius = 12
        callButton.layer.cornerCurve = .continuous
        callButton.layer.shadowColor = NinjaPalette.red.cgColor
        callButton.layer.shadowOpacity = 0.20
        callButton.layer.shadowRadius = 13
        callButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        callButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        callButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -3, bottom: 0, right: 5)
        callButton.accessibilityLabel = "Call Mosquito Ninja at 609-313-6317"
        callButton.accessibilityIdentifier = "header-call"
        callButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        // Preserve the expanded measurement while the compact style hides its title.
        fullCallWidth = max(44, ceil(callButton.intrinsicContentSize.width))
        condensedCallWidthConstraint = callButton.widthAnchor.constraint(equalToConstant: 44)
        callButton.addAction(UIAction { [weak self] _ in
            self?.onCall?()
        }, for: .touchUpInside)

        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.setTitle("MENU", for: .normal)
        menuButton.setTitleColor(.white, for: .normal)
        menuButton.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        menuButton.tintColor = NinjaPalette.red
        menuButton.titleLabel?.font = .systemFont(ofSize: 11, weight: .heavy)
        menuButton.backgroundColor = UIColor(
            red: 0.035,
            green: 0.055,
            blue: 0.043,
            alpha: 0.96
        )
        menuButton.layer.borderWidth = 1
        menuButton.layer.borderColor = NinjaPalette.red.withAlphaComponent(0.48).cgColor
        menuButton.layer.cornerRadius = 12
        menuButton.layer.cornerCurve = .continuous
        menuButton.layer.shadowColor = NinjaPalette.red.cgColor
        menuButton.layer.shadowOpacity = 0.18
        menuButton.layer.shadowRadius = 11
        menuButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        menuButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
        menuButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -3, bottom: 0, right: 6)
        menuButton.accessibilityLabel = "Open Mosquito Ninja navigation menu"
        menuButton.accessibilityIdentifier = "header-menu"
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let sections: [UIView] = [
            brand,
            spacer,
            nav,
            callButton,
            menuButton
        ]
        sections.forEach { shell.addArrangedSubview($0) }
        shell.translatesAutoresizingMaskIntoConstraints = false
        shell.axis = .horizontal
        shell.alignment = .center
        shell.spacing = 24
        shell.isLayoutMarginsRelativeArrangement = true
        shell.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 0, leading: horizontalPadding, bottom: 0, trailing: horizontalPadding
        )

        addSubview(shell)

        NSLayoutConstraint.activate([
            shell.topAnchor.constraint(equalTo: topAnchor),
            shell.bottomAnchor.constraint(equalTo: bottomAnchor),
            shell.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            shell.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            callButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            menuButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])

        // Start compact until the first layout supplies the actual window width.
        nav.isHidden = true
        callButton.isHidden = true
        brandCopy.isHidden = true
        updateMenu()
        setSelectedIndex(0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        updateResponsiveLayout(for: bounds.width)
        super.layoutSubviews()
    }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        setNeedsLayout()
    }

    func setSelectedIndex(_ index: Int) {
        selectedIndex = index
        for item in items {
            item.setSelected(item.index == index)
        }
        updateMenu()
    }

    private func updateResponsiveLayout(for width: CGFloat) {
        let availableWidth = width - safeAreaInsets.left - safeAreaInsets.right
        guard availableWidth > 0 else { return }

        // Measure the content, not its current frames: hidden/compressed views
        // must report the same preferred widths when the window grows again.
        let copyWidth = brandCopy.arrangedSubviews.reduce(CGFloat.zero) {
            max($0, $1.intrinsicContentSize.width)
        }
        let brandWidth = brandMarkSize + brandCopySpacing + ceil(copyWidth)
        let itemWidths = items.reduce(CGFloat.zero) {
            $0 + $1.intrinsicContentSize.width
        }
        let navigationGaps = CGFloat(max(0, items.count - 1))
        // Stable measurements let the header both collapse AND expand again.
        // Keep the links visible at intermediate widths by shortening only Call.
        let fullWidth = brandWidth + itemWidths + navigationGaps * 26
            + fullCallWidth + 24 * 3 + horizontalPadding * 2 + 24
        let condensedWidth = brandWidth + itemWidths + navigationGaps * 16
            + 44 + 18 * 3 + 20 * 2 + 16
        let style: LayoutStyle
        if availableWidth >= ceil(fullWidth) {
            style = .full
        } else if availableWidth >= ceil(condensedWidth) {
            style = .condensed
        } else {
            style = .menu
        }
        let shouldCompact = style == .menu

        let padding: CGFloat = style == .full ? horizontalPadding : (availableWidth < 500 ? 16 : 20)
        let sectionSpacing: CGFloat = style == .full ? 24 : 18
        let compactWidth = brandWidth + ceil(menuButton.intrinsicContentSize.width)
            + sectionSpacing * 2 + padding * 2
        // Very narrow Split View windows keep the tappable logo and menu.
        let hideBrandCopy = shouldCompact && availableWidth < ceil(compactWidth)
        guard layoutStyle != style
            || brandCopy.isHidden != hideBrandCopy
            || shell.directionalLayoutMargins.leading != padding else { return }
        layoutStyle = style

        UIView.performWithoutAnimation {
            condensedCallWidthConstraint?.isActive = false
            nav.spacing = style == .full ? 26 : 16
            shell.spacing = sectionSpacing
            callButton.setTitle(style == .full ? fullCallTitle : nil, for: .normal)
            callButton.contentEdgeInsets = UIEdgeInsets(
                top: 10, left: style == .full ? 15 : 12,
                bottom: 10, right: style == .full ? 15 : 12
            )
            callButton.imageEdgeInsets = style == .full
                ? UIEdgeInsets(top: 0, left: -3, bottom: 0, right: 5) : .zero
            nav.isHidden = shouldCompact
            callButton.isHidden = shouldCompact
            menuButton.isHidden = !shouldCompact
            condensedCallWidthConstraint?.isActive = style == .condensed
            brandCopy.isHidden = hideBrandCopy
            shell.directionalLayoutMargins = NSDirectionalEdgeInsets(
                top: 0, leading: padding, bottom: 0, trailing: padding
            )
        }
    }

    private func updateMenu() {
        menuButton.accessibilityValue =
            menuEntries.first(where: { $0.index == selectedIndex })?.title

        let navigationActions = menuEntries.map { entry in
            UIAction(
                title: entry.title,
                image: UIImage(systemName: entry.symbol),
                state: selectedIndex == entry.index ? .on : .off
            ) { [weak self] _ in
                self?.onSelectTab?(entry.index)
            }
        }

        let callAction = UIAction(
            title: "Call 609-313-6317",
            image: UIImage(systemName: "phone.fill")
        ) { [weak self] _ in
            self?.onCall?()
        }

        menuButton.menu = UIMenu(
            title: "Mosquito Ninja",
            children: navigationActions + [callAction]
        )
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

    private func showFlyControlFromHeader() {
        guard let controllers = viewControllers,
              controllers.indices.contains(1),
              let nav = controllers[1] as? UINavigationController else {
            return
        }

        selectedIndex = 1
        nav.popToRootViewController(animated: false)
        nav.pushViewController(
            ServiceDetailViewController(service: .fly),
            animated: true
        )
        websiteHeader.setSelectedIndex(5)
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
        if index == 5 {
            showFlyControlFromHeader()
            NinjaHaptics.selection()
            return
        }

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
