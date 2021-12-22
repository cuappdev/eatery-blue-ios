//
//  CafeViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/23/21.
//

import UIKit

class CafeViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setUpView() {
        hero.isEnabled = true

        view.addSubview(scrollView)
        setUpScrollView()
    }

    private func setUpScrollView() {
        scrollView.backgroundColor = .white
        scrollView.contentInsetAdjustmentBehavior = .never

        scrollView.alwaysBounceVertical = true
        scrollView.addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 16
    }

    private func setUpConstraints() {
        scrollView.edgesToSuperview()

        stackView.edgesToSuperview()
        stackView.width(to: scrollView)
    }

    func setUp(cafe: Cafe) {
        addHeaderImageView(imageUrl: cafe.imageUrl)
        addNameLabel(cafe.name)
        stackView.setCustomSpacing(8, after: stackView.arrangedSubviews.last!)
        addShortDescriptionLabel(cafe)
        addButtons(cafe)
    }

    private func addHeaderImageView(imageUrl: URL?) {
        let imageView = UIImageView()
        imageView.hero.id = "headerImageView"
        imageView.aspectRatio(375 / 240)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.kf.setImage(with: imageUrl)

        stackView.addArrangedSubview(imageView)
    }

    private func addNameLabel(_ name: String) {
        let label = UILabel()
        label.text = name
        label.font = .preferredFont(for: .largeTitle, weight: .semibold)
        label.textColor = UIColor(named: "Black")

        let container = ContainerView(content: label)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(container)
    }

    private func addShortDescriptionLabel(_ cafe: Cafe) {
        let label = UILabel()
        label.text = "\(cafe.building ?? "--") · \(cafe.menuSummary ?? "--")"
        label.textColor = UIColor(named: "Gray05")
        label.font = .preferredFont(for: .subheadline, weight: .regular)

        let container = ContainerView(content: label)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(container)
    }

    private func addButtons(_ cafe: Cafe) {
        let buttonStackView = PillButtonStackView()

        let buttonOrderOnline = PillButtonView()
        buttonStackView.addPillButton(buttonOrderOnline)
        buttonOrderOnline.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        buttonOrderOnline.backgroundColor = UIColor(named: "EateryBlue")
        buttonOrderOnline.imageView.image = UIImage(named: "iPhone")
        buttonOrderOnline.imageView.tintColor = .white
        buttonOrderOnline.titleLabel.textColor = .white
        buttonOrderOnline.titleLabel.text = "Order online"

        let buttonDirections = PillButtonView()
        buttonStackView.addPillButton(buttonDirections)
        buttonDirections.layoutMargins = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        buttonDirections.backgroundColor = UIColor(named: "Gray00")
        buttonDirections.imageView.image = UIImage(named: "Walk")
        buttonDirections.imageView.tintColor = UIColor(named: "Black")
        buttonDirections.titleLabel.textColor = UIColor(named: "Black")
        buttonDirections.titleLabel.text = "Get directions"

        stackView.addArrangedSubview(buttonStackView)
    }

}
