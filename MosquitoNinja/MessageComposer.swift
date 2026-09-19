import UIKit
import MessageUI

/// Retained by each screen because MessageUI's delegate is weak.
/// Sending always requires the customer's tap in Apple's in-app composer.
final class MessageComposer:
    NSObject,
    MFMessageComposeViewControllerDelegate,
    MFMailComposeViewControllerDelegate
{
    enum Kind: Equatable {
        case text
        case quote
    }

    private weak var presenter: UIViewController?
    private weak var activeComposer: MFMessageComposeViewController?
    private weak var activeMailComposer: MFMailComposeViewController?
    private var isPresenting = false
    private var isFinishing = false
    private var kind: Kind = .text
    private var preparedBody = ""
    private var preparedImages: [UIImage] = []
    private var acceptedAttachmentCount = 0

    func present(
        from presenter: UIViewController,
        body: String = "",
        kind: Kind = .text,
        images: [UIImage] = []
    ) {
        guard
            !isPresenting,
            presenter.presentedViewController == nil,
            presenter.viewIfLoaded?.window != nil
        else { return }

        preparedBody = body
        preparedImages = Array(images.prefix(3))
        acceptedAttachmentCount = 0
        self.kind = kind
        self.presenter = presenter
        presenter.view.endEditing(true)

        guard MFMessageComposeViewController.canSendText() else {
            showUnavailable(from: presenter)
            return
        }

        if !preparedImages.isEmpty,
           !MFMessageComposeViewController.canSendAttachments() {
            showAttachmentsUnavailable(from: presenter)
            return
        }

        presentComposer(from: presenter)
    }

    private func presentComposer(from presenter: UIViewController) {
        let composer = MFMessageComposeViewController()
        composer.messageComposeDelegate = self
        composer.recipients = ["+16093136317"]
        composer.body = preparedBody
        composer.modalPresentationStyle = .pageSheet
        composer.isModalInPresentation = true

        var acceptedCount = 0

        for (index, image) in preparedImages.enumerated() {
            guard let data = preparedJPEG(from: image) else { continue }

            let accepted = composer.addAttachmentData(
                data,
                typeIdentifier: "public.jpeg",
                filename: "property-photo-\(index + 1).jpg"
            )

            if accepted {
                acceptedCount += 1
            }
        }

        guard acceptedCount == preparedImages.count else {
            showAttachmentPreparationIssue(
                from: presenter,
                acceptedCount: acceptedCount,
                expectedCount: preparedImages.count,
                retry: { [weak self, weak presenter] in
                    guard let self, let presenter else { return }
                    self.presentComposer(from: presenter)
                },
                continueSending: { [weak self, weak presenter] in
                    guard let self, let presenter else { return }
                    self.presentMessageComposer(
                        composer,
                        acceptedAttachmentCount: acceptedCount,
                        from: presenter
                    )
                }
            )
            return
        }

        presentMessageComposer(
            composer,
            acceptedAttachmentCount: acceptedCount,
            from: presenter
        )
    }

    private func presentMessageComposer(
        _ composer: MFMessageComposeViewController,
        acceptedAttachmentCount: Int,
        from presenter: UIViewController
    ) {
        isPresenting = true
        isFinishing = false
        self.acceptedAttachmentCount = acceptedAttachmentCount
        activeComposer = composer
        presenter.present(composer, animated: true)
    }

    /// Bundled reference pages use SMS links; handle them without leaving the app.
    func present(from presenter: UIViewController, smsURL: URL) {
        let body = URLComponents(url: smsURL, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == "body" })?
            .value ?? ""

        let kind: Kind =
            body.hasPrefix("Hi Mosquito Ninja, I'd like a property quote.")
            ? .quote
            : .text

        present(from: presenter, body: body, kind: kind)
    }

    func messageComposeViewController(
        _ controller: MFMessageComposeViewController,
        didFinishWith result: MessageComposeResult
    ) {
        guard controller === activeComposer, !isFinishing else { return }
        isFinishing = true

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
                let sentPhotoCount = self.acceptedAttachmentCount
                self.preparedBody = ""
                self.preparedImages = []
                self.acceptedAttachmentCount = 0

                title = self.kind == .quote ? "Request sent" : "Message sent"
                detail = self.kind == .quote
                    ? (
                        sentPhotoCount > 0
                        ? "iOS accepted your quote request and \(sentPhotoCount) photo attachment\(sentPhotoCount == 1 ? "" : "s") for sending. Delivery is handled by Messages."
                        : "iOS accepted your quote request for sending. Delivery is handled by Messages."
                    )
                    : "iOS accepted your text for sending. Delivery and replies are handled by Messages."
                feedback = .success

            case .cancelled:
                title = "Nothing sent"
                detail = self.kind == .quote
                    ? "Your quote details and selected photos are still here whenever you're ready."
                    : "You can write a message again whenever you're ready."
                feedback = .info

            case .failed:
                title = "Couldn't send"
                detail = self.kind == .quote
                    ? "Your quote details and selected photos are still here. Check your connection, then tap Review & Send to retry."
                    : "Check your connection, then tap Text to try again."
                feedback = .error

            @unknown default:
                title = "Send status unavailable"
                detail = "Check Messages before trying again to avoid sending twice."
                feedback = .warning
            }

            self.presenter?.showFeedback(
                title: title,
                detail: detail,
                kind: feedback,
                duration: 5
            )
        }
    }

    private func showAttachmentsUnavailable(from presenter: UIViewController) {
        let alert = UIAlertController(
            title: "Photo Attachments Aren't Available",
            message:
                "This device can send the quote text, but iOS reports that message attachments are unavailable. You can send the text-only request or return to the quote.",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Keep Editing",
                style: .cancel
            )
        )

        alert.addAction(
            UIAlertAction(
                title: "Send Text Only",
                style: .default
            ) { [weak self, weak presenter] _ in
                guard let self, let presenter else { return }
                self.preparedImages = []
                self.acceptedAttachmentCount = 0
                DispatchQueue.main.async {
                    self.presentComposer(from: presenter)
                }
            }
        )

        presenter.present(alert, animated: true)
    }

    private func showUnavailable(from presenter: UIViewController) {
        let canEmailQuote =
            kind == .quote && MFMailComposeViewController.canSendMail()

        let message: String
        if kind == .quote, canEmailQuote {
            message =
                "This device isn't set up to send texts. Nothing has been sent. Email can carry the prepared request and available photos. The secure website form opens separately without the selected photos, and your app draft stays here."
        } else if kind == .quote {
            message =
                "This device isn't set up to send texts or in-app email. Nothing has been sent. The secure website form opens separately without the selected photos, and your app draft stays here. You can also copy the prepared request."
        } else {
            message =
                "This device isn't set up to send texts. Nothing has been sent. You can keep your details here or copy them to use later."
        }

        let alert = UIAlertController(
            title: "Texting isn't available",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Keep Editing",
                style: .cancel
            )
        )

        if canEmailQuote {
            alert.addAction(
                UIAlertAction(
                    title: "Email Quote",
                    style: .default
                ) { [weak self, weak presenter] _ in
                    guard let self, let presenter else { return }
                    DispatchQueue.main.async {
                        self.presentEmailComposer(from: presenter)
                    }
                }
            )
        }

        if kind == .quote {
            alert.addAction(
                UIAlertAction(
                    title: "Open Website Form",
                    style: .default
                ) { [weak presenter] _ in
                    guard
                        let url = URL(
                            string: "https://njbugninja.com/#quote"
                        )
                    else { return }

                    UIApplication.shared.open(url) { success in
                        guard !success else { return }
                        DispatchQueue.main.async {
                            presenter?.showFeedback(
                                title: "Website Didn't Open",
                                detail:
                                    "Your quote details are still here. Check your connection and try again.",
                                kind: .error,
                                duration: 3
                            )
                        }
                    }
                }
            )
        }

        let copyTitle =
            preparedBody.isEmpty
            ? "Copy Phone Number"
            : (kind == .quote ? "Copy Request" : "Copy Message")

        alert.addAction(
            UIAlertAction(
                title: copyTitle,
                style: .default
            ) { [weak self] _ in
                guard let self else { return }

                let value =
                    self.preparedBody.isEmpty
                    ? "609-313-6317"
                    : self.preparedBody

                UIPasteboard.general.string = value

                presenter.showFeedback(
                    title: "Copied",
                    detail:
                        self.kind == .quote
                        ? "The quote text is on your clipboard. Photos are not included, and nothing has been sent."
                        : "The message is on your clipboard. Nothing has been sent.",
                    kind: .info,
                    duration: 3
                )
            }
        )

        presenter.present(alert, animated: true)
    }

    private func presentEmailComposer(from presenter: UIViewController) {
        guard MFMailComposeViewController.canSendMail() else {
            presenter.showFeedback(
                title: "Email Isn't Available",
                detail:
                    "No email account is configured for in-app sending. Your quote details and photos are still here.",
                kind: .warning,
                duration: 4
            )
            return
        }

        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["service@njbugninja.com"])
        composer.setSubject("Mosquito Ninja Property Quote Request")
        composer.setMessageBody(preparedBody, isHTML: false)
        composer.modalPresentationStyle = .pageSheet
        composer.isModalInPresentation = true

        var preparedCount = 0
        for (index, image) in preparedImages.enumerated() {
            guard let data = preparedJPEG(from: image) else { continue }

            composer.addAttachmentData(
                data,
                mimeType: "image/jpeg",
                fileName: "property-photo-\(index + 1).jpg"
            )
            preparedCount += 1
        }

        guard preparedCount == preparedImages.count else {
            showAttachmentPreparationIssue(
                from: presenter,
                acceptedCount: preparedCount,
                expectedCount: preparedImages.count,
                retry: { [weak self, weak presenter] in
                    guard let self, let presenter else { return }
                    self.presentEmailComposer(from: presenter)
                },
                continueSending: { [weak self, weak presenter] in
                    guard let self, let presenter else { return }
                    self.presentMailComposer(
                        composer,
                        acceptedAttachmentCount: preparedCount,
                        from: presenter
                    )
                }
            )
            return
        }

        presentMailComposer(
            composer,
            acceptedAttachmentCount: preparedCount,
            from: presenter
        )
    }

    private func presentMailComposer(
        _ composer: MFMailComposeViewController,
        acceptedAttachmentCount: Int,
        from presenter: UIViewController
    ) {
        isPresenting = true
        isFinishing = false
        self.acceptedAttachmentCount = acceptedAttachmentCount
        activeMailComposer = composer
        presenter.present(composer, animated: true)
    }

    private func showAttachmentPreparationIssue(
        from presenter: UIViewController,
        acceptedCount: Int,
        expectedCount: Int,
        retry: @escaping () -> Void,
        continueSending: @escaping () -> Void
    ) {
        let missingCount = expectedCount - acceptedCount
        let alert = UIAlertController(
            title: "Some Photos Aren't Ready",
            message:
                "\(acceptedCount) of \(expectedCount) selected photo\(expectedCount == 1 ? "" : "s") could be attached. \(missingCount) photo\(missingCount == 1 ? "" : "s") could not be prepared. Nothing has been sent.",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Keep Editing",
                style: .cancel
            )
        )

        alert.addAction(
            UIAlertAction(
                title: "Retry Photos",
                style: .default
            ) { _ in
                DispatchQueue.main.async(execute: retry)
            }
        )

        let continueTitle =
            acceptedCount == 0
            ? "Continue Without Photos"
            : "Continue with \(acceptedCount) Photo\(acceptedCount == 1 ? "" : "s")"

        alert.addAction(
            UIAlertAction(
                title: continueTitle,
                style: .default
            ) { _ in
                DispatchQueue.main.async(execute: continueSending)
            }
        )

        presenter.present(alert, animated: true)
    }

    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        guard controller === activeMailComposer, !isFinishing else { return }
        isFinishing = true

        controller.dismiss(animated: true) { [weak self] in
            guard let self else { return }

            self.activeMailComposer = nil
            self.isPresenting = false
            self.isFinishing = false

            let title: String
            let detail: String
            let feedback: NinjaFeedbackKind

            switch result {
            case .sent:
                let sentPhotoCount = self.acceptedAttachmentCount
                self.preparedBody = ""
                self.preparedImages = []
                self.acceptedAttachmentCount = 0

                title = "Request sent"
                detail =
                    sentPhotoCount > 0
                    ? "Mail accepted your quote request and \(sentPhotoCount) photo attachment\(sentPhotoCount == 1 ? "" : "s") for sending to service@njbugninja.com."
                    : "Mail accepted your quote request for sending to service@njbugninja.com."
                feedback = .success

            case .saved:
                title = "Email draft saved"
                detail =
                    "Nothing has been sent yet. Your quote remains here, and Mail saved a draft you can finish later."
                feedback = .info

            case .cancelled:
                title = "Nothing sent"
                detail =
                    "Your quote details and selected photos are still here whenever you're ready."
                feedback = .info

            case .failed:
                let errorDetail =
                    error.map { $0.localizedDescription + " " } ?? ""
                title = "Couldn't send"
                detail =
                    errorDetail +
                    "Your quote details and selected photos are still here. Check your mail account and connection, then try again."
                feedback = .error

            @unknown default:
                title = "Send status unavailable"
                detail =
                    "Check Mail before trying again to avoid sending twice."
                feedback = .warning
            }

            self.presenter?.showFeedback(
                title: title,
                detail: detail,
                kind: feedback,
                duration: 5
            )
        }
    }

    private func preparedJPEG(from image: UIImage) -> Data? {
        let maxDimension: CGFloat = 1600
        let sourceSize = image.size

        guard sourceSize.width > 0, sourceSize.height > 0 else {
            return image.jpegData(compressionQuality: 0.80)
        }

        let scale = min(
            1,
            maxDimension / max(sourceSize.width, sourceSize.height)
        )

        let targetSize = CGSize(
            width: max(1, floor(sourceSize.width * scale)),
            height: max(1, floor(sourceSize.height * scale))
        )

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        let rendered = renderer.image { _ in
            image.draw(
                in: CGRect(
                    origin: .zero,
                    size: targetSize
                )
            )
        }

        return rendered.jpegData(compressionQuality: 0.78)
    }
}
