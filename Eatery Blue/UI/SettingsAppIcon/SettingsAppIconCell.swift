//
//  SettingsAppIconCell.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 4/16/24.
//

import UIKit

class SettingsAppIconCell: UICollectionViewCell {

    // MARK: - Properties (data)

    static let reuse = "SettingsAppIconCellReuseId"

    // MARK: - Properties (view)

    private let containerView = UIView()
    private let iconView = UIImageView()
    private let overlayView = UIView()
    private let checkImageView = UIImageView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    func configure(appIcon: AppIcon) {
        iconView.image = appIcon.icon

        if appIcon.name == UserDefaults.standard.string(forKey: UserDefaultsKeys.activeIcon) {
            overlayView.alpha = 0.4
            checkImageView.isHidden = false
        } else {
            overlayView.alpha = 0
            checkImageView.isHidden = true
        }
    }

    private func setupViews() {
        backgroundColor = .clear

        addSubview(containerView)
        setupContainterView()

        containerView.addSubview(iconView)
        setupIconView()

        addSubview(overlayView)
        setupOverlayView()

        addSubview(checkImageView)
        setupCheckImageView()
    }

    private func setupContainterView() {
        containerView.layer.shadowColor = UIColor.Eatery.black.cgColor
        containerView.layer.shadowOpacity = 0.20
        containerView.layer.shadowOffset = .zero
        containerView.layer.shadowRadius = 5
    }

    private func setupIconView() {
        iconView.contentMode = .scaleAspectFit
        iconView.layer.cornerRadius = 12
        iconView.layer.masksToBounds = true
    }

    private func setupOverlayView() {
        overlayView.backgroundColor = .black
        overlayView.alpha = 0
        overlayView.layer.cornerRadius = 12
        overlayView.layer.masksToBounds = true
    }

    private func setupCheckImageView() {
        checkImageView.image = UIImage(named: "CheckboxFilled")
        checkImageView.isHidden = true
    }

    // MARK: - Constraints

    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(64)
        }

        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(64)
        }

        overlayView.snp.makeConstraints { make in
            make.edges.equalTo(iconView)
        }

        checkImageView.snp.makeConstraints { make in
            make.center.equalTo(overlayView)
        }
    }

}

