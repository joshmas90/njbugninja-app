import UIKit

final class RootTabBarController: UITabBarController, UITabBarControllerDelegate {
    private let accent = UIColor(red: 0.878, green: 0.125, blue: 0.153, alpha: 1)

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
    }

    func showQuote(service: NinjaService? = nil) {
        selectedIndex = 3

        if let nav = selectedViewController as? UINavigationController {
            nav.popToRootViewController(animated: false)

            if let service,
               let quote = nav.viewControllers.first as? QuoteViewController {
                quote.selectService(service)
            }
        }
    }

    func showAppointments() {
        selectedIndex = 2

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
        NinjaHaptics.selection()
    }
}
