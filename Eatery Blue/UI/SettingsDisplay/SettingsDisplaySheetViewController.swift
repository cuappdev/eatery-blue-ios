//
//  SettingsDisplaySheetViewController.swift
//  Eatery Blue
//
//  Created by Arielle Nudelman on 10/8/25.
//

import SnapKit
import UIKit

// MARK: - Persisted Theme Choice

enum DisplayTheme: String, CaseIterable {
    case light, dark, device

    static let storageKey = "Settings.DisplayTheme"

    static func current() -> DisplayTheme {
        if let raw = UserDefaults.standard.string(forKey: storageKey),
           let val = DisplayTheme(rawValue: raw) {
            return val
        }
        return .device
    }

    static func set(_ theme: DisplayTheme) {
        UserDefaults.standard.set(theme.rawValue, forKey: storageKey)
    }
}

// MARK: - ViewController

final class SettingsDisplaySheetViewController: SheetViewController {
    private var selected: DisplayTheme = .device {
        didSet { updateSelection() }
    }

    private lazy var lightRow = OptionRow(icon: UIImage(named: "Sun") ?? UIImage(systemName: "sun.max"),
                                          title: "Light",
                                          option: .light)

    private lazy var darkRow = OptionRow(icon: UIImage(named: "Moon") ?? UIImage(systemName: "moon"),
                                         title: "Dark",
                                         option: .dark)

    private lazy var deviceRow = OptionRow(icon: UIImage(named: "SettingsGear") ?? UIImage(systemName: "gearshape"),
                                           title: "Device Theme",
                                           option: .device)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Header
        addHeader(title: "Display")

        // Options section
        addOptions()

        // Spacing before button
        setCustomSpacing(16)

        // Done button
        addPillButton(title: "Done", style: .prominent) { [weak self] in
            guard let self else { return }
            self.applySelectedTheme()
            self.dismiss(animated: true)
        }

        // Initial selection
        selected = DisplayTheme.current()
    }

    private func addOptions() {
        [lightRow, separatorView(),
         darkRow, separatorView(),
         deviceRow].forEach { view in
            stackView.addArrangedSubview(view)
        }

        for row in [lightRow, darkRow, deviceRow] {
            row.selectionChanged = { [weak self] option in
                self?.selected = option
            }
        }
    }

    private func updateSelection() {
        lightRow.isChecked = (selected == .light)
        darkRow.isChecked = (selected == .dark)
        deviceRow.isChecked = (selected == .device)
    }

    private func applySelectedTheme() {
        // Persist choice
        DisplayTheme.set(selected)

        // Determine the interface style to apply
        let style: UIUserInterfaceStyle
        switch selected {
        case .light:
            style = .light
        case .dark:
            style = .dark
        case .device:
            style = .unspecified
        }

        // Apply to all windows so the whole app updates immediately
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.overrideUserInterfaceStyle = style }
    }

    private func separatorView() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.Eatery.gray01
        v.snp.makeConstraints { make in make.height.equalTo(1.0 / UIScreen.main.scale) }
        return v
    }
}

// MARK: - Option Row

private final class OptionRow: UIControl {
    let option: DisplayTheme
    var selectionChanged: ((DisplayTheme) -> Void)?

    // UI
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let radio = Radio()

    var isChecked: Bool = false {
        didSet { radio.isOn = isChecked }
    }

    init(icon: UIImage?, title: String, option: DisplayTheme) {
        self.option = option
        super.init(frame: .zero)

        // Icon
        iconView.image = icon
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor.Eatery.secondaryText

        // Title
        titleLabel.text = title
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
        titleLabel.textColor = UIColor.Eatery.primaryText
        titleLabel.numberOfLines = 1

        // Layout container
        let h = UIStackView(arrangedSubviews: [iconView, titleLabel, UIView(), radio])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 12
        h.isLayoutMarginsRelativeArrangement = true
        h.layoutMargins = UIEdgeInsets(top: 16, left: 4, bottom: 16, right: 4)
        h.isUserInteractionEnabled = false

        addSubview(h)
        h.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconView.snp.makeConstraints { make in
            make.width.height.equalTo(28)
        }
        radio.snp.makeConstraints { make in
            make.width.height.equalTo(28)
        }

        // Touch handling
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    @objc private func didTap() {
        selectionChanged?(option)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Radio (check indicator)

private final class Radio: UIView {
    var isOn: Bool = false { didSet { setNeedsLayout() } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let outer = CAShapeLayer()
        outer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: 2.5, dy: 2.5)).cgPath
        outer.fillColor = UIColor.clear.cgColor
        outer.strokeColor = UIColor.Eatery.secondaryText.cgColor
        outer.lineWidth = 2
        layer.addSublayer(outer)

        if isOn {
            let innerRect = bounds.insetBy(dx: bounds.width * 0.22, dy: bounds.height * 0.22)
            let inner = CAShapeLayer()
            inner.path = UIBezierPath(ovalIn: innerRect).cgPath
            inner.fillColor = UIColor.Eatery.primaryText.cgColor
            layer.addSublayer(inner)
            outer.strokeColor = UIColor.Eatery.primaryText.cgColor
        }
    }
}
