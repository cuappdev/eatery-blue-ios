//
//  GetAPIError.swift
//  
//
//  Created by William Ma on 1/12/22.
//

import Foundation

public enum GetAPIError: Error {

    case invalidLoginUrl

    case loginFailed

    case internalError

    case emptyNetId

    case emptyPassword

}
