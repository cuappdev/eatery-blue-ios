@testable import EateryGetAPI
import XCTest

// Expected strings came from generate_barcode.py with fake keys, not a live GET account.

final class BarcodeGeneratorTests: XCTestCase {
    func testMatchesPythonForFixedTimestamp() throws {
        let barcode = try BarcodeGenerator.generateBarcode(
            seedHex: "0123456789abcdef",
            cashlessKey: "12345",
            timestamp: 1_700_000_000
        )

        XCTAssertEqual(barcode, "1700000000102731570695")
        XCTAssertEqual(barcode.count, 22)
    }

    // Same keys, 5 seconds later — digits must change.
    func testMatchesPythonFiveSecondsLater() throws {
        let barcode = try BarcodeGenerator.generateBarcode(
            seedHex: "0123456789abcdef",
            cashlessKey: "12345",
            timestamp: 1_700_000_005
        )

        XCTAssertEqual(barcode, "1700000005104570632015")
    }

    func testMatchesPythonWithTenByteSeed() throws {
        let barcode = try BarcodeGenerator.generateBarcode(
            seedHex: "00112233445566778899",
            cashlessKey: "1234567890",
            timestamp: 1_741_034_134
        )

        XCTAssertEqual(barcode, "1741034134114538783673")
    }

    func testMatchesPythonWithSingleDigitPatronId() throws {
        let barcode = try BarcodeGenerator.generateBarcode(
            seedHex: "aabbccddeeff00112233",
            cashlessKey: "1",
            timestamp: 1_600_000_000
        )

        XCTAssertEqual(barcode, "1600000000106227967348")
    }

    // Format: [10-digit time][version 1][10-digit payload][1 check digit]
    func testBarcodeShape() throws {
        let barcode = try BarcodeGenerator.generateBarcode(
            seedHex: "0123456789abcdef",
            cashlessKey: "12345",
            timestamp: 1_700_000_000
        )

        XCTAssertEqual(barcode.prefix(10), "1700000000")
        XCTAssertEqual(barcode.dropFirst(10).prefix(1), "1")
        XCTAssertTrue(barcode.allSatisfy(\.isNumber))
    }
}
