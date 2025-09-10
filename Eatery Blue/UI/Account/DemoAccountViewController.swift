//
//  DemoAccountViewController.swift
//  Eatery Blue
//
//  Created by Jayson Hahn on 4/21/25.
//

import EateryGetAPI
import EateryModel
import UIKit

protocol DemoAccountViewControllerDelegate: AnyObject {
    func demoModeDidLogout()
}

enum DemoEateryAccountType: Int, CustomStringConvertible, CaseIterable {
    case mealPlan
    case bigRedBucks
    case cityBucks
    case laundry

    var description: String {
        switch self {
        case .mealPlan: return "Meal Swipes"
        case .bigRedBucks: return "Big Red Bucks"
        case .cityBucks: return "City Bucks"
        case .laundry: return "Laundry"
        }
    }
}

@MainActor
class DemoAccountModelController: AccountViewController {
    enum TimePeriod: CaseIterable {
        case past7Days
        case past30Days
        case past365Days
    }

    let demoBalances: [BalanceItem] = [
        BalanceItem(title: "Meal Swipes", subtitle: NSAttributedString(string: "Unlimited")),
        BalanceItem(title: "Big Red Bucks", subtitle: NSAttributedString(string: "$350.00")),
        BalanceItem(title: "City Bucks", subtitle: NSAttributedString(string: "$0.00")),
        BalanceItem(title: "Laundry", subtitle: NSAttributedString(string: ""))
    ]

    var delegate: DemoAccountViewControllerDelegate?

    private var selectedAccount: DemoEateryAccountType = .mealPlan
    private var selectedTimePeriod: TimePeriod = .past30Days

    override func viewDidLoad() {
        super.viewDidLoad()

        // Change nav bar title
        navigationItem.title = "Demo Account"

        // Remove the pull-to-refresh
        if let table = view.subviews.compactMap({ $0 as? UITableView }).first {
            table.refreshControl = nil
        }

        // Remove the loading spinner
        view.subviews
            .compactMap { $0 as? UIActivityIndicatorView }
            .forEach { $0.removeFromSuperview() }

        setUpTransactionsHeaderView()

        updateCellsFromState()
        updateTransactionsHeaderViewFromState()
    }

    override func setUpNavigation() {
        super.setUpNavigation()

        let backButtonItem = UIBarButtonItem(
            image: UIImage(named: "ArrowLeft"),
            style: .plain,
            target: self,
            action: #selector(didTapBackButton)
        )
        backButtonItem.tintColor = .white
        navigationItem.leftBarButtonItem = backButtonItem
    }

    @objc private func didTapBackButton() {
        delegate?.demoModeDidLogout()
    }

    private func setUpTransactionsHeaderView() {
        transactionsHeaderView.buttonImageView.tap { [self] _ in
            let viewController = AccountPickerSheetViewController()
            viewController.setUpSheetPresentation()
            viewController.setUp(DemoEateryAccountType.allCases.map(\.description))
            viewController.setSelectedAccountIndex(selectedAccount.rawValue)
            viewController.delegate = self
            tabBarController?.present(viewController, animated: true)
        }
    }

    private func updateCellsFromState() {
        updateCells(balances: demoBalances, transactions: selectedAccount.demoTransactions)
    }

    private func updateTransactionsHeaderViewFromState() {
        switch selectedAccount {
        case .mealPlan: transactionsHeaderView.titleLabel.text = "Meal Swipes"
        case .bigRedBucks: transactionsHeaderView.titleLabel.text = "Big Red Bucks"
        case .cityBucks: transactionsHeaderView.titleLabel.text = "City Bucks"
        case .laundry: transactionsHeaderView.titleLabel.text = "Laundry"
        }

        switch selectedTimePeriod {
        case .past7Days: transactionsHeaderView.headerLabel.text = "Past 7 Days"
        case .past30Days: transactionsHeaderView.headerLabel.text = "Past 30 Days"
        case .past365Days: transactionsHeaderView.headerLabel.text = "Past Year"
        }
    }
}

extension DemoAccountModelController: AccountPickerSheetViewControllerDelegate {
    func accountPickerSheetViewController(
        _ viewController: AccountPickerSheetViewController,
        didSelectAccountAt index: Int
    ) {
        if let account = DemoEateryAccountType(rawValue: index) {
            selectedAccount = account
            updateCellsFromState()
            updateTransactionsHeaderViewFromState()
        }

        viewController.dismiss(animated: true)
    }
}

extension DemoEateryAccountType {
    /// A quick formatter for “yesterday”
    private var yesterdayString: String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .none
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        return fmt.string(from: yesterday)
    }

    private var semiboldFont: UIFont {
        .preferredFont(for: .footnote, weight: .semibold)
    }

    private var mediumFont: UIFont {
        .preferredFont(for: .footnote, weight: .medium)
    }

    var demoTransactions: [AccountViewController.TransactionItem] {
        switch self {
        case .mealPlan:
            return [
                .init(
                    title: "Morrison Dining Hall",
                    time: "6:00 PM",
                    date: yesterdayString,
                    amount: {
                        let ms = NSMutableAttributedString(
                            string: "1",
                            attributes: [.font: semiboldFont]
                        )
                        ms.append(.init(
                            string: " swipe",
                            attributes: [.font: mediumFont, .foregroundColor: UIColor.Eatery.gray05]
                        ))
                        return ms
                    }()
                ),
                .init(
                    title: "Okenshields",
                    time: "12:30 PM",
                    date: yesterdayString,
                    amount: {
                        let ms = NSMutableAttributedString(
                            string: "1",
                            attributes: [.font: semiboldFont]
                        )
                        ms.append(.init(
                            string: " swipe",
                            attributes: [.font: mediumFont, .foregroundColor: UIColor.Eatery.gray05]
                        ))
                        return ms
                    }()
                ),
                .init(
                    title: "Jansens at Bethe House",
                    time: "8:15 AM",
                    date: yesterdayString,
                    amount: {
                        let ms = NSMutableAttributedString(
                            string: "1",
                            attributes: [.font: semiboldFont]
                        )
                        ms.append(.init(
                            string: " swipe",
                            attributes: [.font: mediumFont, .foregroundColor: UIColor.Eatery.gray05]
                        ))
                        return ms
                    }()
                )
            ]

        case .bigRedBucks:
            return [
                .init(
                    title: "Bear Necessities",
                    time: "9:45 PM",
                    date: yesterdayString,
                    amount: NSMutableAttributedString(
                        string: "$24.00",
                        attributes: [.font: semiboldFont]
                    )
                ),
                .init(
                    title: "Stadler Macs",
                    time: "1:00 PM",
                    date: yesterdayString,
                    amount: NSMutableAttributedString(
                        string: "$19.00",
                        attributes: [.font: semiboldFont]
                    )
                ),

                .init(
                    title: "College Town Bagels",
                    time: "10:30 AM",
                    date: yesterdayString,
                    amount: NSMutableAttributedString(
                        string: "$7.00",
                        attributes: [.font: semiboldFont]
                    )
                )
            ]

        case .cityBucks, .laundry:
            return []
        }
    }
}
