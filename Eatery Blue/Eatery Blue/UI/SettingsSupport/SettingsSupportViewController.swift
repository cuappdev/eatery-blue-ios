//
//  SettingsSupportViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/26/22.
//

import Combine
import SwiftUI
import UIKit

class SettingsSupportViewController: UIViewController {

    private lazy var hostingController: UIHostingController<SettingsSupportView> = {
        let hostingController = UIHostingController(rootView: SettingsSupportView())
        return hostingController
    }()

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

        navigationItem.title = "Support"

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
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        hostingController.rootView.delegate = self
    }

    private func setUpConstraints() {
        hostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

}

extension SettingsSupportViewController: SettingsSupportViewDelegate {

    func openReportIssue(preselectedIssueType: ReportIssueViewController.IssueType?) {
        let viewController = ReportIssueViewController()
        if let issueType = preselectedIssueType {
            viewController.setSelectedIssueType(issueType)
        }
        present(viewController, animated: true)
    }

}
