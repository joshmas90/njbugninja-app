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
    private var preparedImages: [UIImage] = []

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
        isPresenting = true
        isFinishing = false

        let composer = MFMessageComposeViewController()
        composer.messageComposeDelegate = self
        composer.recipients = ["+16093136317"]
        composer.body = preparedBody
        composer.modalPresentationStyle = .pageSheet
        composer.isModalInPresentation = true

        for (index, image) in preparedImages.enumerated() {
            guard let data = preparedJPEG(from: image) else { continue }

            composer.addAttachmentData(
                data,
                typeIdentifier: "public.jpeg",
                filename: "property-photo-\(index + 1).jpg"
            )
        }

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
                let hadPhotos = !self.preparedImages.isEmpty
                self.preparedBody = ""
                self.preparedImages = []

                title = self.kind == .quote ? "Request sent" : "Message sent"
                detail = self.kind == .quote
                    ? (
                        hadPhotos
                        ? "iOS accepted your quote request and photo attachments for sending. Delivery is handled by Messages."
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
                self.presentComposer(from: presenter)
            }
        )

        presenter.present(alert, animated: true)
    }

    private func showUnavailable(from presenter: UIViewController) {
        let alert = UIAlertController(
            title: "Texting isn't available",
            message:
                "This device isn't set up to send texts. Nothing has been sent. You can keep your details here or copy them to use later.",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Keep Editing",
                style: .cancel
            )
        )

        let copyTitle =
            preparedBody.isEmpty
            ? "Copy Phone Number"
            : "Copy Message"

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
            }
        )

        presenter.present(alert, animated: true)
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
