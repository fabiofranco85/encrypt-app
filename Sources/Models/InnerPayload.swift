//  InnerPayload.swift
//  The plaintext that gets encrypted. Carrying the filename here (rather than
//  in the clear container header) keeps metadata confidential.

import Foundation

/// What kind of data an artifact carries.
enum PayloadKind: UInt8, Sendable, Equatable {
    case text = 0
    case file = 1
}

/// The encrypted-side payload: a tagged blob of either a text message or a
/// named file's bytes.
struct InnerPayload: Equatable, Sendable {
    var kind: PayloadKind
    /// Original filename for `.file`; empty string for `.text`.
    var filename: String
    var data: Data

    static func text(_ message: String) -> InnerPayload {
        InnerPayload(kind: .text, filename: "", data: Data(message.utf8))
    }

    static func file(named filename: String, data: Data) -> InnerPayload {
        InnerPayload(kind: .file, filename: filename, data: data)
    }
}

/// Serializes `InnerPayload` to/from its wire form.
///
/// Layout: `kind(1) | filenameLength(2, BE) | filename(UTF-8) | data(rest)`.
enum InnerPayloadCodec {
    static func encode(_ payload: InnerPayload) -> Data {
        var writer = ByteWriter()
        writer.writeUInt8(payload.kind.rawValue)
        let nameBytes = Data(payload.filename.utf8)
        // Filenames are tiny; clamp defensively to the 16-bit length field.
        let nameLength = UInt16(min(nameBytes.count, Int(UInt16.max)))
        writer.writeUInt16(nameLength)
        writer.writeBytes(nameBytes.prefix(Int(nameLength)))
        writer.writeBytes(payload.data)
        return writer.data
    }

    static func decode(_ data: Data) throws -> InnerPayload {
        var reader = ByteReader(data)
        let rawKind = try reader.readUInt8()
        guard let kind = PayloadKind(rawValue: rawKind) else {
            throw CryptoError.malformedArtifact
        }
        let nameLength = try reader.readUInt16()
        let nameBytes = try reader.readBytes(Int(nameLength))
        let filename = String(decoding: nameBytes, as: UTF8.self)
        let payloadData = reader.readRemaining()
        return InnerPayload(kind: kind, filename: filename, data: payloadData)
    }
}
