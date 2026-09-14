import UIKit
import WebKit

final class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private var webView: WKWebView!
    private let actionBar = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
    private let accent = UIColor(red: 0.878, green: 0.125, blue: 0.153, alpha: 1)
    private let green = UIColor(red: 0.561, green: 0.741, blue: 0.180, alpha: 1)

    private var webRoot: URL {
        guard let url = Bundle.main.resourceURL?.appendingPathComponent("Web", isDirectory: true) else {
            fatalError("Bundled Web directory is missing.")
        }
        return url
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.031, green: 0.039, blue: 0.035, alpha: 1)
        configureWebView()
        configureActionBar()
        loadLocalPage("index.html")
    }

    private func configureWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.allowsInlineMediaPlayback = true

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.keyboardDismissMode = .interactive
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 0.031, green: 0.039, blue: 0.035, alpha: 1)
        webView.scrollView.backgroundColor = webView.backgroundColor

        view.addSubview(webView)
    }

    private func configureActionBar() {
        actionBar.translatesAutoresizingMaskIntoConstraints = false
        actionBar.layer.borderWidth = 0.5
        actionBar.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        view.addSubview(actionBar)

        let quote = makeAction(title: "QUOTE", symbol: "doc.text.fill", color: accent, action: #selector(openQuote))
        let call = makeAction(title: "CALL", symbol: "phone.fill", color: green, action: #selector(callJosh))
        let text = makeAction(title: "TEXT", symbol: "message.fill", color: .white, action: #selector(textJosh))

        let stack = UIStackView(arrangedSubviews: [quote, call, text])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        actionBar.contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            actionBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            actionBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            actionBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.leadingAnchor.constraint(equalTo: actionBar.contentView.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: actionBar.contentView.trailingAnchor, constant: -10),
            stack.topAnchor.constraint(equalTo: actionBar.contentView.topAnchor, constant: 7),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            stack.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),

            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: actionBar.topAnchor)
        ])
    }

    private func makeAction(
        title: String,
        symbol: String,
        color: UIColor,
        action: Selector
    ) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = UIImage(systemName: symbol)
        config.imagePlacement = .top
        config.imagePadding = 4
        config.baseForegroundColor = color
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 11, weight: .bold)
            return outgoing
        }

        let button = UIButton(configuration: config)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.accessibilityLabel = title.capitalized
        return button
    }

    private func localURL(for page: String, fragment: String? = nil) -> URL {
        var url = webRoot.appendingPathComponent(page)
        if let fragment, !fragment.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.fragment = fragment
            if let fragmented = components?.url { url = fragmented }
        }
        return url
    }

    private func loadLocalPage(_ page: String, fragment: String? = nil) {
        let url = localURL(for: page, fragment: fragment)
        webView.loadFileURL(url, allowingReadAccessTo: webRoot)
    }

    @objc private func openQuote() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        loadLocalPage("index.html", fragment: "quote")
    }

    @objc private func callJosh() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        openExternal(URL(string: "tel:+16093136317"))
    }

    @objc private func textJosh() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        openExternal(URL(string: "sms:+16093136317"))
    }

    private func openExternal(_ url: URL?) {
        guard let url else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func routeInternalWebsiteURL(_ url: URL) -> Bool {
        guard let host = url.host?.lowercased(), host == "njbugninja.com" || host == "www.njbugninja.com" else {
            return false
        }
        let rawPath = url.path
        let page: String
        if rawPath.isEmpty || rawPath == "/" {
            page = "index.html"
        } else {
            page = String(rawPath.dropFirst())
        }
        guard page.hasSuffix(".html") || page == "index.html" else { return false }
        loadLocalPage(page, fragment: url.fragment)
        return true
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        if url.isFileURL {
            decisionHandler(.allow)
            return
        }

        let scheme = url.scheme?.lowercased() ?? ""
        if ["tel", "sms", "mailto"].contains(scheme) {
            openExternal(url)
            decisionHandler(.cancel)
            return
        }

        if ["http", "https"].contains(scheme) {
            if routeInternalWebsiteURL(url) {
                decisionHandler(.cancel)
            } else {
                openExternal(url)
                decisionHandler(.cancel)
            }
            return
        }

        decisionHandler(.allow)
    }

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let url = navigationAction.request.url {
            if url.isFileURL {
                webView.load(navigationAction.request)
            } else {
                openExternal(url)
            }
        }
        return nil
    }
}
