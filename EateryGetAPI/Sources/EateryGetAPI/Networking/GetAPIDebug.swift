//
//  GetAPIDebug.swift
//  
//
//  Created by William Ma on 1/12/22.
//

import UIKit

public enum _GetAPIDebug {

    @MainActor
    public static func sessionId(netId: String, password: String, attachToView view: UIView) async throws -> String {
        let login = GetAccountLogin(netId: netId, password: password)
        view.addSubview(login.webView)
        NSLayoutConstraint.activate([
            login.webView.topAnchor.constraint(equalTo: view.topAnchor),
            login.webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            login.webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            login.webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        return try await login.sessionId()
    }

}
