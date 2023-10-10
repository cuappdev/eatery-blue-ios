//
//  AccountViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/7/22.
//

import UIKit

class AccountViewController: UIViewController {

    struct TransactionItem {
        let title: String
        let time: String
        let date: String
        let amount: NSAttributedString
    }

    struct BalanceItem {
        let title: String
        let subtitle: NSAttributedString
    }

    private let refreshControl = UIRefreshControl()
    private let tableView = UITableView()

    let spinner = UIActivityIndicatorView(style: .large)
    let transactionsHeaderView = AccountTransactionsHeaderView()

    private(set) var balanceItems: [BalanceItem] = []
    private(set) var transactionItems: [TransactionItem] = []

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
        appearance.backgroundColor = UIColor.Eatery.blue
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
        
        view.addSubview(spinner)
        setUpSpinnerView()
    }

    private func setUpTableView() {
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none

        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(didRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl

        tableView.register(AccountBalanceTableViewCell.self, forCellReuseIdentifier: "balance")
        tableView.register(AccountTransactionTableViewCell.self, forCellReuseIdentifier: "transaction")
    }
    
    private func setUpSpinnerView() {
        spinner.hidesWhenStopped = true
    }

    private func setUpConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        spinner.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }

    func updateCells(balances: [BalanceItem], transactions: [TransactionItem]) {
        balanceItems = balances
        transactionItems = transactions
        tableView.reloadData()
    }

    @objc private func didTapSettingsButton() {
        let viewController = SettingsMainMenuModelController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc func didRefresh(_ sender: UIRefreshControl) {
    }

}

extension AccountViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2 + balanceItems.count // First cell is the header, last cell is a large separator
        case 1: return 1 + transactionItems.count // First cell is the header
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
                
            } else if indexPath.row == balanceItems.count + 1 {
                let view = UIView()
                view.backgroundColor = UIColor.Eatery.gray00
                view.snp.makeConstraints { make in
                    make.height.equalTo(16)
                }
                return UITableViewCell(content: view)

            } else {
                let balance = balanceItems[indexPath.row - 1]
                let cell = tableView.dequeueReusableCell(withIdentifier: "balance", for: indexPath) as! AccountBalanceTableViewCell
                cell.titleLabel.text = balance.title
                cell.subtitleLabel.attributedText = balance.subtitle
                return cell
            }

        case 1:
            if indexPath.row == 0 {
                return UITableViewCell(content: transactionsHeaderView)

            } else {
                let transaction = transactionItems[indexPath.row - 1]
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
