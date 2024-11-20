//
//  EateryFormatter.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import CoreLocation
import EateryModel
import UIKit

class EateryFormatter {

    enum Style {
        case medium
        case long
    }

    static let `default` = EateryFormatter()

    private let timeFormatter = DateFormatter()
    private let mediumDayMonthFormatter = DateFormatter()
    private let walkTimeMinutesCap = 30
    private let waitTimeMinutesCap = 30

    init() {
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        timeFormatter.calendar = .eatery

        mediumDayMonthFormatter.dateFormat = "MMM d"
        mediumDayMonthFormatter.calendar = .eatery
    }

    func formatStatusSimple(_ status: EateryStatus, followedBy: String) -> NSMutableAttributedString {
        var statusText: String = ""
        var statusColor: UIColor = UIColor.Eatery.gray03

        switch status {
        case .open:
            statusText = "Open"
            statusColor = UIColor.Eatery.green
        case .closed:
            statusText = "Closed"
            statusColor = UIColor.Eatery.red
        case .openingSoon:
            statusText = "Opening Soon"
            statusColor = UIColor.Eatery.orange
        case .closingSoon:
            statusText = "Closing Soon"
            statusColor = UIColor.Eatery.orange
        }

        let mainString = "\(statusText) · \(followedBy)"
        let range = (mainString as NSString).range(of: statusText)
        let mutableAttributedString = NSMutableAttributedString.init(string: mainString)
        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: statusColor, range: range)
        return mutableAttributedString
    }

    func formatStatus(_ status: EateryStatus) -> NSAttributedString {
        switch status {
        case .open(let event):
            let timeString = timeFormatter.string(from: event.endDate)
            return NSAttributedString(
                string: "Open until \(timeString)",
                attributes: [.foregroundColor: UIColor.Eatery.green as Any]
            )

        case .closed:
            return NSAttributedString(
                string: "Closed",
                attributes: [.foregroundColor: UIColor.Eatery.red as Any]
            )

        case .openingSoon(let event):
            let timeString = timeFormatter.string(from: event.startDate)
            return NSAttributedString(
                string: "Opening at \(timeString)",
                attributes: [.foregroundColor: UIColor.Eatery.orange as Any]
            )

        case .closingSoon(let event):
            let timeString = timeFormatter.string(from: event.endDate)
            return NSAttributedString(
                string: "Closing at \(timeString)",
                attributes: [.foregroundColor: UIColor.Eatery.orange as Any]
            )

        }
    }

    func formatTime(_ date: Date) -> String {
        timeFormatter.string(from: date)
    }

    func formatEventTime(_ event: Event) -> String {
        "\(timeFormatter.string(from: event.startDate)) - \(timeFormatter.string(from: event.endDate))"
    }

    func formatEventTimes(_ events: [Event]) -> String {
        if events.isEmpty {
            return "Closed"
        } else {
            return events.map(formatEventTime(_:)).joined(separator: "\n")
        }
    }
    
    func eateryCardFormatter(_ eatery: Eatery, date: Date) -> NSAttributedString? {
        let day = Day(date: date)
        if eatery.isOpen {
            switch eatery.status {
            case .closingSoon(let event):
                return NSAttributedString(
                    string: "Open until \(timeFormatter.string(from: event.endDate))",
                    attributes: [.foregroundColor: UIColor.Eatery.orange as Any]
                )
            case .open(let event):
                return NSAttributedString(
                    string: "Open until \(timeFormatter.string(from: event.endDate))",
                    attributes: [.foregroundColor: UIColor.Eatery.green as Any]
                )
            default:
                return NSAttributedString(
                    string: "Open",
                    attributes: [.foregroundColor: UIColor.Eatery.green as Any]
                )
            }
        } else {
            if let nextEventOfDay = EateryStatus.nextEvent(eatery.events, date: date, on: day) {
                if let _ = EateryStatus.previousEvent(eatery.events, date: date, on: day) {
                    return NSAttributedString(
                        string: "Re-opens at \(timeFormatter.string(from: nextEventOfDay.startDate))",
                        attributes: [.foregroundColor: UIColor.Eatery.orange as Any]
                    )
                } else {
                    return NSAttributedString(
                        string: "Opens at \(timeFormatter.string(from: nextEventOfDay.startDate))",
                        attributes: [.foregroundColor: UIColor.Eatery.orange as Any]
                    )
                }
            } else if let nextEventOfNextDay = EateryStatus.nextEvent(eatery.events, date: date, on: day.advanced(by: 1)) {
                return NSAttributedString(
                    string: "Closed until \(timeFormatter.string(from: nextEventOfNextDay.startDate))",
                    attributes: [.foregroundColor: UIColor.Eatery.red as Any]
                )
            } else if let nextEvent = EateryStatus.nextEvent(eatery.events, date: date) {
                return NSAttributedString(
                    string: "Closed until \(mediumDayMonthFormatter.string(from: nextEvent.startDate))",
                    attributes: [.foregroundColor: UIColor.Eatery.red as Any]
                )
            } else {
                return NSAttributedString(
                    string: "Closed today",
                    attributes: [.foregroundColor: UIColor.Eatery.red as Any]
                )
            }
        }
    }

    private func firstLineSecondComponent(_ eatery: Eatery, date: Date) -> NSAttributedString? {
        let day = Day(date: date)
        if eatery.isOpen {
            if eatery.paymentMethods.contains(.mealSwipes) {
                return NSAttributedString(
                    string: "Meal swipes allowed",
                    attributes: [.foregroundColor: UIColor.Eatery.blue as Any]
                )
            } else if eatery.paymentMethods == [.cash, .credit] {
                return NSAttributedString(
                    string: "Cash or credit only",
                    attributes: [.foregroundColor: UIColor.Eatery.green as Any]
                )
            } else if let menuSummary = eatery.menuSummary {
                return NSAttributedString(string: menuSummary)
            } else {
                return nil
            }
        } else if let nextEventOfNextDay = EateryStatus.nextEvent(eatery.events, date: date, on: day.advanced(by: 1)) {
            return NSAttributedString(
                string: "Closed until \(timeFormatter.string(from: nextEventOfNextDay.startDate))",
                attributes: [.foregroundColor: UIColor.Eatery.red as Any]
            )
        } else if let nextEvent = EateryStatus.nextEvent(eatery.events, date: date) {
            return NSAttributedString(
                string: "Closed until \(mediumDayMonthFormatter.string(from: nextEvent.startDate))",
                attributes: [.foregroundColor: UIColor.Eatery.red as Any]
            )
        } else {
            return NSAttributedString(
                string: "Closed today",
                attributes: [.foregroundColor: UIColor.Eatery.red as Any]
            )
        }
    }

    func formatEatery(
        _ eatery: Eatery,
        style: Style,
        font: UIFont,
        userLocation: CLLocation? = nil,
        date: Date = Date()
    ) -> [NSAttributedString] {
        switch style {
        case .medium:
            let text = NSMutableAttributedString()
            text.append(NSAttributedString(attachment: NSTextAttachment(
                image: UIImage(named: "Walk"),
                scaledToMatch: font
            )))
            text.append(NSAttributedString(string: " "))
            text.append(NSAttributedString(string: formatEateryWalkTime(eatery, userLocation: userLocation, isLong: false)))

            if let secondComponent = eateryCardFormatter(eatery, date: date) {
                text.append(NSAttributedString(string: " · "))
                text.append(secondComponent)
            }

            return [text]

        case .long:
            var lines: [NSAttributedString] = []

            var firstLineComponents: [NSAttributedString] = []
            if let locationDescription = eatery.locationDescription {
                firstLineComponents.append(NSAttributedString(
                    string: locationDescription
                ))
            }
            if let firstLineSecondComponent = firstLineSecondComponent(eatery, date: date) {
                firstLineComponents.append(firstLineSecondComponent)
            }

            if !firstLineComponents.isEmpty {
                let firstLine = NSMutableAttributedString()
                for (i, component) in firstLineComponents.enumerated() {
                    if i != 0 {
                        firstLine.append(NSAttributedString(string: " · "))
                    }
                    firstLine.append(component)
                }
                lines.append(firstLine)
            }

            let secondLine = NSMutableAttributedString()
            secondLine.append(NSAttributedString(attachment: NSTextAttachment(
                image: UIImage(named: "Walk"),
                scaledToMatch: font
            )))
            secondLine.append(NSAttributedString(string: " "))
            secondLine.append(NSAttributedString(string: formatEateryWalkTime(eatery, userLocation: userLocation)))
            secondLine.append(NSAttributedString(string: " · "))
            secondLine.append(NSAttributedString(attachment: NSTextAttachment(
                image: UIImage(named: "Clock"),
                scaledToMatch: font
            )))
            secondLine.append(NSAttributedString(string: " "))
            
            // TODO: Temporarily removed wait times.
            secondLine.append(NSAttributedString(string: formatEateryWaitTime(
                eatery,
                font: font,
                userLocation: userLocation,
                departureDate: date
            )))
            lines.append(secondLine)

            return lines

        }
    }

    func formatEateryTimeTotal(
        _ eatery: Eatery,
        userLocation: CLLocation?,
        departureDate: Date
    ) -> String {
        let (walkTime, waitTime) = eatery.timingInfo(userLocation: userLocation, departureDate: departureDate)

        if let waitTime = waitTime {
            let minutesLow = Int(round((((walkTime ?? 0) + waitTime.low) / 60)))
            let minutesHigh = Int(round(((walkTime ?? 0) + waitTime.high) / 60))

            if minutesLow > walkTimeMinutesCap + waitTimeMinutesCap {
                return ">\(walkTimeMinutesCap + waitTimeMinutesCap) min"
            } else {
                return minutesLow < minutesHigh ? "\(minutesLow)-\(minutesHigh) min" : "\(minutesLow) min"
            }

        } else if let walkTime = walkTime {
            let minutes = Int(round(walkTime / 60))
            if minutes > walkTimeMinutesCap {
                return ">\(walkTimeMinutesCap) min"
            } else {
                return "\(minutes) min"
            }

        } else {
            return "-- min"
        }
    }

    func formatEateryWalkTime(_ eatery: Eatery, userLocation: CLLocation?, isLong: Bool = true) -> String {
        let detail = isLong ? " walk" : ""
        if let walkTime = eatery.walkTime(userLocation: userLocation) {
            let minutes = Int(round(walkTime / 60))
            if minutes > walkTimeMinutesCap {
                return ">\(walkTimeMinutesCap) min\(detail)"
            } else {
                return "\(minutes) min\(detail)"
            }

        } else {
            return "-- min\(detail)"
        }
    }

    func formatEateryWaitTime(_ eatery: Eatery, font: UIFont, userLocation: CLLocation?, departureDate: Date) -> String {
        let (_, waitTime) = eatery.timingInfo(userLocation: userLocation, departureDate: departureDate)

        if let waitTime = waitTime {
            let minutesLow = Int(round(waitTime.low / 60))
            let minutesHigh = Int(round(waitTime.high / 60))
            let avgMinutes = Int((minutesLow+minutesHigh) / 2)

            if minutesLow > walkTimeMinutesCap + waitTimeMinutesCap {
                return ">\(walkTimeMinutesCap + waitTimeMinutesCap) min wait"
            } else {
                return "\(avgMinutes) min wait"
            }

        } else {
            return "-- min wait"
        }
    }

    func formatPaymentMethod(_ paymentMethod: PaymentMethod) -> String {
        switch paymentMethod {
        case .mealSwipes: return "Meal swipes"
        case .brbs: return "BRBs"
        case .cash: return "Cash"
        case .credit: return "Credit"
        }
    }

    func formatPaymentMethods(_ paymentMethods: Set<PaymentMethod>) -> String {
        var components: [String] = []

        if paymentMethods.contains(.mealSwipes) {
            components.append("Meal swipes")
        }
        if paymentMethods.contains(.brbs) {
            components.append("BRBs")
        }
        if paymentMethods.contains(.cash) {
            components.append("Cash")
        }
        if paymentMethods.contains(.credit) {
            components.append("Credit")
        }

        return components.joined(separator: ", ")
    }

}
