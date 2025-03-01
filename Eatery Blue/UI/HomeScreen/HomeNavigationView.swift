//
//  HomeNavigationView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/8/22.
//

import UIKit

class HomeNavigationView: NavigationView {

    // MARK: - Properties (view)

    let logoRefreshControl = LogoRefreshControl()
    let searchButton = NavigationImageButton()

    // MARK: - Properties (data)

    private(set) var fadeInProgress: Double = 0

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setUpSelf() {
        backgroundColor = UIColor.Eatery.blue
        layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16)

        titleLabel.text = "Eatery"
        titleLabel.textColor = .white

        largeTitleLabel.text = "Eatery"
        largeTitleLabel.textColor = .white

        searchButton.image = UIImage(named: "Search")?.withRenderingMode(.alwaysTemplate)
        searchButton.tintColor = .white
        setRightButtons([searchButton])

        addSubview(logoRefreshControl)
        setFadeInProgress(0)
    }

    private func setUpConstraints() {
        logoRefreshControl.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.bottom.equalTo(largeTitleLabel.snp.top).offset(4)
            make.leading.equalTo(layoutMarginsGuide)
        }
    }

    // MARK: - Actions

    func setFadeInProgress(_ progress: Double) {
        titleLabel.alpha = progress
        searchButton.alpha = progress
    }

    func setFadeInProgress(_ progress: Double, animated: Bool) {
        if progress == fadeInProgress {
            return
        }

        let progress = max(0, min(1, progress))
        self.fadeInProgress = progress

        if animated {
            UIView.animate(withDuration: 0.125) {
                self.setFadeInProgress(progress)
            }
        } else {
            setFadeInProgress(progress)
        }
    }

}
