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

    var onShowBarcode: (() -> Void)?

    private(set) var balanceItems: [BalanceItem] = []
    private(set) var transactionItems: [TransactionItem] = []

    private let barcodeHeaderView = UIView()
    private let showBarcodeButton = ButtonView(pillContent: UILabel())
    private let barcodeHintLabel = UILabel()
    private var isBarcodeHeaderInstalled = false

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

    func setUpNavigation() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.Eatery.blue
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.Eatery.default00,
            .font: UIFont.eateryNavigationBarTitleFont
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.Eatery.default00,
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
        settingsItem.tintColor = UIColor.Eatery.default00
        navigationItem.rightBarButtonItem = settingsItem
    }

    private func setUpView() {
        view.backgroundColor = UIColor.Eatery.default00

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

        refreshControl.tintColor = UIColor.Eatery.default00
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

    // Only the logged-in Account screen calls this.
    func setUpBarcodeEntry() {
        let titleLabel = showBarcodeButton.content
        titleLabel.font = .preferredFont(for: .body, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.text = "Show barcode"
        titleLabel.textColor = UIColor.Eatery.default00

        showBarcodeButton.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        showBarcodeButton.cornerRadiusView.backgroundColor = UIColor.Eatery.blue
        showBarcodeButton.buttonPress { [weak self] _ in
            self?.onShowBarcode?()
        }

        barcodeHintLabel.font = .preferredFont(forTextStyle: .footnote)
        barcodeHintLabel.textColor = UIColor.Eatery.secondaryText
        barcodeHintLabel.numberOfLines = 0
        barcodeHintLabel.isHidden = true

        let stack = UIStackView(arrangedSubviews: [showBarcodeButton, barcodeHintLabel])
        stack.axis = .vertical
        stack.spacing = 8

        barcodeHeaderView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 4, right: 16))
        }

        isBarcodeHeaderInstalled = true
        tableView.tableHeaderView = barcodeHeaderView
        layoutBarcodeHeader()
    }

    func updateBarcodeEntry(isEnabled: Bool, hint: String?) {
        showBarcodeButton.isUserInteractionEnabled = isEnabled
        showBarcodeButton.alpha = isEnabled ? 1 : 0.4
        barcodeHintLabel.text = hint
        barcodeHintLabel.isHidden = hint == nil || hint?.isEmpty == true
        layoutBarcodeHeader()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isBarcodeHeaderInstalled {
            layoutBarcodeHeader()
        }
    }

    private func layoutBarcodeHeader() {
        let width = tableView.bounds.width > 0 ? tableView.bounds.width : view.bounds.width
        guard width > 0 else {
            return
        }

        let size = barcodeHeaderView.systemLayoutSizeFitting(
            CGSize(width: width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        let frame = CGRect(x: 0, y: 0, width: width, height: size.height)
        if barcodeHeaderView.frame != frame {
            barcodeHeaderView.frame = frame
            tableView.tableHeaderView = barcodeHeaderView
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

    @objc func didRefresh(_: UIRefreshControl) {}
}

extension AccountViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        2
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
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
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "balance", for: indexPath)
                    as? AccountBalanceTableViewCell else { return UITableViewCell() }
                cell.titleLabel.text = balance.title
                cell.subtitleLabel.attributedText = balance.subtitle
                return cell
            }

        case 1:
            if indexPath.row == 0 {
                return UITableViewCell(content: transactionsHeaderView)

            } else {
                let transaction = transactionItems[indexPath.row - 1]
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "transaction", for: indexPath)
                    as? AccountTransactionTableViewCell else { return UITableViewCell() }

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

extension AccountViewController: UITableViewDelegate {}
