@testable import EateryGetAPI
import XCTest

final class NativeStartupDecodingTests: XCTestCase {
    /// pinSeed is included to assert decoding ignores fields we do not model.
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

    func testMalformedJSONThrows() {
        let data = Data("not-json".utf8)

        XCTAssertThrowsError(try SchemaToModel.barcodeConfig(fromNativeStartupData: data))
    }

    private func fixtureJSON(_ string: String) -> Data {
        Data(string.utf8)
    }
}
