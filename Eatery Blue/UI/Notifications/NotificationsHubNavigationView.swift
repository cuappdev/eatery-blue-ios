//
//  NotificationsHubNavigationView.swift
//  Eatery Blue
//
//  Created by Cindy Liang on 2/22/25.
//

import UIKit

class NotificationsHubNavigationView: UIView {

    // MARK: - Properties (View)

    private let backButton = ButtonView(content: UIImageView())
    private let placeholderView = UIView()
    private let titleLabel = UILabel()

    // MARK: - Properties (Data)

    /// The controller that this view uses to pop on back button press
    var navigationController: UINavigationController?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSelf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Set Up

    private func setUpSelf() {
        self.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 4, right: 16)
        backgroundColor = .white

        addSubview(backButton)
        setUpBackButton()
        
        addSubview(titleLabel)
        setUpTitleLabel()


        setUpConstraints()
    }

    private func setUpBackButton() {
        backButton.content.image = UIImage(named: "ArrowLeft")
        backButton.shadowColor = UIColor.Eatery.black
        backButton.shadowOffset = CGSize(width: 0, height: 4)
        backButton.backgroundColor = .white
        backButton.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 16)

        backButton.buttonPress { [weak self] _ in
            guard let self else { return }

            navigationController?.hero.isEnabled = false
            navigationController?.popViewController(animated: true)
        }
    }

    private func setUpTitleLabel() {
        titleLabel.text = "Notifications"
        titleLabel.font = .eateryNavigationBarLargeTitleFont
        titleLabel.textColor = UIColor.Eatery.blue
    }


   

    private func setUpConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(layoutMarginsGuide.snp.leading)
            make.top.equalTo(layoutMarginsGuide.snp.top)
            make.width.height.equalTo(42)
        }

 

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(layoutMarginsGuide.snp.leading).inset(4)
            make.trailing.equalTo(layoutMarginsGuide.snp.trailing)
            make.top.equalTo(backButton.snp.bottom)
            make.height.equalTo(42)
        }
     
    }

}
