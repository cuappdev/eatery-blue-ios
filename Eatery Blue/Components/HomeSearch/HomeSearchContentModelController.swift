//
//  HomeSearchContentModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/1/22.
//

import UIKit

class HomeSearchContentModelController: HomeSearchContentViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        cells = [
            .eatery(DummyData.macs),
            .item(
                MenuItem(
                    healthy: false,
                    name: "Deli",
                    description: "A classic sub made with your choice of bread, proten, and toppings.",
                    price: 850
                ),
                DummyData.macs
            ),
            .eatery(DummyData.macs),
            .eatery(DummyData.macs),
            .eatery(DummyData.macs),
            .item(
                MenuItem(
                    healthy: false,
                    name: "Deli",
                    description: "A classic sub made with your choice of bread, proten, and toppings.",
                    price: 850
                ),
                DummyData.macs
            ),
            .eatery(DummyData.macs),
            .eatery(DummyData.macs),
            .item(
                MenuItem(
                    healthy: false,
                    name: "Deli",
                    description: "A classic sub made with your choice of bread, proten, and toppings.",
                    price: 850
                ),
                DummyData.macs
            ),
        ]
    }

}
