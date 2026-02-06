//
//  PaymentMethodsFilterSheetViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/24/21.
//

import EateryModel
import UIKit

protocol PaymentMethodsFilterSheetViewControllerDelegate: AnyObject {
    func paymentMethodsFilterSheetViewController(
        _ viewController: PaymentMethodsFilterSheetViewController,
        didSelectPaymentMethods paymentMethods: Set<PaymentMethod>
    )
}

class PaymentMethodsFilterSheetViewController: SheetViewController {
    private let mealSwipesView = PaymentMethodFilterView()
    private let brbsView = PaymentMethodFilterView()
    private let cashOrCreditView = PaymentMethodFilterView()
    private(set) var selectedPaymentMethods: Set<PaymentMethod> = []

    weak var delegate: PaymentMethodsFilterSheetViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpStackView()
    }

    private func setUpStackView() {
        addHeader(title: "Payment Methods")
        addPaymentMethodToggles()
        addPillButton(title: "Show results", style: .prominent) { [self] in
            delegate?.paymentMethodsFilterSheetViewController(self, didSelectPaymentMethods: selectedPaymentMethods)
        }
        addTextButton(title: "Reset") { [self] in
            selectedPaymentMethods = []
            updatePaymentMethodViewsFromState(animated: true)
            delegate?.paymentMethodsFilterSheetViewController(self, didSelectPaymentMethods: selectedPaymentMethods)
        }
    }

    private func addPaymentMethodToggles() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalCentering
        stack.alignment = .fill

        stack.addArrangedSubview(mealSwipesView)
        mealSwipesView.label.text = "Meal swipes"
        mealSwipesView.tap { [self] _ in
            if selectedPaymentMethods.contains(.mealSwipe) {
                selectedPaymentMethods.remove(.mealSwipe)
            } else {
                selectedPaymentMethods.insert(.mealSwipe)
            }

            updatePaymentMethodViewsFromState(animated: true)
        }

        stack.addArrangedSubview(brbsView)
        brbsView.label.text = "BRBs"
        brbsView.tap { [self] _ in
            if selectedPaymentMethods.contains(.brbs) {
                selectedPaymentMethods.remove(.brbs)
            } else {
                selectedPaymentMethods.insert(.brbs)
            }

            updatePaymentMethodViewsFromState(animated: true)
        }

        stack.addArrangedSubview(cashOrCreditView)
        cashOrCreditView.label.text = "Cash or credit"
        cashOrCreditView.tap { [self] _ in
            if selectedPaymentMethods.contains(.cash), selectedPaymentMethods.contains(.card) {
                selectedPaymentMethods.remove(.cash)
                selectedPaymentMethods.remove(.card)
            } else {
                selectedPaymentMethods.insert(.cash)
                selectedPaymentMethods.insert(.card)
            }

            updatePaymentMethodViewsFromState(animated: true)
        }

        mealSwipesView.snp.makeConstraints { make in
            make.width.equalTo(brbsView)
            make.width.equalTo(cashOrCreditView)
        }

        let container = ContainerView(content: stack)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(container)

        updatePaymentMethodViewsFromState(animated: false)
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(view.layoutMarginsGuide)
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        view.layoutMargins = UIEdgeInsets(top: 24, left: 16, bottom: view.safeAreaInsets.bottom, right: 16)
    }

    private func updatePaymentMethodViewsFromState(animated: Bool) {
        guard !animated else {
            UIView.transition(with: view, duration: 0.1, options: [
                .allowUserInteraction,
                .transitionCrossDissolve
            ]) { [self] in
                updatePaymentMethodViewsFromState(animated: false)
            }
            return
        }

        if selectedPaymentMethods.contains(.mealSwipe) {
            mealSwipesView.imageView.image = UIImage(named: "MealSwipesSelected")
            mealSwipesView.label.textColor = UIColor.Eatery.blue
        } else {
            mealSwipesView.imageView.image = UIImage(named: "MealSwipesUnselected")
            mealSwipesView.label.textColor = UIColor.Eatery.secondaryText
        }

        if selectedPaymentMethods.contains(.brbs) {
            brbsView.imageView.image = UIImage(named: "BRBsSelected")
            brbsView.label.textColor = UIColor.Eatery.red
        } else {
            brbsView.imageView.image = UIImage(named: "BRBsUnselected")
            brbsView.label.textColor = UIColor.Eatery.secondaryText
        }

        if selectedPaymentMethods.contains(.cash), selectedPaymentMethods.contains(.card) {
            cashOrCreditView.imageView.image = UIImage(named: "CashSelected")
            cashOrCreditView.label.textColor = UIColor.Eatery.green
        } else {
            cashOrCreditView.imageView.image = UIImage(named: "CashUnselected")
            cashOrCreditView.label.textColor = UIColor.Eatery.secondaryText
        }
    }

    func setSelectedPaymentMethods(_ paymentMethods: Set<PaymentMethod>, animated: Bool) {
        selectedPaymentMethods = paymentMethods
        updatePaymentMethodViewsFromState(animated: animated)
    }
}
