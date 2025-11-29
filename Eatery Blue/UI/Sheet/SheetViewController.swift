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
        view.backgroundColor = UIColor.Eatery.default00
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.insetsLayoutMarginsFromSafeArea = false
        view.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

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
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(view.layoutMarginsGuide)
        }
    }

    func addHeader(title: String, image: UIImage? = nil) {
        let header = UIStackView()
        header.axis = .horizontal

        let titleLabel = UILabel()
        header.addArrangedSubview(titleLabel)
        titleLabel.font = .preferredFont(for: .title2, weight: .semibold)
        titleLabel.textColor = UIColor.Eatery.primaryText

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
        cancelButton.tap { [self] _ in
            dismiss(animated: true)
        }

        cancelButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }

        stackView.addArrangedSubview(header)
    }

    func addPillButton(title: String, style: ButtonStyle = .regular, action: @escaping () -> Void) {
        let titleLabel = UILabel()
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.text = title

        let container = ButtonView(pillContent: titleLabel)
        stackView.addArrangedSubview(container)

        container.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)

        container.buttonPress { _ in
            action()
        }

        switch style {
        case .regular:
            titleLabel.textColor = UIColor.Eatery.primaryText
            container.cornerRadiusView.backgroundColor = UIColor.Eatery.gray00

        case .prominent:
            titleLabel.textColor = UIColor.Eatery.default00
            container.cornerRadiusView.backgroundColor = UIColor.Eatery.blue
        }
    }

    func addTextButton(title: String, action: @escaping () -> Void) {
        let titleLabel = UILabel()
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
        titleLabel.text = title
        titleLabel.textColor = UIColor.Eatery.primaryText
        titleLabel.textAlignment = .center

        let container = ButtonView(content: titleLabel)
        container.buttonPress { _ in
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
        titleLabel.textColor = UIColor.Eatery.secondaryText
        titleLabel.font = .preferredFont(for: .subheadline, weight: .medium)
        stack.addArrangedSubview(titleLabel)

        let attributedString = NSMutableAttributedString(string: description ?? "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length)
        )

        let descriptionLabel = UILabel()
        descriptionLabel.attributedText = attributedString
        descriptionLabel.textColor = UIColor.Eatery.primaryText
        descriptionLabel.font = .preferredFont(for: .body, weight: .semibold)
        descriptionLabel.numberOfLines = 0
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
        source _: UIViewController
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
        forPresented _: UIViewController,
        presenting _: UIViewController,
        source _: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        SheetPresentationAnimationController(isPresenting: true)
    }

    func animationController(
        forDismissed _: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        SheetPresentationAnimationController(isPresenting: false)
    }
}
