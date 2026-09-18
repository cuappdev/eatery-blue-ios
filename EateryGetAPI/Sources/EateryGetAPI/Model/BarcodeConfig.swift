//
//  BarcodeConfig.swift
//
//
//  Created by Arielle Nudelman on 9/17/26.
//

// What we keep after talking to GET: a secret seed + whether the phone
// is allowed to draw barcodes itself.
public struct BarcodeConfig: Equatable {
    // Secret hex string used later to generate the 22-digit code.
    // nil means GET did not give us a usable seed.
    public let barcodeSeed: String?

    // GET's "you may generate barcodes offline" switch.
    // If this is false, we must not show a barcode.
    public let enableOfflineBarcodeGeneration: Bool

    // Shortcut: do we have everything needed to show a real barcode?
    public var canGenerateOfflineBarcode: Bool {
        enableOfflineBarcodeGeneration && barcodeSeed != nil
    }

    public init(barcodeSeed: String?, enableOfflineBarcodeGeneration: Bool) {
        self.barcodeSeed = barcodeSeed
        self.enableOfflineBarcodeGeneration = enableOfflineBarcodeGeneration
    }
}
