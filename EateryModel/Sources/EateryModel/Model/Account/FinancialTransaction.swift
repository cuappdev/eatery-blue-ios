//
//  FinancialTransaction.swift
//  EateryGetAPI
//
//  Created by Adelynn Wu on 3/6/26.
//
import SwiftUI

public struct FinancialTransaction: Decodable {
    public let amount: Double?
    public let tenderId: String?
    public let accountName: String?
    public let date: Date?
    public let location: String?
}
