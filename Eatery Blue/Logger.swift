//
//  Logger.swift
//  Eatery Blue
//
//  Created by William Ma on 1/1/22.
//

import Logging

let logger: Logger = {
    var logger = Logger(label: "com.appdev.Eatery-Blue")
    logger.logLevel = .debug
    return logger
}()
