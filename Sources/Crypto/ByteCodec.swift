//  ByteCodec.swift
//  Minimal big-endian byte serialization used by the container/payload codecs.
//  Reads are bounds-checked and throw on truncation so malformed artifacts
//  never read out of bounds.

import Foundation

/// Appends primitives to a growing `Data` buffer in big-endian order.
struct ByteWriter {
    private(set) var data = Data()

    mutating func writeUInt8(_ value: UInt8) {
        data.append(value)
    }

    mutating func writeUInt16(_ value: UInt16) {
        data.append(UInt8(truncatingIfNeeded: value >> 8))
        data.append(UInt8(truncatingIfNeeded: value))
    }

    mutating func writeUInt64(_ value: UInt64) {
        for shift in stride(from: 56, through: 0, by: -8) {
            data.append(UInt8(truncatingIfNeeded: value >> UInt64(shift)))
        }
    }

    mutating func writeBytes(_ bytes: Data) {
        data.append(bytes)
    }
}

/// Sequentially reads primitives from a `Data` buffer in big-endian order.
///
/// The input is normalized to a zero-based buffer so slices (e.g. `Data`
/// produced by `prefix`/`suffix`) read correctly.
struct ByteReader {
    private let bytes: [UInt8]
    private var offset = 0

    init(_ data: Data) {
        self.bytes = [UInt8](data)
    }

    var remainingCount: Int { bytes.count - offset }

    mutating func readUInt8() throws -> UInt8 {
        try require(1)
        defer { offset += 1 }
        return bytes[offset]
    }

    mutating func readUInt16() throws -> UInt16 {
        try require(2)
        defer { offset += 2 }
        return UInt16(bytes[offset]) << 8 | UInt16(bytes[offset + 1])
    }

    mutating func readUInt64() throws -> UInt64 {
        try require(8)
        defer { offset += 8 }
        var value: UInt64 = 0
        for index in 0..<8 {
            value = value << 8 | UInt64(bytes[offset + index])
        }
        return value
    }

    mutating func readBytes(_ count: Int) throws -> Data {
        guard count >= 0 else { throw CryptoError.malformedArtifact }
        try require(count)
        defer { offset += count }
        return Data(bytes[offset..<offset + count])
    }

    /// Returns all bytes not yet consumed.
    mutating func readRemaining() -> Data {
        defer { offset = bytes.count }
        return Data(bytes[offset...])
    }

    private func require(_ count: Int) throws {
        guard remainingCount >= count else { throw CryptoError.malformedArtifact }
    }
}
