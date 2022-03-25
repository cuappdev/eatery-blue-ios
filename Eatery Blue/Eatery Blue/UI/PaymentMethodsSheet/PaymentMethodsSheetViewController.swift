//
//  PaymentMethodsSheetViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/24/21.
//

import EateryModel
import UIKit

class PaymentMethodsSheetViewController: SheetViewController {

    private let mealSwipesImageView = UIImageView()
    private let brbsImageView = UIImageView()
    private let cashOrCardImageView = UIImageView()
    private let descriptionLabel = UILabel()

    private(set) var paymentMethods: Set<PaymentMethod> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpStackView()
        setPaymentMethods(paymentMethods)
    }

    private func setUpStackView() {
        stackView.spacing = 24
        addHeader(title: "Payment Methods")
        addImageViews()
        addDescriptionLabel()
        addPillButton(title: "Close", style: .regular) { [self] in
            dismiss(animated: true)
        }
    }

    private func addImageViews() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill

        stack.addArrangedSubview(mealSwipesImageView)
        mealSwipesImageView.contentMode = .scaleAspectFit
        mealSwipesImageView.image = UIImage(named: "MealSwipes")?.withRenderingMode(.alwaysTemplate)
        mealSwipesImageView.snp.makeConstraints { make in
            make.height.equalTo(48)
        }

        stack.addArrangedSubview(brbsImageView)
        brbsImageView.contentMode = .scaleAspectFit
        brbsImageView.image = UIImage(named: "BRBs")?.withRenderingMode(.alwaysTemplate)
        brbsImageView.snp.makeConstraints { make in
            make.height.equalTo(48)
        }

        stack.addArrangedSubview(cashOrCardImageView)
        cashOrCardImageView.contentMode = .scaleAspectFit
        cashOrCardImageView.image = UIImage(named: "Cash")?.withRenderingMode(.alwaysTemplate)
        cashOrCardImageView.snp.makeConstraints { make in
            make.height.equalTo(48)
        }

        let container = ContainerView(content: stack)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(container)
    }

    private func addDescriptionLabel() {
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = .preferredFont(for: .subheadline, weight: .regular)
        descriptionLabel.numberOfLines = 0
        stackView.addArrangedSubview(descriptionLabel)
    }

    func setPaymentMethods(_ paymentMethods: Set<PaymentMethod>) {
        self.paymentMethods = paymentMethods

        mealSwipesImageView.tintColor = paymentMethods.contains(.mealSwipes)
            ? UIColor(named: "EateryBlue")
            : UIColor(named: "Gray05")

        brbsImageView.tintColor = paymentMethods.contains(.brbs)
            ? UIColor(named: "EateryRed")
            : UIColor(named: "Gray05")

        cashOrCardImageView.tintColor = paymentMethods.contains(.cash) && paymentMethods.contains(.credit)
            ? UIColor(named: "EateryGreen")
            : UIColor(named: "Gray05")

        descriptionLabel.attributedText = getAttributedString(paymentMethods)
    }

    private func getAttributedString(_ paymentMethods: Set<PaymentMethod>) -> NSAttributedString {
        let strings = getAttributedStrings(paymentMethods)

        let result = NSMutableAttributedString()

        switch strings.count {
        case 1:
            result.append(NSAttributedString(string: "Pay with "))
            result.append(strings[0])
            result.append(NSAttributedString(string: "."))

        case 2:
            result.append(NSAttributedString(string: "Pay with "))
            result.append(strings[0])
            result.append(NSAttributedString(string: " or "))
            result.append(strings[1])
            result.append(NSAttributedString(string: "."))

        case 3:
            result.append(NSAttributedString(string: "Pay with "))
            result.append(strings[0])
            result.append(NSAttributedString(string: ", "))
            result.append(strings[1])
            result.append(NSAttributedString(string: ", or "))
            result.append(strings[2])
            result.append(NSAttributedString(string: "."))

        default:
            result.append(NSAttributedString(string: "We're not quite sure how to pay at this eatery..."))
        }

        return result
    }

    private func getAttributedStrings(_ paymentMethods: Set<PaymentMethod>) -> [NSAttributedString] {
        var result: [NSAttributedString] = []

        if paymentMethods.contains(.mealSwipes) {
            let attributedString = NSMutableAttributedString()
            let attachment = NSTextAttachment(
                image: UIImage(named: "MealSwipes")?.withRenderingMode(.alwaysTemplate),
                scaledToMatch: descriptionLabel.font
            )
            attributedString.append(NSAttributedString(attachment: attachment))
            attributedString.append(NSAttributedString(string: " Meal swipes"))
            attributedString.addAttributes([
                    .foregroundColor: UIColor(named: "EateryBlue") as Any,
                    .font: UIFont.preferredFont(for: .subheadline, weight: .medium)
                ],
                range: NSRange(location: 0, length: attributedString.length)
            )
            result.append(attributedString)
        }

        if paymentMethods.contains(.brbs) {
            let attributedString = NSMutableAttributedString()
            let attachment = NSTextAttachment(
                image: UIImage(named: "BRBs")?.withRenderingMode(.alwaysTemplate),
                scaledToMatch: descriptionLabel.font
            )
            attributedString.append(NSAttributedString(attachment: attachment))
            attributedString.append(NSAttributedString(string: " BRBs"))
            attributedString.addAttributes([
                    .foregroundColor: UIColor(named: "EateryRed") as Any,
                    .font: UIFont.preferredFont(for: .subheadline, weight: .medium)
                ],
                range: NSRange(location: 0, length: attributedString.length)
            )
            result.append(attributedString)
        }

        if paymentMethods.contains(.cash), paymentMethods.contains(.credit) {
            let attributedString = NSMutableAttributedString()
            let attachment = NSTextAttachment(
                image: UIImage(named: "Cash")?.withRenderingMode(.alwaysTemplate),
                scaledToMatch: descriptionLabel.font
            )
            attributedString.append(NSAttributedString(attachment: attachment))
            attributedString.append(NSAttributedString(string: " Cash or credit"))
            attributedString.addAttributes([
                    .foregroundColor: UIColor(named: "EateryGreen") as Any,
                    .font: UIFont.preferredFont(for: .subheadline, weight: .medium)
                ],
                range: NSRange(location: 0, length: attributedString.length)
            )
            result.append(attributedString)
        }

        return result
    }

}
