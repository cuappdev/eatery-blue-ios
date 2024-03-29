//
//  EateryEnvironment.swift
//  Eatery Blue
//
//  Created by Vin Bui on 1/28/24.
//

import Foundation

/// Data from Info.plist stored as environment variables.
enum EateryEnvironment {

    /// Keys from Info.plist.
    enum Keys {
#if DEBUG
        static let baseURL: String = "EATERY_DEV_URL"
#else
        static let baseURL: String = "EATERY_PROD_URL"
#endif
        static let announcementsCommonPath = "ANNOUNCEMENTS_COMMON_PATH"
        static let announcementsHost = "ANNOUNCEMENTS_HOST"
        static let announcementsPath = "ANNOUNCEMENTS_PATH"
        static let announcementsScheme = "ANNOUNCEMENTS_SCHEME"
    }

    /// A dictionary storing key-value pairs from Info.plist.
    private static let infoDict: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Info.plist not found")
        }
        return dict
    }()

    /**
     The base URL of Eatery's backend server.

     * If the scheme is set to DEBUG, the development server URL is used.
     * If the scheme is set to RELEASE, the production server URL is used.
     */
    static let baseURL: String = {
        guard let baseURLString = EateryEnvironment.infoDict[Keys.baseURL] as? String else {
#if DEBUG
            fatalError("EATERY_DEV_URL not found in Info.plist")
#else
            fatalError("EATERY_PROD_URL not found in Info.plist")
#endif
        }
        return baseURLString
    }()

    /// The common path for AppDev Announcements.
    static let announcementsCommonPath: String = {
        guard let value = EateryEnvironment.infoDict[Keys.announcementsCommonPath] as? String else {
            fatalError("ANNOUNCEMENTS_COMMON_PATH not found in Info.plist")
        }
        return value
    }()

    /// The host AppDev Announcements.
    static let announcementsHost: String = {
        guard let value = EateryEnvironment.infoDict[Keys.announcementsHost] as? String else {
            fatalError("ANNOUNCEMENTS_HOST not found in Info.plist")
        }
        return value
    }()

    /// The path for AppDev Announcements.
    static let announcementsPath: String = {
        guard let value = EateryEnvironment.infoDict[Keys.announcementsPath] as? String else {
            fatalError("ANNOUNCEMENTS_PATH not found in Info.plist")
        }
        return value
    }()

    /// The scheme for AppDev Announcements.
    static let announcementsScheme: String = {
        guard let value = EateryEnvironment.infoDict[Keys.announcementsScheme] as? String else {
            fatalError("ANNOUNCEMENTS_SCHEME not found in Info.plist")
        }
        return value
    }()

}
