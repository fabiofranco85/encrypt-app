//  FakeCryptoEngine.swift
//  A deterministic, dependency-free CryptoEngine for unit tests. It is NOT
//  secure — it only needs to round-trip and to detect wrong keys / tampering so
//  the higher layers can be exercised without building libsodium.

import Foundation
@testable import Cipherbox

struct FakeCryptoEngine: CryptoEngine {
    func randomBytes(count: Int) throws -> Data {
        Data((0..<count).map { UInt8(truncatingIfNeeded: $0 &* 7 &+ 13) })
    }

    func deriveKey(password: String, salt: Data, parameters: CryptoParameters) throws -> Data {
        var seed = [UInt8](password.utf8) + [UInt8](salt)
        seed.append(UInt8(truncatingIfNeeded: parameters.opsLimit))
        seed.append(UInt8(truncatingIfNeeded: parameters.memLimit))
        return Data(Self.digest(seed, length: CryptoSizes.key))
    }

    func seal(plaintext: Data, key: Data, associatedData: Data) throws -> SealedBox {
        let nonce = try randomBytes(count: CryptoSizes.nonce)
        let stream = Self.keystream(key: key, nonce: nonce, length: plaintext.count)
        let body = Data(zip(plaintext, stream).map { $0 ^ $1 })
        let tag = Self.tag(key: key, nonce: nonce, aad: associatedData, plaintext: plaintext)
        return SealedBox(nonce: nonce, ciphertext: body + tag)
    }

    func open(ciphertext: Data, nonce: Data, key: Data, associatedData: Data) throws -> Data {
        guard ciphertext.count >= CryptoSizes.tag else { throw CryptoError.malformedArtifact }
        let body = Data(ciphertext.prefix(ciphertext.count - CryptoSizes.tag))
        let tag = Data(ciphertext.suffix(CryptoSizes.tag))
        let stream = Self.keystream(key: key, nonce: nonce, length: body.count)
        let plaintext = Data(zip(body, stream).map { $0 ^ $1 })
        let expectedTag = Self.tag(key: key, nonce: nonce, aad: associatedData, plaintext: plaintext)
        guard tag == expectedTag else { throw CryptoError.authenticationFailed }
        return plaintext
    }

    // MARK: Deterministic helpers (FNV-1a based)

    private static func fnv1a(_ bytes: [UInt8], seed: UInt64) -> UInt64 {
        var hash: UInt64 = 14695981039346656037 ^ seed
        for byte in bytes {
            hash ^= UInt64(byte)
            hash = hash &* 1099511628211
        }
        return hash
    }

    private static func digest(_ bytes: [UInt8], length: Int) -> [UInt8] {
        var out = [UInt8]()
        var counter: UInt64 = 0
        while out.count < length {
            let hash = fnv1a(bytes + [UInt8(truncatingIfNeeded: counter)], seed: counter &+ 0x9E3779B9)
            withUnsafeBytes(of: hash.bigEndian) { out.append(contentsOf: $0) }
            counter &+= 1
        }
        return Array(out.prefix(length))
    }

    private static func keystream(key: Data, nonce: Data, length: Int) -> [UInt8] {
        digest([UInt8](key) + [UInt8](nonce), length: length)
    }

    private static func tag(key: Data, nonce: Data, aad: Data, plaintext: Data) -> Data {
        let material = [0x54] + [UInt8](key) + [UInt8](nonce) + [UInt8](aad) + [UInt8](plaintext)
        return Data(digest(material, length: CryptoSizes.tag))
    }
}
