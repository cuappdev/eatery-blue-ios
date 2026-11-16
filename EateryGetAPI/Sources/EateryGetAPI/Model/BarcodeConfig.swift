//
//  BarcodeConfig.swift
//
//
//  Created by Arielle Nudelman on 9/17/26.
//

/// Offline barcode generation config from GET `nativeStartup`.
public struct BarcodeConfig: Equatable {
    /// Secret hex seed for the payment code; nil if GET did not provide one.
    public let barcodeSeed: String?

    /// Whether GET allows offline barcode generation on device.
    public let enableOfflineBarcodeGeneration: Bool

    public var canGenerateOfflineBarcode: Bool {
        enableOfflineBarcodeGeneration && barcodeSeed != nil
    }

    public init(barcodeSeed: String?, enableOfflineBarcodeGeneration: Bool) {
        self.barcodeSeed = barcodeSeed
        self.enableOfflineBarcodeGeneration = enableOfflineBarcodeGeneration
    }
}
