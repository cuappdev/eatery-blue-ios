//
//  BarcodeConfig.swift
//
//
//  Created by Arielle Nudelman on 9/17/26.
//

public struct BarcodeConfig: Equatable {
    public let barcodeSeed: String?
    public let enableOfflineBarcodeGeneration: Bool

    public var canGenerateOfflineBarcode: Bool {
        enableOfflineBarcodeGeneration && barcodeSeed != nil
    }

    public init(barcodeSeed: String?, enableOfflineBarcodeGeneration: Bool) {
        self.barcodeSeed = barcodeSeed
        self.enableOfflineBarcodeGeneration = enableOfflineBarcodeGeneration
    }
}
