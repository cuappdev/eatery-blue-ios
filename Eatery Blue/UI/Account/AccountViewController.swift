//
//  AccountViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/7/22.
//

import UIKit

class AccountViewController: UIViewController {

    struct TransactionCell {
        let title: String
        let time: String
        let date: String
        let amount: NSAttributedString
    }

    struct BalanceCell {
        let icon: UIImage?
        let title: String
        let subtitle: NSAttributedString
    }

    let transactionsHeaderView = AccountTransactionsHeaderView()
    private let tableView = UITableView()

    private(set) var balanceCells: [BalanceCell] = []
    private(set) var transactionCells: [TransactionCell] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigation()
        setUpView()
        setUpConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        RootViewController.setStatusBarStyle(.lightContent)
    }

    private func setUpNavigation() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(named: "EateryBlue")
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.eateryNavigationBarTitleFont
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.eateryNavigationBarLargeTitleFont
        ]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.title = "Account"

        let settingsItem = UIBarButtonItem(
            image: UIImage(named: "Settings"),
            style: .plain,
            target: self,
            action: #selector(didTapSettingsButton)
        )
        settingsItem.tintColor = .white
        navigationItem.rightBarButtonItem = settingsItem
    }

    private func setUpView() {
        view.backgroundColor = .white

        view.addSubview(tableView)
        setUpTableView()
    }

    private func setUpTableView() {
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none

        tableView.register(AccountBalanceTableViewCell.self, forCellReuseIdentifier: "balance")
        tableView.register(AccountTransactionTableViewCell.self, forCellReuseIdentifier: "transaction")
    }

    private func setUpConstraints() {
        tableView.edgesToSuperview()
    }

    func updateCells(balances: [BalanceCell], transactions: [TransactionCell]) {
        balanceCells = balances
        transactionCells = transactions
        tableView.reloadData()
    }

    @objc private func didTapSettingsButton() {
        let viewController = SettingsMainMenuModelController()
        navigationController?.pushViewController(viewController, animated: true)
    }

}

extension AccountViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2 + balanceCells.count // First cell is the header, last cell is a large separator
        case 1: return 1 + transactionCells.count // First cell is the header
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let view = ContainerView(content: UILabel())
                view.content.font = .preferredFont(for: .title2, weight: .semibold)
                view.content.text = "Meal Plan"
                view.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
                return UITableViewCell(content: view)
                
            } else if indexPath.row == balanceCells.count + 1 {
                let view = UIView()
                view.backgroundColor = UIColor(named: "Gray00")
                view.height(16)
                return UITableViewCell(content: view)

            } else {
                let balance = balanceCells[indexPath.row - 1]
                let cell = tableView.dequeueReusableCell(withIdentifier: "balance", for: indexPath) as! AccountBalanceTableViewCell
                cell.iconView.image = balance.icon
                cell.titleLabel.text = balance.title
                cell.subtitleLabel.attributedText = balance.subtitle
                return cell
            }

        case 1:
            if indexPath.row == 0 {
                return UITableViewCell(content: transactionsHeaderView)

            } else {
                let transaction = transactionCells[indexPath.row - 1]
                let cell = tableView.dequeueReusableCell(withIdentifier: "transaction", for: indexPath) as! AccountTransactionTableViewCell
                cell.titleLabel.text = transaction.title
                cell.subtitleLabel.text = "\(transaction.time) · \(transaction.date)"
                cell.amountLabel.attributedText = transaction.amount
                return cell
            }

        default:
            return UITableViewCell()
        }
    }

}

extension AccountViewController: UITableViewDelegate {

}
