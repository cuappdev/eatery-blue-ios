//
//  BarcodeViewController.swift
//  Eatery Blue
//
//  Created by Arielle Nudelman on 9/19/26.
//

import EateryGetAPI
import EateryModel
import SnapKit
import UIKit

/// Partial-screen GET payment barcode. Refreshes about every 5 seconds.
@MainActor
class BarcodeViewController: SheetViewController {
    // MARK: - Views

    private let closeButton = ButtonView(pillContent: UIImageView())
    private let titleLabel = UILabel()
    private let profileCardView = ContainerView(content: UIView())
    private let profileBlueView = UIView()
    private let avatarContainer = ContainerView(pillContent: UIImageView())
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let spinner = UIActivityIndicatorView(style: .large)
    private let barcodeImageView = UIImageView()
    private let messageLabel = UILabel()

    // MARK: - State

    private var refreshTimer: Timer?
    private var seed: String?
    private var patronId: String?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpCloseButton()
        setUpTitleLabel()
        setUpProfileCard()
        setUpBarcodeDisplay()
        setUpConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        RootViewController.setStatusBarStyle(.darkContent)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    // MARK: - View setup

    private func setUpView() {
        view.backgroundColor = .white
    }

    private func setUpTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textColor = UIColor.Eatery.primaryText
        titleLabel.text = "Dining Barcode"

        view.addSubview(titleLabel)
    }

    private func setUpCloseButton() {
        let closeConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        closeButton.content.image = UIImage(systemName: "xmark", withConfiguration: closeConfig)
        closeButton.content.tintColor = UIColor.Eatery.primaryText
        closeButton.content.contentMode = .scaleAspectFit
        closeButton.shadowColor = UIColor.Eatery.shadowLight
        closeButton.shadowOffset = .zero
        closeButton.shadowRadius = 12
        closeButton.shadowOpacity = 0.25
        closeButton.backgroundColor = UIColor.Eatery.card
        closeButton.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        closeButton.buttonPress { [weak self] _ in
            self?.dismiss(animated: true)
        }

        view.addSubview(closeButton)
    }

    private func setUpProfileCard() {
        profileCardView.cornerRadius = 8
        profileCardView.shadowColor = UIColor.Eatery.shadowLight
        profileCardView.shadowOffset = CGSize(width: 0, height: 2)
        profileCardView.shadowRadius = 4
        profileCardView.shadowOpacity = 0.15
        profileCardView.content.backgroundColor = UIColor.Eatery.default00
        view.addSubview(profileCardView)

        profileBlueView.backgroundColor = UIColor.Eatery.blue
        profileCardView.content.addSubview(profileBlueView)

        avatarContainer.backgroundColor = UIColor.Eatery.default00.withAlphaComponent(0.25)
        avatarContainer.layoutMargins = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9)
        avatarContainer.content.image = UIImage(systemName: "person.fill")
        avatarContainer.content.tintColor = UIColor.Eatery.default00
        avatarContainer.content.contentMode = .scaleAspectFit
        profileBlueView.addSubview(avatarContainer)

        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        nameLabel.textColor = UIColor.Eatery.gray00
        nameLabel.text = "Cornell Student"
        profileBlueView.addSubview(nameLabel)

        emailLabel.font = .systemFont(ofSize: 14, weight: .medium)
        emailLabel.textColor = UIColor.Eatery.gray01
        emailLabel.text = "netid@cornell.edu"
        profileBlueView.addSubview(emailLabel)
    }

    private func setUpBarcodeDisplay() {
        spinner.hidesWhenStopped = true
        profileCardView.content.addSubview(spinner)

        barcodeImageView.contentMode = .scaleAspectFit
        barcodeImageView.isHidden = true
        profileCardView.content.addSubview(barcodeImageView)

        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.textColor = UIColor.Eatery.secondaryText
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.isHidden = true
        profileCardView.content.addSubview(messageLabel)
    }

    private func setUpConstraints() {
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(44)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalTo(closeButton)
            make.trailing.lessThanOrEqualTo(closeButton.snp.leading).offset(-8)
        }

        profileCardView.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(26)
            make.bottom.equalToSuperview().inset(61) // determines modal height
        }

        profileBlueView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(68)
        }

        avatarContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(45)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarContainer.snp.trailing).offset(12)
            make.centerY.equalTo(avatarContainer).offset(-9)
            make.trailing.lessThanOrEqualToSuperview().inset(12)
        }

        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.leading.equalTo(nameLabel)
            make.trailing.lessThanOrEqualToSuperview().inset(12)
        }

        barcodeImageView.snp.makeConstraints { make in
            make.top.equalTo(profileBlueView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(87)
            make.bottom.equalToSuperview().inset(7)
        }

        spinner.snp.makeConstraints { make in
            make.center.equalTo(barcodeImageView)
        }

        messageLabel.snp.makeConstraints { make in
            make.center.equalTo(barcodeImageView)
            make.leading.trailing.equalTo(barcodeImageView)
        }
    }

    // MARK: - Profile data

    func loadInitialContent() async {
        async let profileTask: Void = updateProfileFromNetworking()
        await loadSecrets()
        await profileTask
    }

    private func updateProfileFromNetworking() async {
        do {
            let profile = try await Networking.default.getProfile()
            updateProfileLabels(name: profile.fullName, email: profile.email, image: profile.decodedImage)
        } catch {
            logger.error("\(#function): \(error)")
        }
    }

    private func updateProfileLabels(name: String?, email: String?, image: UIImage?) {
        nameLabel.text = name ?? "Cornell Student"
        emailLabel.text = email ?? "netid@cornell.edu"

        if let image {
            avatarContainer.backgroundColor = .clear
            avatarContainer.layoutMargins = .zero
            avatarContainer.content.contentMode = .scaleAspectFill
            avatarContainer.content.image = image
        } else {
            avatarContainer.backgroundColor = UIColor.Eatery.default00.withAlphaComponent(0.25)
            avatarContainer.layoutMargins = UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9)
            avatarContainer.content.contentMode = .scaleAspectFit
            avatarContainer.content.image = UIImage(systemName: "person.fill")
        }
    }

    // MARK: - Barcode data

    private func loadSecrets() async {
        showLoading()

        patronId = KeychainAccess.shared.retrievePatronId()
        seed = KeychainAccess.shared.retrieveBarcodeSeed()

        if seed == nil {
            let didLoadSeed = await fetchSeed()
            if !didLoadSeed {
                return
            }
        }

        if patronId == nil {
            await fetchPatronId()
        }

        guard seed != nil, patronId != nil else {
            if patronId == nil {
                showMessage("No payment ID yet. Use GET once, then try again.")
            } else {
                showMessage(
                    "Couldn't load your barcode. Check your connection and try again."
                )
            }
            return
        }

        refreshBarcode()
    }

    /// Returns false when we already showed an error and should stop.
    private func fetchSeed() async -> Bool {
        let sessionId = Networking.default.sessionId
        guard !sessionId.isEmpty else {
            showMessage("Log in to GET to show a barcode.")
            return false
        }

        do {
            let config = try await GetAPI().barcodeConfig(sessionId: sessionId)
            guard config.canGenerateOfflineBarcode,
                  let barcodeSeed = config.barcodeSeed
            else {
                showMessage("Barcode isn't available for this account.")
                return false
            }
            KeychainAccess.shared.saveBarcodeSeed(barcodeSeed)
            seed = barcodeSeed
            return true
        } catch {
            logger.error("\(#function): failed to fetch barcode seed")
            showMessage(
                "Couldn't load your barcode. Check your connection and try again."
            )
            return false
        }
    }

    private func fetchPatronId() async {
        do {
            let end = Day()
            let start = end.advanced(by: -30)
            let data = try await Networking.default.accounts.fetch(
                start: start,
                end: end
            )
            if let id = data.patronId {
                KeychainAccess.shared.savePatronId(id)
                patronId = id
            }
        } catch {
            logger.error("\(#function): failed to fetch patron id")
        }
    }

    private func startTimer() {
        refreshTimer?.invalidate()
        guard seed != nil, patronId != nil else {
            return
        }

        refreshTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshBarcode()
            }
        }
    }

    private func refreshBarcode() {
        guard let seed, let patronId else {
            return
        }

        let timestamp = Int(Date().timeIntervalSince1970)
        do {
            let digits = try BarcodeGenerator.generateBarcode(
                seedHex: seed,
                cashlessKey: patronId,
                timestamp: timestamp
            )
            guard let image = Self.pdf417Image(from: digits) else {
                showMessage("Couldn't draw barcode.")
                return
            }
            showBarcode(image: image)
        } catch {
            showMessage("Couldn't generate barcode.")
        }
    }

    /// Core Image PDF417. Input must be the 22-digit string as ASCII data.
    static func pdf417Image(from digits: String) -> UIImage? {
        guard let filter = CIFilter(name: "CIPDF417BarcodeGenerator") else {
            return nil
        }
        filter.setValue(Data(digits.utf8), forKey: "inputMessage")
        filter.setValue(4, forKey: "inputPreferredAspectRatio")
        guard let output = filter.outputImage else {
            return nil
        }

        let scaled = output.transformed(by: CGAffineTransform(scaleX: 8, y: 8))
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent)
        else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }

    // MARK: - Barcode display state

    private func showLoading() {
        spinner.startAnimating()
        barcodeImageView.isHidden = true
        messageLabel.isHidden = true
    }

    private func showBarcode(image: UIImage) {
        spinner.stopAnimating()
        messageLabel.isHidden = true
        barcodeImageView.image = image
        barcodeImageView.isHidden = false
    }

    private func showMessage(_ text: String) {
        spinner.stopAnimating()
        barcodeImageView.isHidden = true
        barcodeImageView.image = nil
        messageLabel.text = text
        messageLabel.isHidden = false
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
}
