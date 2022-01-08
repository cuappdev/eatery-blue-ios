//
//  main.swift
//  Eatery Blue
//
//  Created by William Ma on 1/2/22.
//

import ArgumentParser
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
    var delayNetworkRequests: Bool = false

    @Flag
    var locationUrisHall: Bool = false

    @Flag
    var forceOnboarding: Bool = false

    @Option
    var networkingLogLevel: String?

    @Flag
    var forceDeleteCredentials: Bool = false

    func run() throws {
        if let logLevel = logLevel {
            if let logLevel = Logger.Level(rawValue: logLevel) {
                logger.logLevel = logLevel
                logger.log(level: logLevel, "Set log level to \(logLevel)")
            } else {
                logger.error("Could not parse Logger.Level from \"\(String(describing: logLevel))\"")
            }
        }

        if let getLogLevel = networkingLogLevel {
            if let logLevel = Logger.Level(rawValue: getLogLevel) {
                Networking.logger.logLevel = logLevel
                Networking.logger.log(level: logLevel, "Set log level to \(logLevel)")
            } else {
                Networking.logger.error("Could not parse Logger.Level from \"\(String(describing: getLogLevel))\"")
            }
        }

        let url = URL(string: fetchUrl!)!
        Networking.default = Networking(fetchUrl: url)

        if locationUrisHall {
            logger.info("\(#function): Setting location to uris hall")
            LocationManager.shared = DummyLocationManager()
        } else {
            LocationManager.shared = LocationManager()
        }

        if forceOnboarding {
            logger.info("\(#function): Force onboarding")
            UserDefaults.standard.set(false, forKey: "didOnboard")
        }

        if forceDeleteCredentials {
            logger.info("\(#function): Deleting credentials")
            try! KeychainManager.shared.delete()
        }

        AppDelegate.main()
    }

}

extension Networking {

    static var `default`: Networking!

}

extension LocationManager {

    static var shared: LocationManager!

}

EateryBlue.main()
