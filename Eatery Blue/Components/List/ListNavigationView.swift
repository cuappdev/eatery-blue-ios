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

    let filtersView = PillFiltersView()

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
        addSubview(filtersView)

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
        backButton.content.tintColor = UIColor(named: "Black")
        backButton.content.contentMode = .scaleAspectFit
    }

    private func setUpTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
    }

    private func setUpSearchButton() {
        searchButton.content.image = UIImage(named: "Search")?.withRenderingMode(.alwaysTemplate)
        searchButton.content.tintColor = UIColor(named: "Black")
        searchButton.content.contentMode = .scaleAspectFit
    }

    private func setUpSeparator() {
        separator.backgroundColor = UIColor(named: "Gray01")
    }

    private func setUpConstraints() {
        blurView.edgesToSuperview()

        normalNavigationBar.height(44)
        normalNavigationBar.edges(to: layoutMarginsGuide, excluding: .bottom)

        backButton.width(24)
        backButton.height(44)
        backButton.centerYToSuperview()
        backButton.leadingToSuperview()

        titleLabel.leadingToTrailing(of: backButton, offset: 8, relation: .equalOrGreater)
        titleLabel.topToSuperview()
        titleLabel.centerXToSuperview()
        titleLabel.bottomToSuperview()
        titleLabel.trailingToLeading(of: searchButton, offset: 8, relation: .equalOrLess)

        searchButton.width(24)
        searchButton.height(44)
        searchButton.centerYToSuperview()
        searchButton.trailingToSuperview()

        filterPlaceholder.topToBottom(of: normalNavigationBar, offset: 12)
        filterPlaceholder.leadingToSuperview()
        filterPlaceholder.trailingToSuperview()
        filterPlaceholder.bottom(to: layoutMarginsGuide)

        filtersView.edges(to: filterPlaceholder)

        separator.edgesToSuperview(excluding: .top)
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
