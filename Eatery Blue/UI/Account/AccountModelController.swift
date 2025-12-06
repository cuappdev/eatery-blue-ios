//
//  AccountModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/7/22.
//

import EateryGetAPI
import EateryModel
import UIKit

// The accounts which are displayed on the profile page in Eatery.
private struct EateryAccounts {
    let mealPlan: Account?
    let bigRedBucks: Account?
    let cityBucks: Account?
    let laundry: Account?

    init(_ accounts: [Account]) {
        mealPlan = accounts.filter {
            $0.accountType.isMealPlan
        }.min(by: { lhs, rhs in
            (lhs.balance ?? .infinity) < (rhs.balance ?? .infinity)
        })

        bigRedBucks = accounts.filter {
            $0.accountType == .bigRedBucks
        }.min(by: { lhs, rhs in
            (lhs.balance ?? .infinity) < (rhs.balance ?? .infinity)
        })

        cityBucks = accounts.filter {
            $0.accountType == .cityBucks
        }.min(by: { lhs, rhs in
            (lhs.balance ?? .infinity) < (rhs.balance ?? .infinity)
        })

        laundry = accounts.filter {
            $0.accountType == .laundry
        }.min(by: { lhs, rhs in
            (lhs.balance ?? .infinity) < (rhs.balance ?? .infinity)
        })
    }

    subscript(accountType: EateryAccountType) -> Account? {
        switch accountType {
        case .mealPlan: return mealPlan
        case .bigRedBucks: return bigRedBucks
        case .cityBucks: return cityBucks
        case .laundry: return laundry
        }
    }
}

private enum EateryAccountType: Int, CustomStringConvertible, CaseIterable {
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
class AccountModelController: AccountViewController {
    enum TimePeriod: CaseIterable {
        case past7Days
        case past30Days
        case past365Days
    }

    private static let priceFormatter: NumberFormatter = {
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        priceFormatter.locale = .eatery
        return priceFormatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = .eatery
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = .eatery
        return formatter
    }()

    private var accounts = EateryAccounts([])
    private var selectedAccount: EateryAccountType = .mealPlan
    private var selectedTimePeriod: TimePeriod = .past30Days

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTransactionsHeaderView()

        updateCellsFromState()
        updateTransactionsHeaderViewFromState()

        Task {
            spinner.startAnimating()
            await updateAccountsFromNetworking()
            updateCellsFromState()
        }
    }

    private func setUpTransactionsHeaderView() {
        transactionsHeaderView.buttonImageView.tap { [self] _ in
            let viewController = AccountPickerSheetViewController()
            viewController.setUpSheetPresentation()
            viewController.setUp(EateryAccountType.allCases.map(\.description))
            viewController.setSelectedAccountIndex(selectedAccount.rawValue)
            viewController.delegate = self
            tabBarController?.present(viewController, animated: true)
        }
    }

    private func updateAccountsFromNetworking() async {
        do {
            let end = Day()

            let start: Day
            switch selectedTimePeriod {
            case .past7Days: start = end.advanced(by: -7)
            case .past30Days: start = end.advanced(by: -30)
            case .past365Days: start = end.advanced(by: -365)
            }

            let accounts = try await Networking.default.accounts.fetch(start: start, end: end)
            let eateryAccounts = EateryAccounts(accounts)
            self.accounts = eateryAccounts

            spinner.stopAnimating()
        } catch {
            logger.error("\(#function): \(error)")
        }
    }

    private func updateCellsFromState() {
        let balances = AccountModelController.getBalanceItems(accounts)
        let transactions = AccountModelController.getTransactionItems(accounts[selectedAccount]?.transactions ?? [])
        updateCells(balances: balances, transactions: transactions)
    }

    private static func getBalanceItems(_ accounts: EateryAccounts) -> [BalanceItem] {
        var items: [BalanceItem] = []

        if let mealPlan = accounts.mealPlan, let balance = mealPlan.balance {
            let remaining = Int(balance)

            let subtitle = NSMutableAttributedString()
            switch mealPlan.accountType {
            case .bearBasic, .bearChoice, .bearTraditional:
                subtitle.append(NSAttributedString(
                    string: "\(remaining)",
                    attributes: [.foregroundColor: UIColor.Eatery.primaryText as Any]
                ))
                subtitle.append(NSAttributedString(
                    string: " remaining this week",
                    attributes: [.foregroundColor: UIColor.Eatery.secondaryText as Any]
                ))

            case .unlimited:
                subtitle.append(NSAttributedString(string: "Unlimited"))

            case .offCampusValue, .flex:
                subtitle.append(NSAttributedString(
                    string: "\(remaining)",
                    attributes: [.foregroundColor: UIColor.Eatery.primaryText as Any]
                ))
                subtitle.append(NSAttributedString(
                    string: " remaining this semester",
                    attributes: [.foregroundColor: UIColor.Eatery.secondaryText as Any]
                ))

            default:
                break
            }

            items.append(BalanceItem(title: "Meal Swipes", subtitle: subtitle))
        } else {
            items.append(BalanceItem(title: "Meal Swipes", subtitle: NSAttributedString()))
        }

        if let brbBalance = accounts.bigRedBucks?.balance {
            let subtitle = NSAttributedString(string: priceFormatter.string(from: NSNumber(value: brbBalance)) ?? "")
            items.append(BalanceItem(title: "Big Red Bucks", subtitle: subtitle))
        } else {
            items.append(BalanceItem(title: "Big Red Bucks", subtitle: NSAttributedString()))
        }

        if let cityBucksBalance = accounts.cityBucks?.balance {
            let subtitle = NSAttributedString(string: priceFormatter
                .string(from: NSNumber(value: cityBucksBalance)) ?? "")
            items.append(BalanceItem(title: "City Bucks", subtitle: subtitle))
        } else {
            items.append(BalanceItem(title: "City Bucks", subtitle: NSAttributedString()))
        }

        if let laundry = accounts.laundry?.balance {
            let subtitle = NSAttributedString(string: priceFormatter.string(from: NSNumber(value: laundry)) ?? "")
            items.append(BalanceItem(title: "Laundry", subtitle: subtitle))
        } else {
            items.append(BalanceItem(title: "Laundry", subtitle: NSAttributedString()))
        }

        return items
    }

    private static func getTransactionItems(_ transactions: [Transaction]) -> [TransactionItem] {
        var items: [TransactionItem] = []

        for transaction in transactions {
            let amount = NSMutableAttributedString()
            if transaction.accountType.isMealPlan {
                amount.append(NSAttributedString(string: "1"))
                amount.append(NSAttributedString(
                    string: " swipe",
                    attributes: [.foregroundColor: UIColor.Eatery.secondaryText as Any]
                ))
            } else {
                amount.append(NSAttributedString(
                    string: priceFormatter.string(from: NSNumber(value: transaction.amount)) ?? ""
                ))
            }

            let cell = TransactionItem(
                title: transaction.location,
                time: timeFormatter.string(from: transaction.date),
                date: dateFormatter.string(from: transaction.date),
                amount: amount
            )
            items.append(cell)
        }

        return items
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

    override func didRefresh(_ sender: UIRefreshControl) {
        super.didRefresh(sender)

        Task {
            await updateAccountsFromNetworking()
            updateCellsFromState()
            sender.endRefreshing()
        }
    }
}

extension AccountModelController: AccountPickerSheetViewControllerDelegate {
    func accountPickerSheetViewController(
        _ viewController: AccountPickerSheetViewController,
        didSelectAccountAt index: Int
    ) {
        if let account = EateryAccountType(rawValue: index) {
            selectedAccount = account
            updateCellsFromState()
            updateTransactionsHeaderViewFromState()
        }

        viewController.dismiss(animated: true)
    }
}
