//  CryptoParameters.swift
//  Argon2id cost parameters. Stored inside each artifact so they can be
//  raised in future versions without breaking old artifacts.

import Foundation

/// Argon2id tuning parameters.
struct CryptoParameters: Equatable, Sendable {
    /// Number of passes (libsodium `opsLimit`).
    var opsLimit: UInt64
    /// Memory in bytes (libsodium `memLimit`).
    var memLimit: UInt64

    /// Responsive default for on-device use (libsodium INTERACTIVE profile):
    /// 2 passes, 64 MiB. Each artifact has a unique salt, so this is a sound
    /// trade-off between security and phone UX.
    static let interactive = CryptoParameters(opsLimit: 2, memLimit: 64 * 1024 * 1024)

    /// Stronger profile (libsodium MODERATE): 3 passes, 256 MiB.
    static let moderate = CryptoParameters(opsLimit: 3, memLimit: 256 * 1024 * 1024)
}

/// Fixed byte sizes for the chosen primitives.
enum CryptoSizes {
    /// XChaCha20-Poly1305 key length.
    static let key = 32
    /// Argon2id salt length (`crypto_pwhash_SALTBYTES`).
    static let salt = 16
    /// XChaCha20-Poly1305-IETF nonce length.
    static let nonce = 24
    /// Poly1305 authentication tag length.
    static let tag = 16
}
