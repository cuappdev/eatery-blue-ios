//
//  UpcomingMenuPickerSheetViewController.swift
//  Eatery Blue
//
//  Created by Tiffany Pan on 9/29/23.
//

import EateryModel
import UIKit

protocol UpcomingMenuPickerSheetViewControllerDelegate: AnyObject {
    func upcomingMenuPickerSheetViewController(
        _ vc: UpcomingMenuPickerSheetViewController,
        didChangeMenuChoice eventType: EventType
    )
}

class UpcomingMenuPickerSheetViewController: SheetViewController {
    weak var delegate: UpcomingMenuPickerSheetViewControllerDelegate?

    private var menuChoices: [EventType] = [.breakfast, .lunch, .dinner, .lateDinner]

    private var menuChoiceViews: [UpcomingMenuChoiceView] = []
    var selectedMenuIndex: Int?

    func setUp(currentEventType: EventType?) {
        selectedMenuIndex = menuChoices.firstIndex(of: currentEventType ?? .breakfast)
        addHeader(title: "Menus")
        addMenuChoiceViews()
        addPillButton(title: "Show menu", style: .prominent) { [self] in
            if let selectedIndex = self.selectedMenuIndex {
                delegate?.upcomingMenuPickerSheetViewController(self, didChangeMenuChoice: menuChoices[selectedIndex])
            }
            dismiss(animated: true)
        }

        addTextButton(title: "Reset") { [self] in
            selectedMenuIndex = nil
            updateMenuChoiceViewsFromState()
        }

        updateMenuChoiceViewsFromState()
    }

    private func addMenuChoiceViews() {
        for i in 0 ..< menuChoices.count {
            if i != 0 {
                stackView.addArrangedSubview(HDivider())
            }

            let menuChoiceView = UpcomingMenuChoiceView()
            menuChoiceView.setup(description: menuChoices[i].description)
            menuChoiceView.layoutMargins = .zero
            stackView.addArrangedSubview(menuChoiceView)
            menuChoiceView.tap { [self] _ in
                didTapMenuChoiceView(at: i)
            }
            menuChoiceViews.append(menuChoiceView)
        }
        updateMenuChoiceViewsFromState()
    }

    private func updateMenuChoiceViewsFromState() {
        for (i, view) in menuChoiceViews.enumerated() {
            if i < menuChoices.count {
                let menuChoice = menuChoices[i]
                view.descriptionLabel.text = menuChoice.description

                if let selectedMenuIndex = selectedMenuIndex, menuChoices[selectedMenuIndex] == menuChoice {
                    view.imageView.image = UIImage(named: "CheckboxFilled")
                } else {
                    view.imageView.image = UIImage(named: "CheckboxUnfilled")
                }

            } else {
                view.descriptionLabel.text = " "
//                view.timeLabel.text = " "
                view.imageView.image = nil
            }
        }
    }

    private func didTapMenuChoiceView(at index: Int) {
        selectedMenuIndex = index
        updateMenuChoiceViewsFromState()
    }
}
