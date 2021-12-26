//
//  SheetViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/24/21.
//

import UIKit

class SheetViewController: UIViewController {

    enum ButtonStyle {
        case regular
        case prominent
    }

    let stackView = UIStackView()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpConstraints()
    }

    func setUpSheetPresentation() {
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }

    private func setUpView() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        view.addSubview(stackView)
        setUpStackView()
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 12

        view.addSubview(stackView)
    }

    private func setUpConstraints() {
        stackView.edges(to: view.layoutMarginsGuide)
    }

    func addHeader(title: String, image: UIImage? = nil) {
        let header = UIStackView()
        header.axis = .horizontal

        let titleLabel = UILabel()
        header.addArrangedSubview(titleLabel)
        titleLabel.font = .preferredFont(for: .title2, weight: .semibold)
        titleLabel.textColor = UIColor(named: "Black")

        let attributedText = NSMutableAttributedString()
        if let image = image {
            attributedText.append(NSAttributedString(attachment: NSTextAttachment(
                image: image,
                scaledToMatch: titleLabel.font
            )))
            attributedText.append(NSAttributedString(string: " "))
        }
        attributedText.append(NSAttributedString(string: title))
        titleLabel.attributedText = attributedText

        let cancelButton = UIImageView()
        cancelButton.isUserInteractionEnabled = true
        header.addArrangedSubview(cancelButton)
        cancelButton.image = UIImage(named: "ButtonClose")
        cancelButton.on(UITapGestureRecognizer()) { [self] _ in
            dismiss(animated: true)
        }

        cancelButton.width(40)
        cancelButton.height(40)

        stackView.addArrangedSubview(header)
    }

    func addPillButton(title: String, style: ButtonStyle = .regular, action: @escaping () -> Void) {
        let titleLabel = UILabel()
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.text = title

        let container = ContainerView(pillContent: titleLabel)
        stackView.addArrangedSubview(container)

        container.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)

        container.on(UITapGestureRecognizer()) { _ in
            action()
        }

        switch style {
        case .regular:
            titleLabel.textColor = UIColor(named: "Black")
            container.clippingView.backgroundColor = UIColor(named: "Gray00")

        case .prominent:
            titleLabel.textColor = .white
            container.clippingView.backgroundColor = UIColor(named: "EateryBlue")
        }
    }

    func addTextButton(title: String, action: @escaping () -> Void) {
        let titleLabel = UILabel()
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
        titleLabel.text = title
        titleLabel.textColor = UIColor(named: "Black")
        titleLabel.textAlignment = .center

        let container = ContainerView(content: titleLabel)
        container.on(UITapGestureRecognizer()) { _ in
            action()
        }
        stackView.addArrangedSubview(container)
    }

    func addTextSection(title: String?, description: String?) {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 4

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = UIColor(named: "Gray05")
        titleLabel.font = .preferredFont(for: .subheadline, weight: .medium)
        stack.addArrangedSubview(titleLabel)

        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.textColor = UIColor(named: "Black")
        descriptionLabel.font = .preferredFont(for: .body, weight: .semibold)
        stack.addArrangedSubview(descriptionLabel)

        stackView.addArrangedSubview(stack)
    }

    func setCustomSpacing(_ spacing: CGFloat) {
        if let last = stackView.arrangedSubviews.last {
            stackView.setCustomSpacing(spacing, after: last)
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        view.layoutMargins = UIEdgeInsets(top: 24, left: 16, bottom: view.safeAreaInsets.bottom, right: 16)
    }

}

extension SheetViewController: UIViewControllerTransitioningDelegate {

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let height = view.systemLayoutSizeFitting(
            CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        ).height

        return SheetPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            height: height
        )
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        SheetPresentationAnimationController(isPresenting: true)
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        SheetPresentationAnimationController(isPresenting: false)
    }

}
