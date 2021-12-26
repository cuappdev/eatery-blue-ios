//
//  HoursSheetViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/25/21.
//

import UIKit

class HoursSheetViewController: SheetViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpStackView()
    }

    private func setUpStackView() {
        addHeader(title: "Hours", image: UIImage(named: "Clock"))
        addStatusLabel(text: "Open until 5:30 PM", color: UIColor(named: "EateryGreen"))
        addTextSection(title: "Sunday", description: "Closed")
        addTextSection(title: "Monday to Friday", description: "9:30 AM - 5:30 PM")
        addTextSection(title: "Saturday", description: "Closed")
        setCustomSpacing(24)
        addPillButton(title: "Close", style: .regular) { [self] in
            dismiss(animated: true)
        }
        addTextButton(title: "Report an issue") {
        }
    }

    private func addStatusLabel(text: String, color: UIColor?) {
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.font = .preferredFont(for: .body, weight: .semibold)
        stackView.addArrangedSubview(label)
    }

}
