//
//  RootModelController.swift
//  Eatery Blue
//
//  Created by William Ma on 1/4/22.
//

import UIKit

class RootModelController: RootViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setMode(.splash)

        if UserDefaults.standard.bool(forKey: "didOnboard") {
            transitionTo(.main)
        } else {
            transitionTo(.onboarding)
        }
    }

}
