//
//  ListNavigationView.swift
//  Eatery Blue
//
//  Created by William Ma on 12/27/21.
//

import UIKit

protocol ListNavigationViewDelegate: AnyObject {

    func listNavigationViewDidLayoutSubviews(_ view: ListNavigationView)

}

class ListNavigationView: UIView {

    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))

    let normalNavigationBar = UIView()
    let backButton = ContainerView(content: UIImageView())
    let titleLabel = UILabel()
    let searchButton = ContainerView(content: UIImageView())

    // A view that holds the place of the filtersView in the navigation view
    let filterPlaceholder = UIView()

    let separator = HDivider()

    private(set) var fadeInProgress: Double = 0

    weak var delegate: ListNavigationViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpSelf()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpSelf() {
        addSubview(blurView)
        setUpBlurView()

        addSubview(normalNavigationBar)
        setUpNormalNavigationBar()

        addSubview(filterPlaceholder)

        addSubview(separator)
        setUpSeparator()

        setFadeInProgress(fadeInProgress)
    }

    private func setUpNormalNavigationBar() {
        normalNavigationBar.addSubview(backButton)
        setUpBackButton()

        normalNavigationBar.addSubview(titleLabel)
        setUpTitleLabel()

        normalNavigationBar.addSubview(searchButton)
        setUpSearchButton()
    }

    private func setUpBlurView() {
        blurView.alpha = 1
    }

    private func setUpBackButton() {
        backButton.content.image = UIImage(named: "ArrowLeft")?.withRenderingMode(.alwaysTemplate)
        backButton.content.tintColor = UIColor.Eatery.black
        backButton.content.contentMode = .scaleAspectFit
    }

    private func setUpTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
    }

    private func setUpSearchButton() {
        searchButton.content.image = UIImage(named: "Search")?.withRenderingMode(.alwaysTemplate)
        searchButton.content.tintColor = UIColor.Eatery.black
        searchButton.content.contentMode = .scaleAspectFit
    }

    private func setUpSeparator() {
        separator.backgroundColor = UIColor.Eatery.gray01
    }

    private func setUpConstraints() {
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        normalNavigationBar.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.top.leading.trailing.equalTo(layoutMarginsGuide)
        }

        backButton.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.height.equalTo(44)
            make.centerY.leading.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(backButton.snp.trailing).offset(8)
            make.top.centerX.bottom.equalToSuperview()
            make.trailing.lessThanOrEqualTo(searchButton.snp.leading).offset(-8)
        }

        searchButton.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.height.equalTo(44)
            make.centerY.trailing.equalToSuperview()
        }

        filterPlaceholder.snp.makeConstraints { make in
            make.top.equalTo(normalNavigationBar.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(layoutMarginsGuide)
        }

        separator.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        delegate?.listNavigationViewDidLayoutSubviews(self)
    }

    func setFadeInProgress(_ progress: Double) {
        blurView.alpha = progress
        titleLabel.alpha = progress
        separator.alpha = progress
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
