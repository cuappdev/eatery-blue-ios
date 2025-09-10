//
//  WKWebView+Extension.swift
//  Eatery Blue
//
//  Created by Vin Bui on 10/18/23.
//

import WebKit

extension WKWebView {
    func cleanAllCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            for record in records {
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }

    func refreshCookies() {
        configuration.processPool = WKProcessPool()
    }
}
