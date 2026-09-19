//
//  BarcodeGenerator.swift
//
//
//  Created by Arielle Nudelman on 9/18/26.
//

import CryptoKit
import Foundation

// Port of generate_barcode.py. Same inputs must produce the same 22-digit string.
public enum BarcodeGenerator {
    public enum Error: Swift.Error {
        case invalidSeedHex
        case invalidCashlessKey
    }

    // seedHex = barcodeSeed, cashlessKey = patronId, timestamp = unix time
    public static func generateBarcode(
        seedHex: String,
        cashlessKey: String,
        timestamp: Int
    ) throws -> String {
        let checkDigit = generateDigit(cashlessKey)
        let hmacKey = try deriveHmacKey(seedHex: seedHex)
        let patronBytes = try patronKeyToBytes(cashlessKey)

        let totpStr = generateTotp(hmacKey: hmacKey, timestamp: timestamp)
        guard let totpValue = UInt64(totpStr) else {
            throw Error.invalidCashlessKey
        }

        let totpLE = longToLEBytes(totpValue)
        let xorResult = xorEncrypt(patronBytes, totpLE)
        let xorValue = leBytesToLong(xorResult)

        return "\(tenDigits(UInt64(timestamp)))1\(tenDigits(xorValue))\(checkDigit)"
    }
}

// Hardcoded GET garble: base64 → ASCII hex → bytes.
// NTBGQ0RGM0ZFNDIyQTBBNDY5RkU= → 50FCDF3FE422A0A469FE
private let garbleBytes: [UInt8] = [0x50, 0xFC, 0xDF, 0x3F, 0xE4, 0x22, 0xA0, 0xA4, 0x69, 0xFE]

private func xorEncrypt(_ a: [UInt8], _ b: [UInt8]) -> [UInt8] {
    a.enumerated().map { index, byte in
        byte ^ b[index % b.count]
    }
}

private func doLuhn(_ numberStr: String, doubleFirst: Bool) -> Int {
    var total = 0
    var shouldDouble = doubleFirst
    for character in numberStr.reversed() {
        guard let digit = character.wholeNumberValue else {
            continue
        }
        var value = digit
        if shouldDouble {
            value *= 2
            if value > 9 {
                value = (value % 10) + 1
            }
        }
        total += value
        shouldDouble.toggle()
    }
    return total
}

private func generateDigit(_ cashlessKey: String) -> Int {
    let n = 10 - doLuhn(cashlessKey, doubleFirst: true) % 10
    return n % 10 == 0 ? 0 : n
}

private func patronKeyToBytes(_ cashlessKey: String) throws -> [UInt8] {
    guard let value = UInt64(cashlessKey) else {
        throw BarcodeGenerator.Error.invalidCashlessKey
    }
    return Array(longToLEBytes(value).prefix(4))
}

private func longToLEBytes(_ value: UInt64) -> [UInt8] {
    var remaining = value
    var bytes = [UInt8](repeating: 0, count: 8)
    for index in 0 ..< 8 {
        bytes[index] = UInt8(truncatingIfNeeded: remaining)
        remaining >>= 8
    }
    return bytes
}

private func leBytesToLong(_ bytes: [UInt8]) -> UInt64 {
    var result: UInt64 = 0
    for (index, byte) in bytes.enumerated() {
        result += UInt64(byte) << (8 * index)
    }
    return result
}

private func deriveHmacKey(seedHex: String) throws -> [UInt8] {
    try xorEncrypt(garbleBytes, bytesFromHex(seedHex))
}

private func generateTotp(hmacKey: [UInt8], timestamp: Int) -> String {
    // Counter = timestamp as 8-byte big-endian
    var bigEndian = UInt64(timestamp).bigEndian
    let counter = withUnsafeBytes(of: &bigEndian) { Array($0) }

    let mac = HMAC<SHA256>.authenticationCode(
        for: Data(counter),
        using: SymmetricKey(data: Data(hmacKey))
    )
    let digest = Array(mac)

    let offset = Int(digest[digest.count - 1] & 0x0F)
    let binary =
        (UInt32(digest[offset] & 0x7F) << 24)
            | (UInt32(digest[offset + 1] & 0xFF) << 16)
            | (UInt32(digest[offset + 2] & 0xFF) << 8)
            | UInt32(digest[offset + 3] & 0xFF)

    let otp = binary % 1_000_000_000
    return String(otp).leftPadded(to: 9, with: "0")
}

private func bytesFromHex(_ hex: String) throws -> [UInt8] {
    let cleaned = hex.filter { !$0.isWhitespace }
    guard cleaned.count.isMultiple(of: 2), !cleaned.isEmpty else {
        throw BarcodeGenerator.Error.invalidSeedHex
    }

    var bytes: [UInt8] = []
    var index = cleaned.startIndex
    while index < cleaned.endIndex {
        let next = cleaned.index(index, offsetBy: 2)
        let byteString = cleaned[index ..< next]
        guard let byte = UInt8(byteString, radix: 16) else {
            throw BarcodeGenerator.Error.invalidSeedHex
        }
        bytes.append(byte)
        index = next
    }
    return bytes
}

private func tenDigits(_ value: UInt64) -> String {
    String(value).leftPadded(to: 10, with: "0")
}

private extension String {
    func leftPadded(to length: Int, with character: Character) -> String {
        if count >= length {
            return self
        }
        return String(repeating: String(character), count: length - count) + self
    }
}
