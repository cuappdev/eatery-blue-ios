//
//  StayLoggedInSheet.swift
//  Eatery Blue
//
//  Created by Jayson Hahn on 11/7/23.
//

import UIKit

protocol AttemptLogin: AnyObject {
    func attemptLogin()
}

class StayLoggedInSheet: SheetViewController {
    private let descriptionLabel = UILabel()
    private var delegate: AttemptLogin?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpStackView()
    }

    private let desc = """
        Due to updated Cornell security policies users are automatically logged out of their account after 24 hours.
        """
    private let instruction = "Log back in to see your current total BRBs, Meal Swipes, City Bucks and Laundry."

    private func setUpStackView() {
        stackView.spacing = 16
        addHeader(title: "Log Back In?")
        addText(text: desc, weight: .regular, color: .black)
        addText(text: instruction, weight: .bold, color: UIColor.Eatery.gray06)
        addPillButton(
            title: "Log in",
            style: .prominent,
            action: { self.dismiss(animated: true, completion: { self.delegate?.attemptLogin() }) }
        )
        addTextButton(title: "Stay logged out", action: { self.dismiss(animated: true) })
    }

    func setUp(delegate: AttemptLogin) {
        self.delegate = delegate
    }

    private func addText(text: String, weight: UIFont.Weight, color: UIColor) {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: weight)
        label.text = text
        label.textColor = color
        label.numberOfLines = 0
        label.textAlignment = .center
        stackView.addArrangedSubview(label)
    }
}
