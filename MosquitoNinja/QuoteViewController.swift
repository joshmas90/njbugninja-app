import UIKit
import PhotosUI

final class QuoteViewController:
    NinjaBaseViewController,
    UITextFieldDelegate,
    UITextViewDelegate,
    PHPickerViewControllerDelegate
{
    private let serviceChoices: [
        (title: String, detail: String, symbol: String)
    ] = [
        (
            "Mosquito Control",
            "Mosquito resting, harborage and activity areas.",
            "drop.fill"
        ),
        (
            "Tick Control",
            "Wooded edges, brush, leaf litter and transition zones.",
            "scope"
        ),
        (
            "Outdoor Fly Control",
            "House-fly and nuisance-fly source, resting and activity areas.",
            "ant.fill"
        )
    ]

    private let servicePanel = UIView()
    private let serviceStack = UIStackView()
    private var serviceButtons: [UIButton] = []
    private var selectedServiceIndices: Set<Int> = []

    private let propertyType =
        UISegmentedControl(
            items: [
                "Residential",
                "Commercial",
                "Government"
            ]
        )

    private let nameField = UITextField()
    private let phoneField = UITextField()
    private let locationField = UITextField()
    private let notesView = UITextView()

    private let photoPanel = UIView()
    private let photoPreviewStack = UIStackView()
    private let photoCountLabel = UILabel()
    private let clearPhotosButton = NinjaButton(type: .system)
    private let quoteMessageComposer = MessageComposer()
    private lazy var choosePhotosButton =
        secondaryButton(
            "Choose Property Photos",
            symbol: "photo.on.rectangle.angled",
            action: #selector(choosePhotos)
        )
    private lazy var reviewButton =
        primaryButton(
            "Review & Send",
            symbol: "checkmark.bubble.fill",
            action: #selector(reviewQuote)
        )

    private var selectedPhotos: [UIImage] = []
    private var photoSelectionGeneration = 0
    private var pendingPhotoCount = 0
    private var isLoadingPhotos = false

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Quote"
        buildUI()
        updatePhotoUI()
    }

    func selectService(_ selection: NinjaService) {
        loadViewIfNeeded()

        switch selection {
        case .mosquito:
            setSelectedServices([0])
        case .tick:
            setSelectedServices([1])
        case .fly:
            setSelectedServices([2])
        case .commercial:
            propertyType.selectedSegmentIndex = 1
        }
    }

    func prepareForSpring2027Request() {
        loadViewIfNeeded()

        let springNote = "I’m interested in early Spring 2027 scheduling."
        let currentNotes = notesView.text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if currentNotes.isEmpty || currentNotes.hasPrefix("Describe the property") {
            notesView.text = springNote + " "
            notesView.textColor = .white
        } else if !currentNotes.localizedCaseInsensitiveContains("spring 2027") {
            notesView.text = springNote + "\n" + currentNotes
            notesView.textColor = .white
        }

        showFeedback(
            title: "Spring 2027 Request",
            detail: "The scheduling preference is included. Add your property details, then review and send the request.",
            kind: .success,
            duration: 2.0
        )
    }

    private func style(
        _ field: UITextField,
        placeholder: String,
        contentType: UITextContentType? = nil
    ) {
        field.placeholder = placeholder
        field.textContentType = contentType
        field.backgroundColor = NinjaPalette.panel
        field.textColor = .white
        field.font = .preferredFont(forTextStyle: .body)
        field.adjustsFontForContentSizeCategory = true
        field.tintColor = NinjaPalette.red
        field.layer.cornerRadius = 12
        field.layer.cornerCurve = .continuous
        field.layer.borderWidth = 0.75
        field.layer.borderColor =
            UIColor.white.withAlphaComponent(0.12).cgColor
        field.setLeftPadding(14)
        field.heightAnchor.constraint(
            greaterThanOrEqualToConstant: 52
        ).isActive = true
        field.delegate = self

        field.attributedPlaceholder =
            NSAttributedString(
                string: placeholder,
                attributes: [
                    .foregroundColor:
                        UIColor.white.withAlphaComponent(0.64)
                ]
            )
    }

    private func labeledField(
        _ field: UITextField,
        title: String
    ) -> UIView {
        let label = UILabel()
        label.text = title
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.font =
            UIFontMetrics(forTextStyle: .subheadline)
                .scaledFont(
                    for:
                        .systemFont(
                            ofSize: 14,
                            weight: .semibold
                        )
                )
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.isAccessibilityElement = false

        field.accessibilityLabel = title

        let stack = UIStackView(arrangedSubviews: [label, field])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    private func buildUI() {
        contentStack.addArrangedSubview(
            eyebrow("Property quote")
        )

        contentStack.addArrangedSubview(
            headline(
                "Tell us what you’re dealing with.",
                size: 34
            )
        )

        contentStack.addArrangedSubview(
            body(
                "Select every service you’re interested in. You can choose one service or combine mosquito, tick and outdoor fly control in the same request."
            )
        )

        contentStack.addArrangedSubview(
            sectionTitle("Services")
        )

        configureServiceOptions()
        contentStack.addArrangedSubview(servicePanel)

        contentStack.addArrangedSubview(
            sectionTitle("Property type")
        )

        propertyType.selectedSegmentIndex = 0
        propertyType.accessibilityLabel = "Property type"
        propertyType.selectedSegmentTintColor = NinjaPalette.green
        propertyType.setTitleTextAttributes(
            [.foregroundColor: NinjaPalette.ink],
            for: .selected
        )
        propertyType.setTitleTextAttributes(
            [
                .foregroundColor:
                    UIColor.white.withAlphaComponent(0.72)
            ],
            for: .normal
        )
        propertyType.addTarget(
            self,
            action: #selector(propertyTypeSelectionChanged),
            for: .valueChanged
        )

        contentStack.addArrangedSubview(propertyType)

        contentStack.addArrangedSubview(
            sectionTitle("Contact")
        )

        style(
            nameField,
            placeholder: "Your name",
            contentType: .name
        )
        style(
            phoneField,
            placeholder: "Best number to reach you",
            contentType: .telephoneNumber
        )
        style(
            locationField,
            placeholder: "Town or ZIP code",
            contentType: .postalCode
        )

        phoneField.keyboardType = .phonePad
        nameField.returnKeyType = .next
        locationField.returnKeyType = .done

        [
            labeledField(nameField, title: "Name"),
            labeledField(phoneField, title: "Phone"),
            labeledField(
                locationField,
                title: "Town or ZIP code"
            )
        ].forEach(contentStack.addArrangedSubview)

        contentStack.addArrangedSubview(
            sectionTitle("Property details")
        )

        notesView.backgroundColor = NinjaPalette.panel
        notesView.textColor = .white
        notesView.tintColor = NinjaPalette.red
        notesView.font = .preferredFont(forTextStyle: .body)
        notesView.adjustsFontForContentSizeCategory = true
        notesView.accessibilityLabel = "Property details"
        notesView.layer.cornerRadius = 12
        notesView.layer.cornerCurve = .continuous
        notesView.layer.borderWidth = 0.75
        notesView.layer.borderColor =
            UIColor.white.withAlphaComponent(0.12).cgColor
        notesView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: 130
        ).isActive = true
        notesView.text =
            "Describe the property, where you notice activity, and any scheduling details."
        notesView.textColor =
            UIColor.white.withAlphaComponent(0.64)
        notesView.delegate = self

        contentStack.addArrangedSubview(notesView)

        contentStack.addArrangedSubview(
            sectionTitle("Property photos")
        )

        contentStack.addArrangedSubview(
            body(
                "Optional: attach up to three photos of the yard, vegetation, standing water, wooded edges, trash or recycling areas, or the area where activity is worst."
            )
        )

        configurePhotoPanel()
        contentStack.addArrangedSubview(photoPanel)

        contentStack.addArrangedSubview(choosePhotosButton)
        contentStack.addArrangedSubview(reviewButton)

        contentStack.addArrangedSubview(
            card(
                title: "You stay in control",
                detail:
                    "Review the prepared request in Apple's Messages sheet, or use the in-app email option when texting is unavailable. Nothing is sent automatically.",
                symbol: "hand.tap.fill",
                accent: NinjaPalette.green
            )
        )
    }

    private func configurePhotoPanel() {
        photoPanel.backgroundColor = NinjaPalette.panel
        photoPanel.layer.cornerRadius = 16
        photoPanel.layer.cornerCurve = .continuous
        photoPanel.layer.borderWidth = 0.75
        photoPanel.layer.borderColor =
            UIColor.white.withAlphaComponent(0.10).cgColor

        photoCountLabel.textColor = NinjaPalette.muted
        photoCountLabel.font =
            .preferredFont(forTextStyle: .subheadline)
        photoCountLabel.adjustsFontForContentSizeCategory = true
        photoCountLabel.numberOfLines = 0

        var clearConfig = UIButton.Configuration.plain()
        clearConfig.title = "CLEAR"
        clearConfig.baseForegroundColor = NinjaPalette.red
        clearConfig.image = UIImage(systemName: "xmark.circle.fill")
        clearConfig.imagePadding = 6
        clearConfig.contentInsets =
            NSDirectionalEdgeInsets(
                top: 8,
                leading: 8,
                bottom: 8,
                trailing: 8
            )

        clearPhotosButton.configuration = clearConfig
        clearPhotosButton.hapticStyle = .light
        clearPhotosButton.addTarget(
            self,
            action: #selector(clearPhotos),
            for: .touchUpInside
        )

        let header = UIStackView(
            arrangedSubviews: [
                photoCountLabel,
                clearPhotosButton
            ]
        )
        header.axis = .horizontal
        header.alignment = .center
        header.distribution = .fill
        header.spacing = 8

        photoPreviewStack.axis = .horizontal
        photoPreviewStack.alignment = .center
        photoPreviewStack.spacing = 10

        let previewScroll = UIScrollView()
        previewScroll.translatesAutoresizingMaskIntoConstraints = false
        previewScroll.showsHorizontalScrollIndicator = false
        previewScroll.addSubview(photoPreviewStack)
        photoPreviewStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            photoPreviewStack.topAnchor.constraint(
                equalTo: previewScroll.contentLayoutGuide.topAnchor
            ),
            photoPreviewStack.leadingAnchor.constraint(
                equalTo: previewScroll.contentLayoutGuide.leadingAnchor
            ),
            photoPreviewStack.trailingAnchor.constraint(
                equalTo: previewScroll.contentLayoutGuide.trailingAnchor
            ),
            photoPreviewStack.bottomAnchor.constraint(
                equalTo: previewScroll.contentLayoutGuide.bottomAnchor
            ),
            photoPreviewStack.heightAnchor.constraint(
                equalTo: previewScroll.frameLayoutGuide.heightAnchor
            ),
            previewScroll.heightAnchor.constraint(
                equalToConstant: 78
            )
        ])

        let stack = UIStackView(
            arrangedSubviews: [
                header,
                previewScroll
            ]
        )
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12

        photoPanel.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(
                equalTo: photoPanel.topAnchor,
                constant: 15
            ),
            stack.leadingAnchor.constraint(
                equalTo: photoPanel.leadingAnchor,
                constant: 15
            ),
            stack.trailingAnchor.constraint(
                equalTo: photoPanel.trailingAnchor,
                constant: -15
            ),
            stack.bottomAnchor.constraint(
                equalTo: photoPanel.bottomAnchor,
                constant: -15
            )
        ])
    }

    private func updatePhotoUI() {
        photoPreviewStack.arrangedSubviews.forEach {
            photoPreviewStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        if isLoadingPhotos {
            photoCountLabel.text =
                "Loading \(pendingPhotoCount) photo\(pendingPhotoCount == 1 ? "" : "s")..."
            clearPhotosButton.isHidden = false

            let loading = UIActivityIndicatorView(style: .medium)
            loading.color = NinjaPalette.green
            loading.startAnimating()
            loading.accessibilityLabel = "Loading selected property photos"
            photoPreviewStack.addArrangedSubview(loading)

            let detail = UILabel()
            detail.text =
                "Review & Send will be available when the active selection finishes loading."
            detail.textColor = UIColor.white.withAlphaComponent(0.62)
            detail.font = .preferredFont(forTextStyle: .footnote)
            detail.adjustsFontForContentSizeCategory = true
            detail.numberOfLines = 0
            photoPreviewStack.addArrangedSubview(detail)
        } else {
            switch selectedPhotos.count {
            case 0:
                photoCountLabel.text = "No photos selected"
                clearPhotosButton.isHidden = true

                let placeholder = UILabel()
                placeholder.text =
                    "Photos are optional. Choose images only if they help show the property or pest activity."
                placeholder.textColor =
                    UIColor.white.withAlphaComponent(0.52)
                placeholder.font =
                    .preferredFont(forTextStyle: .footnote)
                placeholder.adjustsFontForContentSizeCategory = true
                placeholder.numberOfLines = 0
                placeholder.widthAnchor.constraint(
                    lessThanOrEqualToConstant: 330
                ).isActive = true
                photoPreviewStack.addArrangedSubview(placeholder)

            default:
                photoCountLabel.text =
                    "\(selectedPhotos.count) of 3 photos selected"
                clearPhotosButton.isHidden = false

                for (index, image) in selectedPhotos.enumerated() {
                    let preview = UIImageView(image: image)
                    preview.contentMode = .scaleAspectFill
                    preview.clipsToBounds = true
                    preview.layer.cornerRadius = 12
                    preview.layer.cornerCurve = .continuous
                    preview.layer.borderWidth = 1
                    preview.layer.borderColor =
                        UIColor.white.withAlphaComponent(0.12).cgColor
                    preview.translatesAutoresizingMaskIntoConstraints = false
                    preview.widthAnchor.constraint(
                        equalToConstant: 78
                    ).isActive = true
                    preview.heightAnchor.constraint(
                        equalToConstant: 78
                    ).isActive = true
                    preview.isAccessibilityElement = true
                    preview.accessibilityLabel =
                        "Selected property photo \(index + 1)"
                    photoPreviewStack.addArrangedSubview(preview)
                }
            }
        }

        choosePhotosButton.isEnabled = !isLoadingPhotos
        reviewButton.isEnabled = !isLoadingPhotos
        photoPanel.accessibilityValue =
            isLoadingPhotos
            ? "Loading selected photos"
            : photoCountLabel.text
    }

    private func configureServiceOptions() {
        servicePanel.backgroundColor = .clear
        servicePanel.layer.cornerRadius = 16
        servicePanel.layer.cornerCurve = .continuous
        servicePanel.layer.borderWidth = 0

        serviceStack.translatesAutoresizingMaskIntoConstraints = false
        serviceStack.axis = .vertical
        serviceStack.spacing = 10

        servicePanel.addSubview(serviceStack)

        NSLayoutConstraint.activate([
            serviceStack.topAnchor.constraint(equalTo: servicePanel.topAnchor),
            serviceStack.leadingAnchor.constraint(equalTo: servicePanel.leadingAnchor),
            serviceStack.trailingAnchor.constraint(equalTo: servicePanel.trailingAnchor),
            serviceStack.bottomAnchor.constraint(equalTo: servicePanel.bottomAnchor)
        ])

        serviceButtons = serviceChoices.enumerated().map {
            index,
            choice in

            let button = UIButton(type: .system)
            button.tag = index
            button.contentHorizontalAlignment = .leading
            button.layer.cornerRadius = 14
            button.layer.cornerCurve = .continuous
            button.layer.borderWidth = 1
            button.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 66
            ).isActive = true

            var configuration = UIButton.Configuration.plain()
            configuration.title = choice.title
            configuration.subtitle = choice.detail
            configuration.image = UIImage(systemName: choice.symbol)
            configuration.imagePlacement = .leading
            configuration.imagePadding = 13
            configuration.titleAlignment = .leading
            configuration.contentInsets =
                NSDirectionalEdgeInsets(
                    top: 12,
                    leading: 15,
                    bottom: 12,
                    trailing: 15
                )
            configuration.baseForegroundColor = .white
            configuration.background.backgroundColor =
                NinjaPalette.panel

            button.configuration = configuration
            button.accessibilityLabel = choice.title
            button.accessibilityHint =
                "Double tap to add or remove this service from the quote request."

            button.addTarget(
                self,
                action: #selector(serviceOptionTapped(_:)),
                for: .touchUpInside
            )

            serviceStack.addArrangedSubview(button)
            return button
        }

        updateServiceButtons()
    }

    private func setSelectedServices(_ indices: Set<Int>) {
        selectedServiceIndices =
            Set(indices.filter { serviceChoices.indices.contains($0) })
        updateServiceButtons()
    }

    private func updateServiceButtons() {
        for button in serviceButtons {
            let selected =
                selectedServiceIndices.contains(button.tag)

            var configuration =
                button.configuration ?? UIButton.Configuration.plain()

            configuration.image =
                UIImage(
                    systemName:
                        selected
                        ? "checkmark.square.fill"
                        : "square"
                )

            configuration.baseForegroundColor =
                selected
                ? .white
                : UIColor.white.withAlphaComponent(0.84)

            configuration.background.backgroundColor =
                selected
                ? NinjaPalette.red.withAlphaComponent(0.16)
                : NinjaPalette.panel

            button.configuration = configuration

            button.layer.borderColor =
                (
                    selected
                    ? NinjaPalette.red.withAlphaComponent(0.72)
                    : UIColor.white.withAlphaComponent(0.11)
                ).cgColor

            button.accessibilityValue =
                selected ? "Selected" : "Not selected"

            button.accessibilityTraits =
                selected
                ? [.button, .selected]
                : .button
        }
    }

    @objc private func serviceOptionTapped(_ sender: UIButton) {
        if selectedServiceIndices.contains(sender.tag) {
            selectedServiceIndices.remove(sender.tag)
        } else {
            selectedServiceIndices.insert(sender.tag)
        }

        servicePanel.layer.borderWidth = 0
        updateServiceButtons()
        NinjaHaptics.selection()
    }

    @objc private func propertyTypeSelectionChanged() {
        NinjaHaptics.selection()
    }

    private func resetValidation() {
        servicePanel.layer.borderWidth = 0

        [
            nameField,
            phoneField,
            locationField
        ].forEach { field in
            field.layer.borderColor =
                UIColor.white.withAlphaComponent(0.12).cgColor
            field.layer.borderWidth = 0.75
        }
    }

    private func markInvalid(_ field: UITextField) {
        field.layer.borderColor =
            NinjaPalette.red.withAlphaComponent(0.88).cgColor
        field.layer.borderWidth = 1.25
    }

    @objc private func choosePhotos() {
        var configuration =
            PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 3
        configuration.preferredAssetRepresentationMode = .current

        let picker =
            PHPickerViewController(configuration: configuration)
        picker.delegate = self

        present(picker, animated: true)
    }

    @objc private func clearPhotos() {
        guard isLoadingPhotos || !selectedPhotos.isEmpty else { return }

        photoSelectionGeneration &+= 1
        isLoadingPhotos = false
        pendingPhotoCount = 0
        selectedPhotos.removeAll()
        updatePhotoUI()

        showFeedback(
            title: "Photos Cleared",
            detail:
                "The quote request will be sent without photos unless you choose new ones.",
            kind: .info,
            duration: 1.2
        )
    }

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        picker.dismiss(animated: true)

        guard !results.isEmpty else { return }

        let limitedResults = Array(results.prefix(3))
        photoSelectionGeneration &+= 1
        let selectionGeneration = photoSelectionGeneration
        isLoadingPhotos = true
        pendingPhotoCount = limitedResults.count
        selectedPhotos.removeAll()
        updatePhotoUI()

        let group = DispatchGroup()
        let lock = NSLock()

        var ordered:
            [(index: Int, image: UIImage)] = []

        for (index, result) in limitedResults.enumerated() {
            guard
                result.itemProvider.canLoadObject(
                    ofClass: UIImage.self
                )
            else { continue }

            group.enter()

            result.itemProvider.loadObject(
                ofClass: UIImage.self
            ) { object, _ in
                defer { group.leave() }

                guard let image = object as? UIImage else {
                    return
                }

                lock.lock()
                ordered.append((index, image))
                lock.unlock()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            guard selectionGeneration == self.photoSelectionGeneration else {
                return
            }

            self.selectedPhotos =
                ordered
                    .sorted { $0.index < $1.index }
                    .map(\.image)

            self.isLoadingPhotos = false
            self.pendingPhotoCount = 0
            self.updatePhotoUI()

            let failedCount =
                limitedResults.count - self.selectedPhotos.count

            if self.selectedPhotos.isEmpty {
                self.showFeedback(
                    title: "Photos Couldn't Load",
                    detail:
                        "None of the selected photos loaded. Try choosing them again, or continue without photos.",
                    kind: .warning,
                    duration: 3
                )
            } else if failedCount > 0 {
                self.showFeedback(
                    title: "Some Photos Couldn't Load",
                    detail:
                        "\(self.selectedPhotos.count) of \(limitedResults.count) photos are ready. Choose the photos again to retry, or continue with the loaded selection.",
                    kind: .warning,
                    duration: 4
                )
            } else {
                self.showFeedback(
                    title: "Photos Ready",
                    detail:
                        "\(self.selectedPhotos.count) photo\(self.selectedPhotos.count == 1 ? "" : "s") will be included with the quote request.",
                    kind: .success,
                    duration: 1.5
                )
            }
        }
    }

    @objc private func reviewQuote() {
        view.endEditing(true)

        guard !isLoadingPhotos else {
            showFeedback(
                title: "Photos Are Still Loading",
                detail:
                    "Wait for the active photo selection to finish, or tap Clear to continue without photos.",
                kind: .info,
                duration: 3
            )
            return
        }

        resetValidation()

        let name =
            nameField.text?
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                ) ?? ""

        let phone =
            phoneField.text?
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                ) ?? ""

        let location =
            locationField.text?
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                ) ?? ""

        var issues: [String] = []
        var firstInvalid: UITextField?

        if selectedServiceIndices.isEmpty {
            issues.append("at least one service")
            servicePanel.layer.borderWidth = 1.25
            servicePanel.layer.borderColor =
                NinjaPalette.red.withAlphaComponent(0.88).cgColor
        }

        if name.isEmpty {
            issues.append("your name")
            markInvalid(nameField)
            firstInvalid = nameField
        }

        let normalizedPhone = normalizedUSPhoneDigits(phone)
        let validPhone = normalizedPhone.map {
            $0.count == 10 ||
                ($0.count == 11 && $0.hasPrefix("1"))
        } ?? false

        if phone.isEmpty {
            issues.append("your phone number")
            markInvalid(phoneField)

            if firstInvalid == nil {
                firstInvalid = phoneField
            }
        } else if !validPhone {
            issues.append("a valid 10-digit U.S. phone number")
            markInvalid(phoneField)

            if firstInvalid == nil {
                firstInvalid = phoneField
            }
        }

        if location.isEmpty {
            issues.append("your town or ZIP code")
            markInvalid(locationField)

            if firstInvalid == nil {
                firstInvalid = locationField
            }
        }

        guard issues.isEmpty else {
            let missing = issues.joined(separator: ", ")

            showFeedback(
                title: "More Information Needed",
                detail:
                    "Please add \(missing) before reviewing your quote request.",
                kind: .warning,
                duration: 2.1
            )

            firstInvalid?.becomeFirstResponder()
            return
        }

        guard let normalizedPhone else { return }
        let formattedPhone = formattedUSPhone(normalizedPhone)
        phoneField.text = formattedPhone

        let selectedServices =
            selectedServiceIndices
                .sorted()
                .map { serviceChoices[$0].title }

        let property: String
        switch propertyType.selectedSegmentIndex {
        case 1:
            property = "Commercial / Business"
        case 2:
            property = "Government / Municipal"
        default:
            property = "Residential"
        }

        let notes =
            notesView.text.hasPrefix("Describe the property")
            ? ""
            : (
                notesView.text?
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                ?? ""
            )

        let message = """
        Hi Mosquito Ninja, I'd like a property quote.

        Name: \(name)
        Phone: \(formattedPhone)
        Town/ZIP: \(location)
        Services: \(selectedServices.joined(separator: ", "))
        Property type: \(property)
        Property details: \(notes)
        """

        quoteMessageComposer.present(
            from: self,
            body: message,
            kind: .quote,
            images: selectedPhotos
        )
    }

    private func normalizedUSPhoneDigits(
        _ value: String
    ) -> String? {
        let allowedFormatting =
            CharacterSet.whitespacesAndNewlines.union(
                CharacterSet(charactersIn: "+-()./")
            )

        var digits = ""

        for character in value {
            if
                let digit = character.wholeNumberValue,
                (0...9).contains(digit)
            {
                digits.append(String(digit))
                continue
            }

            let scalars = String(character).unicodeScalars
            guard scalars.allSatisfy({
                allowedFormatting.contains($0)
            }) else {
                return nil
            }
        }

        return digits
    }

    private func formattedUSPhone(_ digits: String) -> String {
        let national =
            digits.count == 11
            ? String(digits.dropFirst())
            : digits

        let areaEnd = national.index(
            national.startIndex,
            offsetBy: 3
        )
        let exchangeEnd = national.index(
            areaEnd,
            offsetBy: 3
        )

        return
            "(" + String(national[..<areaEnd]) + ") " +
            String(national[areaEnd..<exchangeEnd]) + "-" +
            String(national[exchangeEnd...])
    }

    func textFieldDidBeginEditing(
        _ textField: UITextField
    ) {
        textField.layer.borderColor =
            UIColor.white.withAlphaComponent(0.12).cgColor
        textField.layer.borderWidth = 0.75
    }

    func textFieldShouldReturn(
        _ textField: UITextField
    ) -> Bool {
        if textField === nameField {
            phoneField.becomeFirstResponder()
        } else if textField === locationField {
            textField.resignFirstResponder()
        }

        return true
    }

    func textViewDidBeginEditing(
        _ textView: UITextView
    ) {
        if textView.text.hasPrefix("Describe the property") {
            textView.text = ""
            textView.textColor = .white
        }
    }
}

private extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let padding =
            UIView(
                frame:
                    CGRect(
                        x: 0,
                        y: 0,
                        width: amount,
                        height: 1
                    )
            )

        leftView = padding
        leftViewMode = .always
    }
}
