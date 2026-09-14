import UIKit
import WebKit

final class WebViewController:
    UIViewController,
    WKNavigationDelegate,
    WKUIDelegate
{
    private var webView: WKWebView!
    private let messageComposer = MessageComposer()

    private let page: String
    private let pageTitle: String

    private let progressView =
        UIProgressView(progressViewStyle: .bar)

    private let loadingContainer = UIView()
    private let loadingIndicator =
        NinjaActivityIndicator(frame: .zero)
    private let loadingLabel = UILabel()

    private let errorOverlay = UIView()
    private let errorIcon = UIImageView(
        image: UIImage(
            systemName: "exclamationmark.triangle.fill"
        )
    )
    private let errorTitle = UILabel()
    private let errorDetail = UILabel()
    private let retryButton = NinjaButton(frame: .zero)

    private var progressObservation:
        NSKeyValueObservation?

    init(
        page: String = "index.html",
        title: String = "Mosquito Ninja"
    ) {
        self.page = page
        self.pageTitle = title
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.page = "index.html"
        self.pageTitle = "Mosquito Ninja"
        super.init(coder: coder)
    }

    deinit {
        progressObservation?.invalidate()
    }

    private var webRoot: URL {
        guard let url =
            Bundle.main.resourceURL?
                .appendingPathComponent(
                    "Web",
                    isDirectory: true
                )
        else {
            fatalError(
                "Bundled Web directory is missing."
            )
        }

        return url
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = pageTitle
        view.backgroundColor = NinjaPalette.ink

        configureWebView()
        configureLoadingUI()
        configureErrorUI()
        observeProgress()

        loadLocalPage(page)
    }

    private func configureWebView() {
        let configuration =
            WKWebViewConfiguration()

        configuration
            .defaultWebpagePreferences
            .allowsContentJavaScript = true

        configuration
            .allowsInlineMediaPlayback = true

        webView = WKWebView(
            frame: .zero,
            configuration: configuration
        )

        webView.translatesAutoresizingMaskIntoConstraints =
            false

        webView.navigationDelegate = self
        webView.uiDelegate = self

        webView.allowsBackForwardNavigationGestures =
            true

        webView.scrollView.keyboardDismissMode =
            .interactive

        webView.scrollView.delaysContentTouches =
            true

        webView.scrollView.canCancelContentTouches =
            true

        webView.scrollView.decelerationRate =
            .normal

        webView.isOpaque = false
        webView.backgroundColor =
            NinjaPalette.ink

        webView.scrollView.backgroundColor =
            NinjaPalette.ink

        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(
                equalTo:
                    view.safeAreaLayoutGuide.topAnchor
            ),

            webView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            webView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            webView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
    }

    private func configureLoadingUI() {
        progressView.translatesAutoresizingMaskIntoConstraints =
            false

        progressView.progressTintColor =
            NinjaPalette.red

        progressView.trackTintColor =
            UIColor.white.withAlphaComponent(0.06)

        progressView.isHidden = true
        progressView.progress = 0

        view.addSubview(progressView)

        loadingContainer.translatesAutoresizingMaskIntoConstraints =
            false

        loadingContainer.backgroundColor =
            NinjaPalette.panel.withAlphaComponent(0.97)

        loadingContainer.layer.cornerRadius = 17
        loadingContainer.layer.cornerCurve =
            .continuous

        loadingContainer.layer.borderWidth = 1

        loadingContainer.layer.borderColor =
            UIColor.white
                .withAlphaComponent(0.10)
                .cgColor

        loadingContainer.alpha = 0
        loadingContainer.isHidden = true

        loadingIndicator.translatesAutoresizingMaskIntoConstraints =
            false

        loadingLabel.text =
            "LOADING \(pageTitle.uppercased())…"

        loadingLabel.textColor = .white

        loadingLabel.font =
            .systemFont(
                ofSize: 11,
                weight: .heavy
            )

        loadingLabel.numberOfLines = 0

        let row = UIStackView(
            arrangedSubviews: [
                loadingIndicator,
                loadingLabel
            ]
        )

        row.translatesAutoresizingMaskIntoConstraints =
            false

        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 11

        loadingContainer.addSubview(row)
        view.addSubview(loadingContainer)

        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(
                equalTo:
                    view.safeAreaLayoutGuide.topAnchor
            ),

            progressView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            progressView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            progressView.heightAnchor.constraint(
                equalToConstant: 2
            ),

            loadingIndicator.widthAnchor.constraint(
                equalToConstant: 28
            ),

            loadingIndicator.heightAnchor.constraint(
                equalToConstant: 28
            ),

            row.topAnchor.constraint(
                equalTo:
                    loadingContainer.topAnchor,
                constant: 13
            ),

            row.leadingAnchor.constraint(
                equalTo:
                    loadingContainer.leadingAnchor,
                constant: 15
            ),

            row.trailingAnchor.constraint(
                equalTo:
                    loadingContainer.trailingAnchor,
                constant: -15
            ),

            row.bottomAnchor.constraint(
                equalTo:
                    loadingContainer.bottomAnchor,
                constant: -13
            ),

            loadingContainer.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            loadingContainer.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),

            loadingContainer.leadingAnchor.constraint(
                greaterThanOrEqualTo:
                    view.leadingAnchor,
                constant: 28
            ),

            loadingContainer.trailingAnchor.constraint(
                lessThanOrEqualTo:
                    view.trailingAnchor,
                constant: -28
            )
        ])
    }

    private func configureErrorUI() {
        errorOverlay.translatesAutoresizingMaskIntoConstraints =
            false

        errorOverlay.backgroundColor =
            NinjaPalette.ink

        errorOverlay.isHidden = true

        errorIcon.translatesAutoresizingMaskIntoConstraints =
            false

        errorIcon.tintColor = NinjaPalette.red
        errorIcon.contentMode = .scaleAspectFit

        errorTitle.text = "CONTENT DIDN'T LOAD"
        errorTitle.textColor = .white

        errorTitle.font =
            .systemFont(
                ofSize: 22,
                weight: .black
            )

        errorTitle.textAlignment = .center
        errorTitle.numberOfLines = 0

        errorDetail.textColor =
            NinjaPalette.muted

        errorDetail.font =
            .systemFont(
                ofSize: 14,
                weight: .medium
            )

        errorDetail.textAlignment = .center
        errorDetail.numberOfLines = 0

        var config =
            UIButton.Configuration.filled()

        config.title = "TRY AGAIN"
        config.image =
            UIImage(
                systemName:
                    "arrow.clockwise"
            )

        config.imagePadding = 8

        config.baseBackgroundColor =
            NinjaPalette.red

        config.baseForegroundColor = .white

        config.cornerStyle = .medium

        config.contentInsets =
            NSDirectionalEdgeInsets(
                top: 14,
                leading: 20,
                bottom: 14,
                trailing: 20
            )

        retryButton.configuration = config
        retryButton.hapticStyle = .medium

        retryButton.addTarget(
            self,
            action: #selector(retryLoad),
            for: .touchUpInside
        )

        retryButton.heightAnchor.constraint(
            greaterThanOrEqualToConstant: 52
        ).isActive = true

        let stack = UIStackView(
            arrangedSubviews: [
                errorIcon,
                errorTitle,
                errorDetail,
                retryButton
            ]
        )

        stack.translatesAutoresizingMaskIntoConstraints =
            false

        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 15

        stack.setCustomSpacing(
            20,
            after: errorDetail
        )

        errorOverlay.addSubview(stack)
        view.addSubview(errorOverlay)

        NSLayoutConstraint.activate([
            errorIcon.widthAnchor.constraint(
                equalToConstant: 42
            ),

            errorIcon.heightAnchor.constraint(
                equalToConstant: 42
            ),

            stack.centerYAnchor.constraint(
                equalTo:
                    errorOverlay.centerYAnchor
            ),

            stack.leadingAnchor.constraint(
                equalTo:
                    errorOverlay.leadingAnchor,
                constant: 32
            ),

            stack.trailingAnchor.constraint(
                equalTo:
                    errorOverlay.trailingAnchor,
                constant: -32
            ),

            errorOverlay.topAnchor.constraint(
                equalTo:
                    view.safeAreaLayoutGuide.topAnchor
            ),

            errorOverlay.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            errorOverlay.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            errorOverlay.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
    }

    private func observeProgress() {
        progressObservation =
            webView.observe(
                \.estimatedProgress,
                options: [.new]
            ) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.progressView.setProgress(
                        Float(
                            webView.estimatedProgress
                        ),
                        animated: true
                    )
                }
            }
    }

    private func setLoading(
        _ loading: Bool
    ) {
        if loading {
            errorOverlay.isHidden = true
            webView.isHidden = false

            progressView.progress = 0.04
            progressView.isHidden = false

            loadingContainer.isHidden = false
            loadingIndicator.startAnimating()

            UIView.animate(
                withDuration: 0.16
            ) {
                self.loadingContainer.alpha = 1
            }

            return
        }

        progressView.setProgress(
            1,
            animated: true
        )

        loadingIndicator.stopAnimating()

        UIView.animate(
            withDuration: 0.18,
            animations: {
                self.loadingContainer.alpha = 0
            }
        ) { _ in
            self.loadingContainer.isHidden = true
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.18
        ) {
            self.progressView.isHidden = true
            self.progressView.progress = 0
        }
    }

    private func showLoadError(
        _ error: Error?
    ) {
        setLoading(false)

        let reason =
            error?.localizedDescription ??
            "The page stopped responding."

        errorDetail.text =
            reason +
            "\n\nNothing is frozen. Tap Try Again to reload this page."

        webView.isHidden = true
        errorOverlay.isHidden = false

        view.bringSubviewToFront(
            errorOverlay
        )

        NinjaHaptics.warning()
    }

    @objc private func retryLoad() {
        errorOverlay.isHidden = true
        webView.isHidden = false

        NinjaHaptics.selection()

        if webView.url != nil {
            webView.reload()
        } else {
            loadLocalPage(page)
        }
    }

    private func localURL(
        for page: String,
        fragment: String? = nil
    ) -> URL {
        var url =
            webRoot.appendingPathComponent(page)

        if let fragment,
           !fragment.isEmpty
        {
            var components =
                URLComponents(
                    url: url,
                    resolvingAgainstBaseURL: false
                )

            components?.fragment =
                fragment

            if let fragmented =
                components?.url
            {
                url = fragmented
            }
        }

        return url
    }

    private func loadLocalPage(
        _ page: String,
        fragment: String? = nil
    ) {
        let url =
            localURL(
                for: page,
                fragment: fragment
            )

        errorOverlay.isHidden = true
        webView.isHidden = false

        setLoading(true)

        webView.loadFileURL(
            url,
            allowingReadAccessTo: webRoot
        )
    }

    private func openExternal(
        _ url: URL?
    ) {
        guard let url else {
            showExternalActionError()
            return
        }

        if url.scheme?.lowercased() == "sms" {
            messageComposer.present(from: self, smsURL: url)
            return
        }

        UIApplication.shared.open(
            url,
            options: [:]
        ) { [weak self] success in
            guard !success else {
                return
            }

            DispatchQueue.main.async {
                self?.showExternalActionError()
            }
        }
    }

    private func showExternalActionError() {
        NinjaHaptics.warning()

        let alert = UIAlertController(
            title: "Unable to Open",
            message:
                "iOS could not open that action. Check your device settings and try again.",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )

        present(
            alert,
            animated: true
        )
    }

    private func routeQuoteURL(_ url: URL) -> Bool {
        guard url.fragment == "quote",
              url.isFileURL || ["njbugninja.com", "www.njbugninja.com"].contains(url.host?.lowercased() ?? ""),
              let root = tabBarController as? RootTabBarController else { return false }
        root.showQuote()
        return true
    }

    private func routeInternalWebsiteURL(
        _ url: URL
    ) -> Bool {
        guard
            let host =
                url.host?.lowercased(),
            host == "njbugninja.com" ||
                host == "www.njbugninja.com"
        else {
            return false
        }

        let rawPath = url.path

        let localPage =
            (rawPath.isEmpty ||
             rawPath == "/")
            ? "index.html"
            : String(
                rawPath.dropFirst()
            )

        guard
            localPage.hasSuffix(".html") ||
            localPage == "index.html"
        else {
            return false
        }

        loadLocalPage(
            localPage,
            fragment: url.fragment
        )

        return true
    }

    func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation
            navigation: WKNavigation!
    ) {
        setLoading(true)
    }

    func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        setLoading(false)
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        showLoadError(error)
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation
            navigation: WKNavigation!,
        withError error: Error
    ) {
        showLoadError(error)
    }

    func webViewWebContentProcessDidTerminate(
        _ webView: WKWebView
    ) {
        showLoadError(nil)
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction:
            WKNavigationAction,
        decisionHandler:
            @escaping (
                WKNavigationActionPolicy
            ) -> Void
    ) {
        guard let url =
            navigationAction.request.url
        else {
            decisionHandler(.allow)
            return
        }

        if routeQuoteURL(url) {
            decisionHandler(.cancel)
            return
        }

        if url.isFileURL {
            decisionHandler(.allow)
            return
        }

        let scheme =
            url.scheme?.lowercased() ?? ""

        if [
            "tel",
            "sms",
            "mailto"
        ].contains(scheme) {
            openExternal(url)
            decisionHandler(.cancel)
            return
        }

        if [
            "http",
            "https"
        ].contains(scheme) {
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
        createWebViewWith configuration:
            WKWebViewConfiguration,
        for navigationAction:
            WKNavigationAction,
        windowFeatures:
            WKWindowFeatures
    ) -> WKWebView? {
        if let url =
            navigationAction.request.url
        {
            if routeQuoteURL(url) { return nil }
            if url.isFileURL {
                webView.load(
                    navigationAction.request
                )
            } else {
                openExternal(url)
            }
        }

        return nil
    }
}
