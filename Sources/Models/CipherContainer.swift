//  CipherContainer.swift
//  The binary format (v1) of a Hushbox artifact. Header fields are PLAINTEXT;
//  all secrets live inside `ciphertext`. See docs/crypto-design.md.

import Foundation

/// A parsed Hushbox artifact.
///
/// On-wire layout (big-endian):
/// ```
/// magic "HUSH"(4) | version(1) | kdfId(1) | cipherId(1) | reserved(1)
/// | opsLimit(8) | memLimit(8) | salt(16) | nonce(24) | ciphertext+tag(rest)
/// ```
/// The first 40 bytes (everything up to and including `salt`) are passed to the
/// AEAD as associated data, so the version/algorithm ids and KDF parameters are
/// authenticated. The nonce and salt are additionally protected implicitly: any
/// change to them yields the wrong key/stream and fails authentication.
struct CipherContainer: Equatable, Sendable {
    var parameters: CryptoParameters
    var salt: Data
    var nonce: Data
    var ciphertext: Data

    static let magic: [UInt8] = Array("HUSH".utf8)
    static let version: UInt8 = 1
    static let kdfArgon2id: UInt8 = 1
    static let cipherXChaCha20Poly1305: UInt8 = 1

    /// Length of the authenticated, pre-nonce header (magic…salt).
    static let associatedDataLength = 40
    /// Length of the full clear header (associated data + nonce).
    static let headerLength = 64
}

/// Serializes `CipherContainer` to/from its wire form.
enum CipherContainerCodec {
    /// The 40-byte authenticated header (magic…salt), used as AEAD associated data.
    static func associatedData(parameters: CryptoParameters, salt: Data) -> Data {
        var writer = ByteWriter()
        writer.writeBytes(Data(CipherContainer.magic))
        writer.writeUInt8(CipherContainer.version)
        writer.writeUInt8(CipherContainer.kdfArgon2id)
        writer.writeUInt8(CipherContainer.cipherXChaCha20Poly1305)
        writer.writeUInt8(0) // reserved
        writer.writeUInt64(parameters.opsLimit)
        writer.writeUInt64(parameters.memLimit)
        writer.writeBytes(salt)
        return writer.data
    }

    static func encode(_ container: CipherContainer) -> Data {
        var data = associatedData(parameters: container.parameters, salt: container.salt)
        data.append(container.nonce)
        data.append(container.ciphertext)
        return data
    }

    static func decode(_ data: Data) throws -> CipherContainer {
        guard data.count >= CipherContainer.headerLength + CryptoSizes.tag else {
            throw CryptoError.malformedArtifact
        }
        var reader = ByteReader(data)

        let magic = try reader.readBytes(4)
        guard [UInt8](magic) == CipherContainer.magic else {
            throw CryptoError.malformedArtifact
        }
        let version = try reader.readUInt8()
        guard version == CipherContainer.version else {
            throw CryptoError.unsupportedVersion(version)
        }
        let kdfId = try reader.readUInt8()
        let cipherId = try reader.readUInt8()
        guard kdfId == CipherContainer.kdfArgon2id,
              cipherId == CipherContainer.cipherXChaCha20Poly1305 else {
            throw CryptoError.unsupportedAlgorithm
        }
        _ = try reader.readUInt8() // reserved
        let opsLimit = try reader.readUInt64()
        let memLimit = try reader.readUInt64()
        let salt = try reader.readBytes(CryptoSizes.salt)
        let nonce = try reader.readBytes(CryptoSizes.nonce)
        let ciphertext = reader.readRemaining()

        return CipherContainer(
            parameters: CryptoParameters(opsLimit: opsLimit, memLimit: memLimit),
            salt: salt,
            nonce: nonce,
            ciphertext: ciphertext
        )
    }
}
