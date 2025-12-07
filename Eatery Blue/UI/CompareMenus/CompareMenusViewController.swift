//
//  CompareMenusViewController.swift
//  Eatery Blue
//
//  Created by Peter Bidoshi  on 3/5/24.
//

import EateryModel
import UIKit

class CompareMenusViewController: UIViewController {
    // MARK: - Properties (data)

    private let allEateries: [Eatery]
    private let comparedEateries: [Eatery]
    private let pageController: CompareMenusPageViewController

    // MARK: - Properties (view)

    private let navigationView = CompareMenusNavigationView()
    private let compareMenusOnboarding = CompareMenusInternalOnboardingView()

    // MARK: - Init

    init(allEateries: [Eatery], comparedEateries: [Eatery]) {
        pageController = CompareMenusPageViewController(eateries: comparedEateries, allEateries: allEateries)
        self.allEateries = allEateries
        self.comparedEateries = comparedEateries

        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Setup

    override func viewDidLoad() {
        view.backgroundColor = UIColor.Eatery.default00
        view.clipsToBounds = true

        addChild(pageController)
        view.addSubview(pageController.view)
        pageController.delegate = self

        setUpNavigationView()
        view.addSubview(navigationView)

        setUpConstraints()
        trySetCompareMenusUpOnboarding()
        view.bringSubviewToFront(navigationView)
    }

    private func trySetCompareMenusUpOnboarding() {
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.didInternallyOnboardCompareMenus) { return }

        compareMenusOnboarding.layer.opacity = 0.01
        navigationController?.tabBarController?.parent?.view.addSubview(compareMenusOnboarding)
        compareMenusOnboarding.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            compareMenusOnboarding.layer.opacity = 1
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpNavigationView() {
        navigationView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 12, right: 16)
        navigationView.backButton.buttonPress { [weak self] _ in
            guard let self else { return }
            navigationController?.popViewController(animated: true)
        }

        navigationView.editButton.buttonPress { [weak self] _ in
            guard let self else { return }
            navigationController?.popViewController(animated: true)
            let selectionViewController = CompareMenusSheetViewController(
                parentNavigationController: navigationController,
                selectedEateries: comparedEateries,
                selectedOn: true
            )
            selectionViewController.setUpSheetPresentation()
            tabBarController?.present(selectionViewController, animated: true)
        }
    }

    private func setUpConstraints() {
        navigationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.height.equalTo(56)
        }

        pageController.view.snp.makeConstraints { make in
            make.trailing.leading.bottom.equalToSuperview()
            make.top.equalTo(navigationView.snp.bottom)
        }
    }

    // MARK: - Error Handling

    func showInlineError() {
        // Remove page content from view
        pageController.view.removeFromSuperview()

        let container = UIView()
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12

        let imageView = UIImageView(image: UIImage(systemName: "xmark.octagon"))
        imageView.tintColor = UIColor.Eatery.red
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(41)
        }

        let titleLabel = UILabel()
        titleLabel.text = "Hmm, no chow here (yet)."
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        let messageLabel = UILabel()
        messageLabel.text = "We ran into an issue loading this page. Check your connection or try again later"
        messageLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        messageLabel.textColor = UIColor.Eatery.gray05
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        stack.addArrangedSubview(imageView)
        stack.setCustomSpacing(12, after: imageView)
        stack.addArrangedSubview(titleLabel)
        stack.setCustomSpacing(4, after: titleLabel)
        stack.addArrangedSubview(messageLabel)

        container.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().inset(41)
            make.trailing.lessThanOrEqualToSuperview().inset(41)
        }

        view.bringSubviewToFront(navigationView)
    }
}

extension CompareMenusViewController: CompareMenusPageViewControllerDelegate {
    func compareMenusPageViewControllerDidFailToLoadMenus(_: CompareMenusPageViewController) {
        showInlineError()
    }
}
