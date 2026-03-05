//
//  AccessTokenResponse.swift
//  EateryModel
//
//  Created by Adelynn Wu on 3/4/26.
//

public struct AccessTokenResponse: Decodable {
    public let accessToken: String
    public let refreshToken: String
}
