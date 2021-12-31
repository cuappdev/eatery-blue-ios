//
//  WaitTimesSheetViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/25/21.
//

import UIKit

class WaitTimesSheetViewController: SheetViewController {

    // A time formatter without AM/PM in 12-hour time
    private let timeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        dateFormatter.calendar = .eatery
        return dateFormatter
    }()

    typealias WaitTimeData = [(startTime: String, fraction: Double)]

    private let samplePeriod: TimeInterval = 15 * 60

    private var day = Day()
    private var waitTimes: WaitTimes?

    func setUp(_ waitTimes: WaitTimes, day: Day = Day()) {
        self.waitTimes = waitTimes
        self.day = day

        addHeader(title: "Wait Time", image: UIImage(named: "Watch"))
        addStatusLabel("12-15 minutes")
        addTextSection(title: "Wednesday, November 10", description: "11:45 AM - 1:00 PM")
        addWaitTimeView(generateWaitTimeData(waitTimes, day: day))
        setCustomSpacing(24)
        addPillButton(title: "Close", style: .regular) { [self] in
            dismiss(animated: true)
        }
        addTextButton(title: "Report an issue") { [self] in
            let viewController = ReportIssueViewController()
            viewController.setSelectedIssueType(.inaccurateWaitTime)
            present(viewController, animated: true)
        }
    }

    private func addStatusLabel(_ text: String) {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor(named: "EateryBlue")
        label.font = .preferredFont(for: .headline, weight: .semibold)
        stackView.addArrangedSubview(label)
    }

    private func midpointDateOfSample(at index: Int) -> Date {
        startDateOfSample(at: index) + samplePeriod / 2
    }

    private func startDateOfSample(at index: Int) -> Date {
        day.date(hour: 0, minute: 0) + samplePeriod * TimeInterval(index)
    }

    private func sample(at index: Int) -> WaitTimeSample? {
        waitTimes?.sample(at: midpointDateOfSample(at: index))
    }

    private func generateWaitTimeData(_ waitTimes: WaitTimes, day: Day) -> WaitTimeData {
        var data: WaitTimeData = []

        for i in 0..<1000 {
            let sampleMidpoint = midpointDateOfSample(at: i)
            guard Day(date: sampleMidpoint) == day else {
                break
            }

            guard let sample = sample(at: i) else {
                continue
            }

            let sampleStart = startDateOfSample(at: i)
            data.append((
                startTime: timeFormatter.string(from: sampleStart),
                fraction: max(0, min(1, sample.expected / (2 * samplePeriod)))
            ))
        }

        return data
    }

    private func addWaitTimeView(_ data: WaitTimeData) {
        let view = WaitTimeView()
        view.delegate = self

        for datum in data {
            let cell = WaitTimeCell()
            cell.setDatum(startTime: datum.startTime, fraction: datum.fraction)
            view.addCell(cell)
        }

        stackView.addArrangedSubview(view)
    }

}

extension WaitTimesSheetViewController: WaitTimeViewDelegate {

    func waitTimeView(_ sender: WaitTimeView, waitTimeTextForCell cell: WaitTimeCell, atIndex index: Int) -> String {
        guard let sample = sample(at: index) else {
            return "? min"
        }

        let lowMinutes = Int(sample.low / 60)
        let highMinutes = Int(sample.high / 60)
        return "\(lowMinutes)-\(highMinutes) min"
    }

}
