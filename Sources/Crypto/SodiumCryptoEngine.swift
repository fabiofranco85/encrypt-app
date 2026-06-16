//  SodiumCryptoEngine.swift
//  The ONLY code that touches libsodium. Implements Argon2id key derivation and
//  XChaCha20-Poly1305-IETF AEAD via swift-sodium.

import Foundation
import Sodium

/// Production `CryptoEngine` backed by libsodium (swift-sodium).
///
/// Holds no stored state: `Sodium()` only ensures libsodium is initialized
/// (idempotent), and libsodium is thread-safe, so the engine is trivially
/// `Sendable`.
struct SodiumCryptoEngine: CryptoEngine {
    private var sodium: Sodium { Sodium() }

    func randomBytes(count: Int) throws -> Data {
        guard let bytes = sodium.randomBytes.buf(length: count) else {
            throw CryptoError.randomGenerationFailed
        }
        return Data(bytes)
    }

    func deriveKey(password: String, salt: Data, parameters: CryptoParameters) throws -> Data {
        guard let key = sodium.pwHash.hash(
            outputLength: CryptoSizes.key,
            passwd: [UInt8](Data(password.utf8)),
            salt: [UInt8](salt),
            opsLimit: Int(parameters.opsLimit),
            memLimit: Int(parameters.memLimit),
            alg: .Argon2ID13
        ) else {
            throw CryptoError.keyDerivationFailed
        }
        return Data(key)
    }

    func seal(plaintext: Data, key: Data, associatedData: Data) throws -> SealedBox {
        // swift-sodium exposes two `encrypt` overloads differing only by return
        // type; annotate to select the (cipherText, nonce) tuple variant.
        let result: (authenticatedCipherText: [UInt8], nonce: [UInt8])? =
            sodium.aead.xchacha20poly1305ietf.encrypt(
                message: [UInt8](plaintext),
                secretKey: [UInt8](key),
                additionalData: [UInt8](associatedData)
            )
        guard let result else { throw CryptoError.authenticationFailed }
        return SealedBox(
            nonce: Data(result.nonce),
            ciphertext: Data(result.authenticatedCipherText)
        )
    }

    func open(ciphertext: Data, nonce: Data, key: Data, associatedData: Data) throws -> Data {
        guard let plaintext = sodium.aead.xchacha20poly1305ietf.decrypt(
            authenticatedCipherText: [UInt8](ciphertext),
            secretKey: [UInt8](key),
            nonce: [UInt8](nonce),
            additionalData: [UInt8](associatedData)
        ) else {
            throw CryptoError.authenticationFailed
        }
        return Data(plaintext)
    }
}
