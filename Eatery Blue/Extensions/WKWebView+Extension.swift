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
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }

    func refreshCookies() {
        self.configuration.processPool = WKProcessPool()
    }
    
}
