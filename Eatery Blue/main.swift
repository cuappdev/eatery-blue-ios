//
//  main.swift
//  Eatery Blue
//
//  Created by William Ma on 1/2/22.
//

import ArgumentParser
import EateryModel
import EateryGetAPI
import Foundation
import Logging

var logger = Logger(label: "com.appdev.Eatery-Blue")

struct EateryBlue: ParsableCommand {

    @Option
    var logLevel: String?

    @Option
    var fetchUrl: String?

    @Flag
    var injectDummyData: Bool = false

    @Flag
    var locationUrisHall: Bool = false

    @Flag
    var forceOnboarding: Bool = false

    @Flag
    var forceDeleteCredentials: Bool = false

    func run() throws {
        if let logLevel = logLevel {
            if let logLevel = Logger.Level(rawValue: logLevel) {
                logger.logLevel = logLevel
                EateryModel.logger.logLevel = logLevel
                EateryGetAPI.logger.logLevel = logLevel
                logger.log(level: logLevel, "Set log level to \(logLevel)")

            } else {
                logger.error("Could not parse Logger.Level from \"\(String(describing: logLevel))\"")
            }
        }

        if let fetchUrl = fetchUrl, let fetchUrl = URL(string: fetchUrl) {
            Networking.default = Networking(fetchUrl: fetchUrl)
        }

        if locationUrisHall {
            logger.info("\(#function): Setting location to uris hall")
            LocationManager.shared = DummyLocationManager()
        }

        if forceOnboarding {
            logger.info("\(#function): Force onboarding")
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.didOnboard)
        }

        if forceDeleteCredentials {
            logger.info("\(#function): Deleting credentials")
            try! NetIDKeychainManager.shared.delete()
        }

        AppDelegate.main()
    }
}

extension Networking {

    static var `default` = Networking(fetchUrl: URL(string: "\(EateryEnvironment.baseURL)/eatery/")!)

}

extension LocationManager {

    static var shared = LocationManager()

}

EateryBlue.main()
