//
//  PaymentMethodsFilterViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/24/21.
//

import UIKit

class PaymentMethodsFilterViewController: SheetViewController {

    private let mealSwipesView = PaymentMethodFilterView()
    private let brbsView = PaymentMethodFilterView()
    private let cashOrCreditView = PaymentMethodFilterView()
    private(set) var selectedPaymentMethods: Set<PaymentMethod> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpStackView()
    }

    private func setUpStackView() {
        addHeader(title: "Payment Methods")
        addPaymentMethodToggles()
        addPillButton(title: "Show results", style: .prominent) { [self] in
            dismiss(animated: true)
        }
        addTextButton(title: "Reset") { [self] in
            selectedPaymentMethods = []
            setPaymentMethodViewsFromSelectedPaymentMethods()
            dismiss(animated: true)
        }
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

        stack.addArrangedSubview(cashOrCreditView)
        cashOrCreditView.label.text = "Cash or credit"
        cashOrCreditView.on(UITapGestureRecognizer()) { [self] _ in
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
        mealSwipesView.width(to: cashOrCreditView)

        let container = ContainerView(content: stack)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(container)

        setPaymentMethodViewsFromSelectedPaymentMethods()
    }

    private func setUpConstraints() {
        stackView.edges(to: view.layoutMarginsGuide)
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
            cashOrCreditView.imageView.image = UIImage(named: "CashSelected")
            cashOrCreditView.label.textColor = UIColor(named: "EateryGreen")
        } else {
            cashOrCreditView.imageView.image = UIImage(named: "CashUnselected")
            cashOrCreditView.label.textColor = UIColor(named: "Gray05")
        }
    }

}
