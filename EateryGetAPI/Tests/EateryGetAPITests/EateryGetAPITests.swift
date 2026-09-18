@testable import EateryGetAPI
import XCTest

// These tests never call GET. They feed fake JSON into the decoder.

final class NativeStartupDecodingTests: XCTestCase {
    // Happy path: seed + offline on → we can generate a barcode.
    // pinSeed is in the JSON on purpose; decoding should ignore it.
    func testDecodesSeedWhenOfflineGenerationIsEnabled() throws {
        let data = fixtureJSON("""
        {
          "response": {
            "barcodeSeed": "0123456789abcdef",
            "enableOfflineBarcodeGeneration": true,
            "pinSeed": "should-be-ignored"
          }
        }
        """)

        let config = try SchemaToModel.barcodeConfig(fromNativeStartupData: data)

        XCTAssertEqual(config.barcodeSeed, "0123456789abcdef")
        XCTAssertTrue(config.enableOfflineBarcodeGeneration)
        XCTAssertTrue(config.canGenerateOfflineBarcode)
    }

    // GET said offline generation is off → do not show a barcode.
    func testDoesNotTreatOfflineDisabledAsUsableBarcode() throws {
        let data = fixtureJSON("""
        {
          "response": {
            "barcodeSeed": "0123456789abcdef",
            "enableOfflineBarcodeGeneration": false
          }
        }
        """)

        let config = try SchemaToModel.barcodeConfig(fromNativeStartupData: data)

        XCTAssertEqual(config.barcodeSeed, "0123456789abcdef")
        XCTAssertFalse(config.enableOfflineBarcodeGeneration)
        XCTAssertFalse(config.canGenerateOfflineBarcode)
    }

    // No seed field → not usable.
    func testMissingSeedIsNotUsable() throws {
        let data = fixtureJSON("""
        {
          "response": {
            "enableOfflineBarcodeGeneration": true
          }
        }
        """)

        let config = try SchemaToModel.barcodeConfig(fromNativeStartupData: data)

        XCTAssertNil(config.barcodeSeed)
        XCTAssertTrue(config.enableOfflineBarcodeGeneration)
        XCTAssertFalse(config.canGenerateOfflineBarcode)
    }

    // Empty string is not a real seed.
    func testEmptySeedIsNotUsable() throws {
        let data = fixtureJSON("""
        {
          "response": {
            "barcodeSeed": "",
            "enableOfflineBarcodeGeneration": true
          }
        }
        """)

        let config = try SchemaToModel.barcodeConfig(fromNativeStartupData: data)

        XCTAssertNil(config.barcodeSeed)
        XCTAssertFalse(config.canGenerateOfflineBarcode)
    }

    // Missing switch → assume false (safer than showing a barcode).
    func testMissingOfflineFlagDefaultsToFalse() throws {
        let data = fixtureJSON("""
        {
          "response": {
            "barcodeSeed": "0123456789abcdef"
          }
        }
        """)

        let config = try SchemaToModel.barcodeConfig(fromNativeStartupData: data)

        XCTAssertFalse(config.enableOfflineBarcodeGeneration)
        XCTAssertFalse(config.canGenerateOfflineBarcode)
    }

    // Junk data should fail, not pretend we got a config.
    func testMalformedJSONThrows() {
        let data = Data("not-json".utf8)

        XCTAssertThrowsError(try SchemaToModel.barcodeConfig(fromNativeStartupData: data))
    }

    // Helper: JSON string → Data for the decoder.
    private func fixtureJSON(_ string: String) -> Data {
        Data(string.utf8)
    }
}
