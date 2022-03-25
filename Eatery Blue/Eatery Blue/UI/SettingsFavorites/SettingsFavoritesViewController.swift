//
//  SettingsFavoritesViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/24/22.
//

import Combine
import EateryModel
import UIKit

@MainActor
class SettingsFavoritesViewController: UIViewController {

    private let tableView = UITableView()

    private var favoriteEateries: [Eatery] = []

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationItem()
        setUpView()
        setUpConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        RootViewController.setStatusBarStyle(.darkContent)
    }

    private func setUpNavigationItem() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(named: "Black") as Any,
            .font: UIFont.eateryNavigationBarTitleFont
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(named: "EateryBlue") as Any,
            .font: UIFont.eateryNavigationBarLargeTitleFont
        ]

        navigationItem.title = "Favorites"

        let standardAppearance = appearance.copy()
        standardAppearance.configureWithDefaultBackground()
        navigationItem.standardAppearance = standardAppearance

        let scrollEdgeAppearance = appearance.copy()
        scrollEdgeAppearance.configureWithTransparentBackground()
        navigationItem.scrollEdgeAppearance = scrollEdgeAppearance

        let backButton = UIBarButtonItem(
            image: UIImage(named: "ArrowLeft"),
            style: .plain,
            target: self,
            action: #selector(didTapBackButton)
        )
        backButton.tintColor = UIColor(named: "Black")
        navigationItem.leftBarButtonItem = backButton
    }

    private func setUpView() {
        view.backgroundColor = .white

        view.addSubview(tableView)
        setUpTableView()
    }

    private func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }

    private func setUpConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

    func updateFavoriteEateries(_ eateries: [Eatery]) {
        favoriteEateries = eateries
        tableView.reloadData()
    }

}

extension SettingsFavoritesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // First cell is the header
        1 + favoriteEateries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let label = UILabel()
            label.text = "Manage your favorite eateries"

            let container = ContainerView(content: label)
            container.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

            let cell = UITableViewCell(content: container)
            cell.selectionStyle = .none
            return cell

        } else {
            let eatery = favoriteEateries[indexPath.row - 1]

            let contentView = EateryLargeCardContentView()
            contentView.imageView.kf.setImage(
                with: eatery.imageUrl,
                options: [
                    .backgroundDecode
                ]
            )
            contentView.imageTintView.alpha = eatery.isOpen ? 0 : 0.5
            contentView.titleLabel.text = eatery.name

            let metadata = AppDelegate.shared.coreDataStack.metadata(eateryId: eatery.id)
            contentView.setFavoriteImage(metadata.isFavorite)

            LocationManager.shared.$userLocation
                .sink { userLocation in
                    let lines = EateryFormatter.default.formatEatery(
                        eatery,
                        style: .long,
                        font: .preferredFont(for: .footnote, weight: .medium),
                        userLocation: userLocation,
                        date: Date()
                    )

                    for (i, subtitleLabel) in contentView.subtitleLabels.enumerated() {
                        if i < lines.count {
                            subtitleLabel.attributedText = lines[i]
                        } else {
                            subtitleLabel.isHidden = true
                        }
                    }
                }
                .store(in: &cancellables)

            let cardView = EateryCardVisualEffectView(content: contentView)
            cardView.layoutMargins = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)

            let cell = ClearTableViewCell(content: cardView)
            cell.selectionStyle = .none
            return cell
        }
    }

}

extension SettingsFavoritesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            let cell = tableView.cellForRow(at: indexPath)
            UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
                cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        }
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            let cell = tableView.cellForRow(at: indexPath)
            UIView.animate(withDuration: 0.15, delay: 0, options: .beginFromCurrentState) {
                cell?.transform = .identity
            }
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            let eatery = favoriteEateries[indexPath.row - 1]
            let viewController = EateryModelController()
            viewController.setUp(eatery: eatery)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

}

