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
    var locationUrisHall: Bool = false

    func run() throws {
        if let logLevel = logLevel, let logLevel = Logger.Level(rawValue: logLevel) {
            logger.logLevel = logLevel
            logger.log(level: logLevel, "Set log level to \(logLevel)")
        } else {
            logger.error("Could not parse Logger.Level from \"\(String(describing: logLevel))\"")
        }

        if injectDummyData {
            logger.info("\(#function): Injecting dummy data")
            if let fetchUrl = fetchUrl, let url = URL(string: fetchUrl) {
                let networking = DummyNetworking(fetchUrl: url)
                networking.injectDummyData = true
                Networking.default = networking
            }
        } else {
            if let fetchUrl = fetchUrl, let url = URL(string: fetchUrl) {
                Networking.default = Networking(fetchUrl: url)
            }
        }

        if locationUrisHall {
            logger.info("\(#function): Setting location to uris hall")
            LocationManager.shared = DummyLocationManager()
        } else {
            LocationManager.shared = LocationManager()
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
