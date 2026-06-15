//  CryptoEngine.swift
//  The single choke point for cryptographic primitives. The libsodium
//  implementation is the only code that touches the native library; everything
//  else depends on this protocol so it can be tested with a fake.

import Foundation

/// Result of sealing: the freshly generated nonce and the authenticated ciphertext.
struct SealedBox: Equatable, Sendable {
    var nonce: Data
    var ciphertext: Data
}

/// Cryptographic primitives required by the app.
protocol CryptoEngine: Sendable {
    /// CSPRNG bytes.
    func randomBytes(count: Int) throws -> Data

    /// Derives a 32-byte key from a password using Argon2id.
    /// - Parameters:
    ///   - password: user secret; never logged or persisted.
    ///   - salt: 16 random bytes unique to the artifact.
    ///   - parameters: Argon2id cost parameters.
    func deriveKey(password: String, salt: Data, parameters: CryptoParameters) throws -> Data

    /// Encrypts `plaintext` under `key`, generating a fresh nonce.
    /// - Parameter associatedData: authenticated-but-not-encrypted header bytes.
    func seal(plaintext: Data, key: Data, associatedData: Data) throws -> SealedBox

    /// Decrypts and authenticates. Throws ``CryptoError/authenticationFailed``
    /// if the key is wrong or the data was tampered with.
    func open(ciphertext: Data, nonce: Data, key: Data, associatedData: Data) throws -> Data
}
