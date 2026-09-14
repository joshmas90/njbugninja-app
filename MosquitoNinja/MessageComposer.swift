import UIKit
import MessageUI

/// Retained by each screen because MessageUI's delegate is weak.
/// Sending always requires the customer's tap in Apple's in-app composer.
final class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {
    enum Kind: Equatable {
        case text
        case quote
    }

    private weak var presenter: UIViewController?
    private weak var activeComposer: MFMessageComposeViewController?
    private var isPresenting = false
    private var isFinishing = false
    private var kind: Kind = .text
    private var preparedBody = ""

    func present(from presenter: UIViewController, body: String = "", kind: Kind = .text) {
        guard !isPresenting,
              presenter.presentedViewController == nil,
              presenter.viewIfLoaded?.window != nil else { return }

        preparedBody = body
        self.kind = kind
        self.presenter = presenter
        presenter.view.endEditing(true)

        guard MFMessageComposeViewController.canSendText() else {
            showUnavailable(from: presenter)
            return
        }

        isPresenting = true
        isFinishing = false
        let composer = MFMessageComposeViewController()
        composer.messageComposeDelegate = self
        composer.recipients = ["+16093136317"]
        composer.body = body
        composer.modalPresentationStyle = .pageSheet
        // Use the explicit Cancel button so every exit reports a result.
        composer.isModalInPresentation = true
        activeComposer = composer
        presenter.present(composer, animated: true)
    }

    /// Bundled reference pages use SMS links; handle them without leaving the app.
    func present(from presenter: UIViewController, smsURL: URL) {
        let body = URLComponents(url: smsURL, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "body" })?.value ?? ""
        let kind: Kind = body.hasPrefix("Hi Mosquito Ninja, I'd like a property quote.")
            ? .quote : .text
        present(from: presenter, body: body, kind: kind)
    }

    func messageComposeViewController(
        _ controller: MFMessageComposeViewController,
        didFinishWith result: MessageComposeResult
    ) {
        guard controller === activeComposer, !isFinishing else { return }
        isFinishing = true
        // MessageUI exposes initial content, not a guaranteed copy of edits.
        // The quote form remains untouched; do not promise to save composer edits.

        controller.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.activeComposer = nil
            self.isPresenting = false
            self.isFinishing = false

            let title: String
            let detail: String
            let feedback: NinjaFeedbackKind
            switch result {
            case .sent:
                self.preparedBody = ""
                title = self.kind == .quote ? "Request sent" : "Message sent"
                // Apple's .sent means queued OR sent, not delivered or received.
                detail = "iOS accepted your text for sending. Delivery and replies are handled by Messages."
                feedback = .success
            case .cancelled:
                title = "Nothing sent"
                detail = self.kind == .quote
                    ? "Your quote details are still here whenever you're ready."
                    : "You can write a message again whenever you're ready."
                feedback = .info
            case .failed:
                title = "Couldn't send"
                detail = self.kind == .quote
                    ? "Your quote details are still here. Check your connection, then tap Review & Send to retry."
                    : "Check your connection, then tap Text to try again."
                feedback = .error
            @unknown default:
                title = "Send status unavailable"
                detail = "Check Messages before trying again to avoid sending twice."
                feedback = .warning
            }
            self.presenter?.showFeedback(title: title, detail: detail, kind: feedback, duration: 5)
        }
    }

    private func showUnavailable(from presenter: UIViewController) {
        let alert = UIAlertController(
            title: "Texting isn't available",
            message: "This device isn't set up to send texts. Nothing has been sent. You can keep your details here or copy them to use later.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Keep editing", style: .cancel))
        let copyTitle = preparedBody.isEmpty ? "Copy phone number" : "Copy message"
        alert.addAction(UIAlertAction(title: copyTitle, style: .default) { [weak self] _ in
            guard let self else { return }
            let value = self.preparedBody.isEmpty ? "609-313-6317" : self.preparedBody
            UIPasteboard.general.string = value
        })
        presenter.present(alert, animated: true)
    }
}
