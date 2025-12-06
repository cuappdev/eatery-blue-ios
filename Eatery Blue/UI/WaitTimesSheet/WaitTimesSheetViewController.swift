//
//  WaitTimesSheetViewController.swift
//  Eatery Blue
//
//  Created by William Ma on 12/25/21.
//

import EateryModel
import UIKit

class WaitTimesSheetViewController: SheetViewController {
    private let dayFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        return dateFormatter
    }()

    private let shortTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        dateFormatter.calendar = .eatery
        return dateFormatter
    }()

    // A time formatter without AM/PM in 12-hour time
    private let tinyTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        dateFormatter.calendar = .eatery
        return dateFormatter
    }()

    typealias WaitTimeData = [(startTime: String, fraction: Double)]

    private let samplePeriod: TimeInterval = 15 * 60

    private var day = Day()
    private var waitTimes: WaitTimes?
    private var events: [Event] = []

    private let waitTimeLabel = UILabel()
    private let dayLabel = UILabel()
    private let visibleTimesLabel = UILabel()
    private let waitTimesView = WaitTimesView()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Compute layout so the waitTimesView is able to accurately scroll cell to center
        view.layoutIfNeeded()

        let index = index(closesTo: Date())
        waitTimesView.highlightCell(at: index)
        waitTimesView.scrollCellToCenter(at: index, animated: false)
        updateWaitTimeLabel()
    }

    func setUp(_ eateryId: Int64, _ waitTimes: WaitTimes, events: [Event], day: Day = Day()) {
        self.waitTimes = waitTimes
        self.day = day
        self.events = events

        addHeader(title: "Wait Time", image: UIImage(named: "Watch"))
        setUpWaitTimeLabel()
        setUpDayLabel()
        setCustomSpacing(4)
        setUpVisibleTimesLabel()
        setUpWaitTimesView(generateWaitTimeData(waitTimes, events: events, day: day))
        setCustomSpacing(24)
        addPillButton(title: "Close", style: .regular) { [self] in
            dismiss(animated: true)
        }
        addTextButton(title: "Report an issue") { [self] in
            let viewController = ReportIssueViewController(eateryId: eateryId)
            viewController.setSelectedIssueType(.inaccurateWaitTime)
            tabBarController?.present(viewController, animated: true)
        }
    }

    private func setUpWaitTimeLabel() {
        waitTimeLabel.textColor = UIColor.Eatery.blue
        waitTimeLabel.font = .preferredFont(for: .headline, weight: .semibold)
        stackView.addArrangedSubview(waitTimeLabel)
    }

    private func setUpDayLabel() {
        dayLabel.text = dayFormatter.string(from: day.date())
        dayLabel.textColor = UIColor.Eatery.secondaryText
        dayLabel.font = .preferredFont(for: .subheadline, weight: .medium)
        stackView.addArrangedSubview(dayLabel)
    }

    private func setUpVisibleTimesLabel() {
        visibleTimesLabel.textColor = UIColor.Eatery.primaryText
        visibleTimesLabel.font = .preferredFont(for: .body, weight: .semibold)
        visibleTimesLabel.numberOfLines = 0
        stackView.addArrangedSubview(visibleTimesLabel)
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

    private func index(closesTo date: Date) -> Int {
        let timeSinceStartOfDay = date.timeIntervalSince(Day(date: date).date())
        return Int(timeSinceStartOfDay / samplePeriod)
    }

    private func generateWaitTimeData(_: WaitTimes, events: [Event], day: Day) -> WaitTimeData {
        var data: WaitTimeData = []

        for i in 0 ..< 1000 {
            let sampleMidpoint = midpointDateOfSample(at: i)
            guard Day(date: sampleMidpoint) == day else {
                break
            }

            let sampleStart = startDateOfSample(at: i)

            if !EateryStatus(events, date: sampleMidpoint).isOpen {
                // If the eatery is closed, display zero height bar
                data.append((
                    startTime: tinyTimeFormatter.string(from: sampleStart),
                    fraction: 0
                ))

            } else if let sample = sample(at: i) {
                // Otherwise, display the sample
                data.append((
                    startTime: tinyTimeFormatter.string(from: sampleStart),
                    fraction: max(0, min(1, sample.expected / (2 * samplePeriod)))
                ))
            }
        }

        return data
    }

    private func setUpWaitTimesView(_ data: WaitTimeData) {
        waitTimesView.delegate = self

        for datum in data {
            let cell = WaitTimeCell()
            cell.setDatum(startTime: datum.startTime, fraction: datum.fraction)
            waitTimesView.addCell(cell)
        }

        stackView.addArrangedSubview(waitTimesView)
    }

    private func updateWaitTimeLabel() {
        guard let highlightedIndex = waitTimesView.highlightedIndex,
              let sample = sample(at: highlightedIndex)
        else {
            return
        }

        let low = Int(round(sample.low / 60))
        let high = Int(round(sample.high / 60))
        waitTimeLabel.text = low < high ? "\(low)-\(high) minutes" : "\(low) minutes"
    }
}

extension WaitTimesSheetViewController: WaitTimeViewDelegate {
    func waitTimesView(_: WaitTimesView, waitTimeTextForCell _: WaitTimeCell, atIndex index: Int) -> String {
        guard let sample = sample(at: index) else {
            return "? min"
        }

        let lowMinutes = Int(round(sample.low / 60))
        let highMinutes = Int(round(sample.high / 60))
        return lowMinutes < highMinutes ? "\(lowMinutes)-\(highMinutes) min" : "\(lowMinutes) min"
    }

    func waitTimesViewDidScroll(_ sender: WaitTimesView) {
        let visibleRange = sender.visibleCellIndexes().prefix(5)
        guard let lower = visibleRange.min(), let upper = visibleRange.max() else {
            return
        }

        let lowerDate = startDateOfSample(at: lower)
        let upperDate = startDateOfSample(at: upper + 1)
        let lowerDateString = shortTimeFormatter.string(from: lowerDate)
        let upperDateString = shortTimeFormatter.string(from: upperDate)

        visibleTimesLabel.text = "\(lowerDateString) - \(upperDateString)"
    }

    func waitTimesView(_: WaitTimesView, shouldHighlightCell _: WaitTimeCell, atIndex i: Int) -> Bool {
        EateryStatus(events, date: midpointDateOfSample(at: i)).isOpen
    }

    func waitTimesView(_: WaitTimesView, didHighlightCell _: WaitTimeCell, atIndex _: Int) {
        updateWaitTimeLabel()
    }
}
