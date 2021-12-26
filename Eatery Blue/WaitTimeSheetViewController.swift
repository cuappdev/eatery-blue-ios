//
//  WaitTimeSheetViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/25/21.
//

import UIKit

class WaitTimeSheetViewController: SheetViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpStackView()
    }

    private func setUpStackView() {
        addHeader(title: "Wait Time", image: UIImage(named: "Watch"))
        addStatusLabel("12-15 minutes")
        addTextSection(title: "Wednesday, November 10", description: "11:45 AM - 1:00 PM")
        addWaitTimeView()
        setCustomSpacing(24)
        addPillButton(title: "Close", style: .regular) { [self] in
            dismiss(animated: true)
        }
        addTextButton(title: "Report an issue") {
        }
    }

    private func addStatusLabel(_ text: String) {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor(named: "EateryBlue")
        label.font = .preferredFont(for: .headline, weight: .semibold)
        stackView.addArrangedSubview(label)
    }

    private func addWaitTimeView() {
        let view = WaitTimeView()
        view.delegate = self

        let data = [
            (startTime: "11:30", fraction: Double.random(in: 0...1)),
            (startTime: "11:45", fraction: Double.random(in: 0...1)),
            (startTime: "12:00", fraction: Double.random(in: 0...1)),
            (startTime: "12:15", fraction: Double.random(in: 0...1)),
            (startTime: "12:30", fraction: Double.random(in: 0...1)),
            (startTime: "12:45", fraction: Double.random(in: 0...1)),
            (startTime: "13:00", fraction: Double.random(in: 0...1)),
            (startTime: "13:15", fraction: Double.random(in: 0...1)),
            (startTime: "13:30", fraction: Double.random(in: 0...1)),
            (startTime: "13:45", fraction: Double.random(in: 0...1)),
            (startTime: "14:00", fraction: Double.random(in: 0...1)),
            (startTime: "14:15", fraction: Double.random(in: 0...1)),
            (startTime: "14:30", fraction: Double.random(in: 0...1)),
            (startTime: "14:45", fraction: Double.random(in: 0...1)),
        ]

        for datum in data {
            let cell = WaitTimeCell()
            cell.setDatum(startTime: datum.startTime, fraction: datum.fraction)
            view.addCell(cell)
        }

        stackView.addArrangedSubview(view)
    }

}

extension WaitTimeSheetViewController: WaitTimeViewDelegate {

    func waitTimeView(_ sender: WaitTimeView, waitTimeTextForCell cell: WaitTimeCell, atIndex index: Int) -> String {
        "\(index + 5)-\(index + 8) min"
    }

}
