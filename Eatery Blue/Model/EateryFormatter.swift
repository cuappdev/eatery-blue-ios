//
//  EateryFormatter.swift
//  Eatery Blue
//
//  Created by William Ma on 12/30/21.
//

import CoreLocation
import UIKit

class EateryFormatter {

    enum Style {
        case medium
        case long
    }

    static let `default` = EateryFormatter()

    private let timeFormatter = DateFormatter()

    init() {
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        timeFormatter.calendar = .eatery
    }

    func formatStatus(_ status: EateryStatus) -> NSAttributedString {
        switch status {
        case .open(let event):
            let timeString = timeFormatter.string(from: event.endDate)
            return NSAttributedString(
                string: "Open until \(timeString)",
                attributes: [.foregroundColor: UIColor(named: "EateryOrange") as Any]
            )

        case .closed:
            return NSAttributedString(
                string: "Closed",
                attributes: [.foregroundColor: UIColor(named: "EateryRed") as Any]
            )

        case .openingSoon(let event):
            let timeString = timeFormatter.string(from: event.startDate)
            return NSAttributedString(
                string: "Opening at \(timeString)",
                attributes: [.foregroundColor: UIColor(named: "EateryOrange") as Any]
            )

        case .closingSoon(let event):
            let timeString = timeFormatter.string(from: event.endDate)
            return NSAttributedString(
                string: "Closing at \(timeString)",
                attributes: [.foregroundColor: UIColor(named: "EateryOrange") as Any]
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
            return events.map(formatEventTime(_:)).joined(separator: ", ")
        }
    }

    func formatEatery(
        _ eatery: Eatery,
        style: Style,
        font: UIFont,
        userLocation: CLLocation? = nil,
        departureDate: Date = Date()
    ) -> [NSAttributedString] {
        switch style {
        case .medium:
            let text = NSMutableAttributedString()
            text.append(NSAttributedString(attachment: NSTextAttachment(
                image: UIImage(named: "Watch"),
                scaledToMatch: font
            )))
            text.append(NSAttributedString(string: " "))
            text.append(NSAttributedString(string: formatEateryTimeTotal(
                eatery,
                userLocation: userLocation,
                departureDate: departureDate
            )))

            let secondComponent: NSAttributedString?
            if eatery.paymentMethods.contains(.mealSwipes) {
                secondComponent = NSAttributedString(
                    string: "Meal swipes allowed",
                    attributes: [.foregroundColor: UIColor(named: "EateryBlue") as Any]
                )
            } else if eatery.paymentMethods == [.cash, .credit] {
                secondComponent = NSAttributedString(
                    string: "Cash or credit only",
                    attributes: [.foregroundColor: UIColor(named: "EateryGreen") as Any]
                )
            } else if let menuSummary = eatery.menuSummary {
                secondComponent = NSAttributedString(string: menuSummary)
            } else {
                secondComponent = nil
            }

            if let secondComponent = secondComponent {
                text.append(NSAttributedString(string: " · "))
                text.append(secondComponent)
            }

            return [text]

        case .long:
            var lines: [NSAttributedString] = []

            var firstLine: [String] = []
            if let building = eatery.building {
                firstLine.append(building)
            }
            if let menuSummary = eatery.menuSummary {
                firstLine.append(menuSummary)
            }
            if !firstLine.isEmpty {
                let firstLine = firstLine.joined(separator: " · ")
                lines.append(NSAttributedString(string: firstLine))
            }

            let secondLine = NSMutableAttributedString()
            secondLine.append(NSAttributedString(attachment: NSTextAttachment(
                image: UIImage(named: "Watch"),
                scaledToMatch: font
            )))
            secondLine.append(NSAttributedString(string: " "))
            secondLine.append(NSAttributedString(string: formatEateryWalkTime(eatery, userLocation: userLocation)))
            secondLine.append(NSAttributedString(string: " · "))
            secondLine.append(NSAttributedString(string: formatEateryWaitTime(
                eatery,
                font: font,
                userLocation: userLocation,
                departureDate: departureDate
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

        let (walkTime, waitTime) = EateryTiming.timing(
            eatery: eatery,
            userLocation: userLocation,
            departureDate: departureDate
        )

        if let waitTime = waitTime {
            let minutesLow = Int(round((((walkTime ?? 0) + waitTime.low) / 60)))
            let minutesHigh = Int(round(((walkTime ?? 0) + waitTime.high) / 60))

            return "\(minutesLow)-\(minutesHigh) min"

        } else {
            return "-- min"
        }
    }

    func formatEateryWalkTime(_ eatery: Eatery, userLocation: CLLocation?) -> String {
        if let walkTime = EateryTiming.walkTime(eatery: eatery, userLocation: userLocation) {
            let minutes = Int(round(walkTime / 60))
            return "\(minutes) min walk"
        } else {
            return "-- min walk"
        }
    }

    func formatEateryWaitTime(_ eatery: Eatery, font: UIFont, userLocation: CLLocation?, departureDate: Date) -> String {
        let (_, waitTime) = EateryTiming.timing(
            eatery: eatery,
            userLocation: userLocation,
            departureDate: departureDate
        )

        if let waitTime = waitTime {
            let minutesLow = Int(round(waitTime.low / 60))
            let minutesHigh = Int(round(waitTime.high / 60))

            if minutesLow == minutesHigh {
                return "\(minutesLow) min wait"
            } else {
                return "\(minutesLow)-\(minutesHigh) min wait"
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
