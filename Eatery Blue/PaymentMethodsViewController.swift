//
//  PaymentMethodsViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/24/21.
//

import UIKit

class PaymentMethodsViewController: UIViewController {

    private let stackView = UIStackView()

    private let mealSwipesView = PaymentMethodView()
    private let brbsView = PaymentMethodView()
    private let cashAndCreditView = PaymentMethodView()
    var selectedPaymentMethods: Set<PaymentMethod> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpConstraints()

        setUpSheetPresentation()
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
        addHeader()
        addPaymentMethodToggles()
        addPillButton(title: "Show results") { [self] in
            dismiss(animated: true)
        }
        addTextButton(title: "Reset") { [self] in
            selectedPaymentMethods = []
            setPaymentMethodViewsFromSelectedPaymentMethods()
        }
    }

    private func addHeader() {
        let header = UIStackView()
        header.axis = .horizontal

        let titleLabel = UILabel()
        header.addArrangedSubview(titleLabel)
        titleLabel.font = .preferredFont(for: .title2, weight: .semibold)
        titleLabel.textColor = UIColor(named: "Black")
        titleLabel.text = "Payment Methods"

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

    private func addPaymentMethodToggles() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalCentering
        stack.alignment = .fill

        stack.addArrangedSubview(mealSwipesView)
        mealSwipesView.label.text = "Meal swipes"
        mealSwipesView.on(UITapGestureRecognizer()) { [self] _ in
            if selectedPaymentMethods.contains(.mealSwipes) {
                selectedPaymentMethods.remove(.mealSwipes)
            } else {
                selectedPaymentMethods.insert(.mealSwipes)
            }

            setPaymentMethodViewsFromSelectedPaymentMethods()
        }

        stack.addArrangedSubview(brbsView)
        brbsView.label.text = "BRBs"
        brbsView.on(UITapGestureRecognizer()) { [self] _ in
            if selectedPaymentMethods.contains(.brbs) {
                selectedPaymentMethods.remove(.brbs)
            } else {
                selectedPaymentMethods.insert(.brbs)
            }

            setPaymentMethodViewsFromSelectedPaymentMethods()
        }

        stack.addArrangedSubview(cashAndCreditView)
        cashAndCreditView.label.text = "Cash or credit"
        cashAndCreditView.on(UITapGestureRecognizer()) { [self] _ in
            if selectedPaymentMethods.contains(.cash), selectedPaymentMethods.contains(.credit) {
                selectedPaymentMethods.remove(.cash)
                selectedPaymentMethods.remove(.credit)
            } else {
                selectedPaymentMethods.insert(.cash)
                selectedPaymentMethods.insert(.credit)
            }

            setPaymentMethodViewsFromSelectedPaymentMethods()
        }

        mealSwipesView.width(to: brbsView)
        mealSwipesView.width(to: cashAndCreditView)

        let container = ContainerView(content: stack)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(container)

        setPaymentMethodViewsFromSelectedPaymentMethods()
    }

    private func addPillButton(title: String, action: @escaping () -> Void) {
        let titleLabel = UILabel()
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.text = title
        titleLabel.textColor = .white

        let container = ContainerView(pillContent: titleLabel)
        container.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        container.clippingView.backgroundColor = UIColor(named: "EateryBlue")
        container.on(UITapGestureRecognizer()) { _ in
            action()
        }
        stackView.addArrangedSubview(container)
    }

    private func addTextButton(title: String, action: @escaping () -> Void) {
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

    private func setUpConstraints() {
        stackView.edges(to: view.layoutMarginsGuide)
    }

    func setUpSheetPresentation() {
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }

    override func viewSafeAreaInsetsDidChange() {
        view.layoutMargins = UIEdgeInsets(top: 24, left: 16, bottom: view.safeAreaInsets.bottom, right: 16)
    }

    private func setPaymentMethodViewsFromSelectedPaymentMethods() {
        if selectedPaymentMethods.contains(.mealSwipes) {
            mealSwipesView.imageView.image = UIImage(named: "MealSwipesSelected")
            mealSwipesView.label.textColor = UIColor(named: "EateryBlue")
        } else {
            mealSwipesView.imageView.image = UIImage(named: "MealSwipesUnselected")
            mealSwipesView.label.textColor = UIColor(named: "Gray05")
        }

        if selectedPaymentMethods.contains(.brbs) {
            brbsView.imageView.image = UIImage(named: "BRBsSelected")
            brbsView.label.textColor = UIColor(named: "EateryRed")
        } else {
            brbsView.imageView.image = UIImage(named: "BRBsUnselected")
            brbsView.label.textColor = UIColor(named: "Gray05")
        }

        if selectedPaymentMethods.contains(.cash), selectedPaymentMethods.contains(.credit) {
            cashAndCreditView.imageView.image = UIImage(named: "CashSelected")
            cashAndCreditView.label.textColor = UIColor(named: "EateryGreen")
        } else {
            cashAndCreditView.imageView.image = UIImage(named: "CashUnselected")
            cashAndCreditView.label.textColor = UIColor(named: "Gray05")
        }
    }

}

extension PaymentMethodsViewController: UIViewControllerTransitioningDelegate {

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
