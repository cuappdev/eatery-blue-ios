@testable import EateryGetAPI
import XCTest

final class PatronIdDecodingTests: XCTestCase {
    func testDecodesPatronIdString() throws {
        let transaction = try decodeTransaction("""
        {
          "accountName": "Flex",
          "actualDate": "2024-01-15T12:00:00.000-0500",
          "amount": 1,
          "locationName": "Okenshields",
          "transactionType": 1,
          "patronId": "12345"
        }
        """)

        XCTAssertEqual(transaction.patronId?.string, "12345")
    }

    func testDecodesPatronIdNumber() throws {
        let transaction = try decodeTransaction("""
        {
          "patronId": 12345
        }
        """)

        XCTAssertEqual(transaction.patronId?.string, "12345")
    }

    func testMissingPatronIdIsNil() throws {
        let transaction = try decodeTransaction("""
        {
          "accountName": "Flex",
          "locationName": "Okenshields"
        }
        """)

        XCTAssertNil(transaction.patronId?.string)
    }

    func testEmptyPatronIdIsNil() throws {
        let transaction = try decodeTransaction("""
        {
          "patronId": ""
        }
        """)

        XCTAssertNil(transaction.patronId?.string)
    }

    func testEmptyTransactionListHasNoPatronId() {
        let data = SchemaToModel.convert(
            getAccounts: [Schema.RawAccount(accountDisplayName: "Flex", balance: 10)],
            getTransactions: []
        )

        XCTAssertNil(data.patronId)
        XCTAssertEqual(data.accounts.count, 1)
        XCTAssertTrue(data.accounts[0].transactions.isEmpty)
    }

    func testUsesFirstAvailablePatronId() throws {
        let withId = try decodeTransaction("""
        {
          "accountName": "Flex",
          "actualDate": "2024-01-15T12:00:00.000-0500",
          "amount": 1,
          "locationName": "Okenshields",
          "patronId": "12345"
        }
        """)
        let withoutId = try decodeTransaction("""
        {
          "accountName": "Flex",
          "actualDate": "2024-01-16T12:00:00.000-0500",
          "amount": 1,
          "locationName": "RPCC"
        }
        """)

        let data = SchemaToModel.convert(
            getAccounts: [Schema.RawAccount(accountDisplayName: "Flex", balance: 10)],
            getTransactions: [withoutId, withId]
        )

        XCTAssertEqual(data.patronId, "12345")
        XCTAssertEqual(data.accounts[0].transactions.count, 2)
    }

    /// Rows skipped for UI (e.g. missing location) can still supply patronId.
    func testKeepsPatronIdFromRowThatIsNotShown() throws {
        let hidden = try decodeTransaction("""
        {
          "patronId": "12345"
        }
        """)

        let data = SchemaToModel.convert(
            getAccounts: [Schema.RawAccount(accountDisplayName: "Flex", balance: 10)],
            getTransactions: [hidden]
        )

        XCTAssertEqual(data.patronId, "12345")
        XCTAssertTrue(data.accounts[0].transactions.isEmpty)
    }

    private func decodeTransaction(_ json: String) throws -> Schema.RawTransaction {
        try JSONDecoder().decode(Schema.RawTransaction.self, from: Data(json.utf8))
    }
}
