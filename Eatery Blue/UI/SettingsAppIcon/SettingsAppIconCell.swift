//
//  SettingsAppIconCell.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi on 4/16/24.
//

import UIKit

class SettingsAppIconCell: UICollectionViewCell {

    // MARK: - Properties (data)

<<<<<<< HEAD
    static let reuse = "SettingsAppIconCellReuseId"
=======
    static let reuse = "SettingsAppIconCellReuse"
>>>>>>> f700b62 (implement tappable tabs for compare menus)

    // MARK: - Properties (view)

    private let containerView = UIView()
    private let iconView = UIImageView()
    private let overlayView = UIView()
    private let checkImageView = UIImageView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

<<<<<<< HEAD
        setupViews()
        setupConstraints()
=======
        setUpSelf()
        setUpConstraints()
>>>>>>> f700b62 (implement tappable tabs for compare menus)
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

<<<<<<< HEAD
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
=======
    private func setUpSelf() {
        backgroundColor = .clear

        addSubview(containerView)
        setUpContainterView()

        containerView.addSubview(iconView)
        setUpIconView()

        addSubview(overlayView)
        setUpOverlayView()

        addSubview(checkImageView)
        setUpCheckImageView()
    }

    private func setUpContainterView() {
>>>>>>> f700b62 (implement tappable tabs for compare menus)
        containerView.layer.shadowColor = UIColor.Eatery.black.cgColor
        containerView.layer.shadowOpacity = 0.20
        containerView.layer.shadowOffset = .zero
        containerView.layer.shadowRadius = 5
    }

<<<<<<< HEAD
    private func setupIconView() {
=======
    private func setUpIconView() {
>>>>>>> f700b62 (implement tappable tabs for compare menus)
        iconView.contentMode = .scaleAspectFit
        iconView.layer.cornerRadius = 12
        iconView.layer.masksToBounds = true
    }

<<<<<<< HEAD
    private func setupOverlayView() {
=======
    private func setUpOverlayView() {
>>>>>>> f700b62 (implement tappable tabs for compare menus)
        overlayView.backgroundColor = .black
        overlayView.alpha = 0
        overlayView.layer.cornerRadius = 12
        overlayView.layer.masksToBounds = true
    }

<<<<<<< HEAD
    private func setupCheckImageView() {
=======
    private func setUpCheckImageView() {
>>>>>>> f700b62 (implement tappable tabs for compare menus)
        checkImageView.image = UIImage(named: "CheckboxFilled")
        checkImageView.isHidden = true
    }

    // MARK: - Constraints

<<<<<<< HEAD
    private func setupConstraints() {
=======
    private func setUpConstraints() {
>>>>>>> f700b62 (implement tappable tabs for compare menus)
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

