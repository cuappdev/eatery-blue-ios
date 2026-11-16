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

/// Temporary full-screen GET payment barcode. Refreshes about every 5 seconds.
@MainActor
class BarcodeViewController: UIViewController {
    private let spinner = UIActivityIndicatorView(style: .large)
    private let barcodeImageView = UIImageView()
    private let digitsLabel = UILabel()
    private let messageLabel = UILabel()
    private let ciContext = CIContext()

    private var refreshTimer: Timer?
    private var loadTask: Task<Void, Never>?
    private var seed: String?
    private var patronId: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigation()
        setUpView()
        setUpConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        RootViewController.setStatusBarStyle(.darkContent)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        loadTask?.cancel()
        loadTask = Task {
            await loadSecrets()
            guard !Task.isCancelled else { return }
            startTimer()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        loadTask?.cancel()
        loadTask = nil
        stopTimer()
    }

    deinit {
        refreshTimer?.invalidate()
    }

    private func setUpNavigation() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.Eatery.primaryText as Any,
            .font: UIFont.eateryNavigationBarTitleFont
        ]
        appearance.configureWithTransparentBackground()
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.title = "Barcode"

        let backButton = UIBarButtonItem(
            image: UIImage(named: "ArrowLeft"),
            style: .plain,
            target: self,
            action: #selector(didTapBackButton)
        )
        backButton.tintColor = UIColor.Eatery.primaryText
        backButton.accessibilityLabel = "Back"
        navigationItem.leftBarButtonItem = backButton
    }

    private func setUpView() {
        view.backgroundColor = .white

        spinner.hidesWhenStopped = true
        view.addSubview(spinner)

        barcodeImageView.contentMode = .scaleAspectFit
        barcodeImageView.backgroundColor = .white
        barcodeImageView.isHidden = true
        barcodeImageView.isAccessibilityElement = true
        barcodeImageView.accessibilityLabel = "Payment barcode"
        barcodeImageView.accessibilityTraits = .image
        view.addSubview(barcodeImageView)

        let digitsFont = UIFont.preferredFont(forTextStyle: .callout)
        digitsLabel.font = .monospacedDigitSystemFont(ofSize: digitsFont.pointSize, weight: .medium)
        digitsLabel.adjustsFontForContentSizeCategory = true
        digitsLabel.textColor = UIColor.Eatery.primaryText
        digitsLabel.textAlignment = .center
        digitsLabel.adjustsFontSizeToFitWidth = true
        digitsLabel.isHidden = true
        digitsLabel.isAccessibilityElement = true
        view.addSubview(digitsLabel)

        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.textColor = UIColor.Eatery.secondaryText
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.isHidden = true
        view.addSubview(messageLabel)
    }

    private func setUpConstraints() {
        spinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        barcodeImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview().offset(-24)
            make.height.equalTo(160)
        }

        digitsLabel.snp.makeConstraints { make in
            make.top.equalTo(barcodeImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        messageLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }

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

        guard !Task.isCancelled else { return }

        guard seed != nil, patronId != nil else {
            if patronId == nil {
                showMessage("No payment ID yet. Use GET once, then try again.")
            } else {
                showMessage("Couldn't load your barcode. Check your connection and try again.")
            }
            return
        }

        refreshBarcode()
    }

    private func fetchSeed() async -> Bool {
        guard !Networking.default.sessionId.isEmpty else {
            showMessage("Log in to GET to show a barcode.")
            return false
        }

        do {
            let config = try await Networking.default.barcodeConfig.fetch()
            guard config.canGenerateOfflineBarcode, let barcodeSeed = config.barcodeSeed else {
                showMessage("Barcode isn't available for this account.")
                return false
            }
            KeychainAccess.shared.saveBarcodeSeed(barcodeSeed)
            seed = barcodeSeed
            return true
        } catch {
            logger.error("\(#function): failed to fetch barcode seed")
            showMessage("Couldn't load your barcode. Check your connection and try again.")
            return false
        }
    }

    private func fetchPatronId() async {
        do {
            let end = Day()
            let start = end.advanced(by: -30)
            let data = try await Networking.default.accounts.fetch(start: start, end: end)
            if let id = data.patronId {
                KeychainAccess.shared.savePatronId(id)
                patronId = id
            }
        } catch {
            logger.error("\(#function): failed to fetch patron id")
        }
    }

    private func startTimer() {
        stopTimer()
        guard seed != nil, patronId != nil else {
            return
        }

        refreshTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshBarcode()
            }
        }
    }

    private func stopTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
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
            guard let image = pdf417Image(from: digits) else {
                showMessage("Couldn't draw barcode.")
                return
            }
            showBarcode(image: image, digits: digits)
        } catch {
            showMessage("Couldn't generate barcode.")
        }
    }

    private func pdf417Image(from digits: String) -> UIImage? {
        guard let filter = CIFilter(name: "CIPDF417BarcodeGenerator") else {
            return nil
        }
        filter.setValue(Data(digits.utf8), forKey: "inputMessage")
        filter.setValue(4, forKey: "inputPreferredAspectRatio")
        guard let output = filter.outputImage else {
            return nil
        }

        let scaled = output.transformed(by: CGAffineTransform(scaleX: 8, y: 8))
        guard let cgImage = ciContext.createCGImage(scaled, from: scaled.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }

    private func showLoading() {
        spinner.startAnimating()
        barcodeImageView.isHidden = true
        digitsLabel.isHidden = true
        messageLabel.isHidden = true
        UIAccessibility.post(notification: .announcement, argument: "Loading barcode")
    }

    private func showBarcode(image: UIImage, digits: String) {
        spinner.stopAnimating()
        messageLabel.isHidden = true
        barcodeImageView.image = image
        barcodeImageView.isHidden = false
        digitsLabel.text = digits
        digitsLabel.accessibilityLabel = "Barcode digits \(digits)"
        digitsLabel.isHidden = false
    }

    private func showMessage(_ text: String) {
        spinner.stopAnimating()
        barcodeImageView.isHidden = true
        barcodeImageView.image = nil
        digitsLabel.isHidden = true
        digitsLabel.text = nil
        messageLabel.text = text
        messageLabel.isHidden = false
        stopTimer()
        UIAccessibility.post(notification: .announcement, argument: text)
    }

    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}
