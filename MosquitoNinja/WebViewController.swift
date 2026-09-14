import UIKit
import WebKit

final class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private var webView: WKWebView!
    private let page: String
    private let pageTitle: String

    init(page: String = "index.html", title: String = "Mosquito Ninja") {
        self.page = page
        self.pageTitle = title
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.page = "index.html"
        self.pageTitle = "Mosquito Ninja"
        super.init(coder: coder)
    }

    private var webRoot: URL {
        guard let url = Bundle.main.resourceURL?.appendingPathComponent("Web", isDirectory: true) else {
            fatalError("Bundled Web directory is missing.")
        }
        return url
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = pageTitle
        view.backgroundColor = NinjaPalette.ink
        configureWebView()
        loadLocalPage(page)
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
        webView.scrollView.delaysContentTouches = true
        webView.scrollView.canCancelContentTouches = true
        webView.scrollView.decelerationRate = .normal
        webView.isOpaque = false
        webView.backgroundColor = NinjaPalette.ink
        webView.scrollView.backgroundColor = NinjaPalette.ink
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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

    private func openExternal(_ url: URL?) {
        guard let url else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func routeInternalWebsiteURL(_ url: URL) -> Bool {
        guard let host = url.host?.lowercased(), host == "njbugninja.com" || host == "www.njbugninja.com" else { return false }
        let rawPath = url.path
        let localPage = (rawPath.isEmpty || rawPath == "/") ? "index.html" : String(rawPath.dropFirst())
        guard localPage.hasSuffix(".html") || localPage == "index.html" else { return false }
        loadLocalPage(localPage, fragment: url.fragment)
        return true
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else { decisionHandler(.allow); return }
        if url.isFileURL { decisionHandler(.allow); return }
        let scheme = url.scheme?.lowercased() ?? ""
        if ["tel", "sms", "mailto"].contains(scheme) { openExternal(url); decisionHandler(.cancel); return }
        if ["http", "https"].contains(scheme) {
            if routeInternalWebsiteURL(url) { decisionHandler(.cancel) } else { openExternal(url); decisionHandler(.cancel) }
            return
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            if url.isFileURL { webView.load(navigationAction.request) } else { openExternal(url) }
        }
        return nil
    }
}
