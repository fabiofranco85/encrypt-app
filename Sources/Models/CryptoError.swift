//  CryptoError.swift
//  Typed domain errors. The UI maps these to calm, non-technical messages;
//  raw errors are never shown to the user.

import Foundation

/// Errors produced by the crypto pipeline.
enum CryptoError: Error, Equatable {
    /// The artifact is too short, has a bad magic number, or is otherwise
    /// not parseable as a Quietbox container.
    case malformedArtifact
    /// The artifact was produced by a newer, unsupported format version.
    case unsupportedVersion(UInt8)
    /// The artifact references a KDF/cipher this build does not implement.
    case unsupportedAlgorithm
    /// Authentication failed: wrong password, or the data was tampered/corrupted.
    case authenticationFailed
    /// The key derivation function failed (e.g. out of memory).
    case keyDerivationFailed
    /// The system CSPRNG failed to produce random bytes.
    case randomGenerationFailed
    /// A password was required but empty.
    case emptyPassword

    /// A short, user-facing description. Never leaks technical detail.
    var userMessage: String {
        switch self {
        case .malformedArtifact:
            return "This doesn’t look like a Quietbox message or file."
        case .unsupportedVersion:
            return "This was made with a newer version of Quietbox. Please update."
        case .unsupportedAlgorithm:
            return "This artifact uses an option this version can’t open."
        case .authenticationFailed:
            return "Couldn’t unlock — check the password and try again."
        case .keyDerivationFailed:
            return "Something went wrong preparing the key. Please try again."
        case .randomGenerationFailed:
            return "Couldn’t generate secure randomness. Please try again."
        case .emptyPassword:
            return "Enter a password to continue."
        }
    }
}
