//
//  AccountPickerSheetViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/9/22.
//

import UIKit

@MainActor
protocol AccountPickerSheetViewControllerDelegate: AnyObject {

    func accountPickerSheetViewController(
        _ viewController: AccountPickerSheetViewController,
        didSelectAccountAt index: Int
    )

}

class AccountPickerSheetViewController: SheetViewController {

    weak var delegate: AccountPickerSheetViewControllerDelegate?

    var selectedAccountIndex: Int?
    private var accountCells: [AccountPickerCell] = []

    func setUp(_ accounts: [String]) {
        addHeader(title: "Payment Method")
        
        for (i, account) in accounts.enumerated() {
            let cell = AccountPickerCell()
            cell.titleLabel.text = account
            cell.layoutMargins = .zero

            cell.on(UITapGestureRecognizer()) { [self] _ in
                selectedAccountIndex = i
                updateCellsFromState()
            }

            accountCells.append(cell)
            stackView.addArrangedSubview(cell)

            if i == accounts.count - 1 {
                cell.bottomSeparator.isHidden = true
            } else {
                setCustomSpacing(0)
            }
        }

        addPillButton(title: "Show transactions", style: .prominent) { [self] in
            if let selectedAccountIndex = selectedAccountIndex {
                delegate?.accountPickerSheetViewController(self, didSelectAccountAt: selectedAccountIndex)
            }
        }

        updateCellsFromState()
    }

    func setSelectedAccountIndex(_ index: Int) {
        selectedAccountIndex = index
        updateCellsFromState()
    }

    private func addSeparator() {
        let separator = ContainerView(content: HDivider())
        separator.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stackView.addArrangedSubview(separator)
    }

    private func updateCellsFromState() {
        for (i, cell) in accountCells.enumerated() {
            if i == selectedAccountIndex {
                cell.imageView.image = UIImage(named: "CheckboxFilled")
            } else {
                cell.imageView.image = UIImage(named: "CheckboxUnfilled")
            }
        }
    }

}
