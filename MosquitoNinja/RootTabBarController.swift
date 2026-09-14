import UIKit

final class RootTabBarController: UITabBarController, UITabBarControllerDelegate {
    private let accent = UIColor(red: 0.878, green: 0.125, blue: 0.153, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configureAppearance()
        viewControllers = [
            makeNavigation(root: HomeViewController(), title: "Home", symbol: "house.fill"),
            makeNavigation(root: ServicesViewController(), title: "Services", symbol: "shield.lefthalf.filled"),
            makeNavigation(root: AppointmentsViewController(), title: "Appointments", symbol: "calendar.badge.clock"),
            makeNavigation(root: QuoteViewController(), title: "Quote", symbol: "doc.text.fill"),
            makeNavigation(root: ContactViewController(), title: "Contact", symbol: "phone.fill")
        ]
    }

    func showAppointments() {
        selectedIndex = 2
        if let nav = selectedViewController as? UINavigationController {
            nav.popToRootViewController(animated: false)
        }
    }

    private func makeNavigation(root: UIViewController, title: String, symbol: String) -> UINavigationController {
        root.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: symbol), selectedImage: nil)
        let nav = UINavigationController(rootViewController: root)
        nav.navigationBar.prefersLargeTitles = false
        return nav
    }

    private func configureAppearance() {
        view.backgroundColor = .black
        tabBar.tintColor = accent
        tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.58)

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(red: 0.025, green: 0.03, blue: 0.027, alpha: 1)
        tabAppearance.shadowColor = UIColor.white.withAlphaComponent(0.08)
        tabBar.standardAppearance = tabAppearance
        if #available(iOS 15.0, *) { tabBar.scrollEdgeAppearance = tabAppearance }

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(red: 0.025, green: 0.03, blue: 0.027, alpha: 1)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = .white
    }

    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {
        NinjaHaptics.selection()
    }

}
