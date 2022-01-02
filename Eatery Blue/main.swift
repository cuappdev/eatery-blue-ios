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

    func run() throws {
        if let logLevel = logLevel, let logLevel = Logger.Level(rawValue: logLevel) {
            logger.logLevel = logLevel
            logger.log(level: logLevel, "Set log level to \(logLevel)")
        } else {
            logger.error("Could not parse Logger.Level from \"\(String(describing: logLevel))\"")
        }

        if injectDummyData {
            if let fetchUrl = fetchUrl, let url = URL(string: fetchUrl) {
                let networking = NetworkingDebugger(fetchUrl: url)
                networking.injectDummyData = true
                Networking.default = networking
            }
        } else {
            if let fetchUrl = fetchUrl, let url = URL(string: fetchUrl) {
                Networking.default = Networking(fetchUrl: url)
            }
        }

        AppDelegate.main()
    }

}

extension Networking {

    static var `default`: Networking!

}

EateryBlue.main()
