import XCTest
@testable import Quietbox

/// Exercises the REAL libsodium-backed engine. Requires the Sodium package to
/// build, so it lives in the integration target.
final class SodiumCryptoEngineTests: XCTestCase {
    private let engine = SodiumCryptoEngine()
    // Fast parameters keep the suite snappy; production uses .interactive.
    private let params = CryptoParameters(opsLimit: 1, memLimit: 8 * 1024 * 1024)

    func test_deriveKey_isDeterministicForSameInputs() throws {
        let salt = try engine.randomBytes(count: CryptoSizes.salt)
        let a = try engine.deriveKey(password: "pw", salt: salt, parameters: params)
        let b = try engine.deriveKey(password: "pw", salt: salt, parameters: params)
        XCTAssertEqual(a, b)
        XCTAssertEqual(a.count, CryptoSizes.key)
    }

    func test_deriveKey_changesWithSalt() throws {
        let saltA = try engine.randomBytes(count: CryptoSizes.salt)
        let saltB = try engine.randomBytes(count: CryptoSizes.salt)
        let a = try engine.deriveKey(password: "pw", salt: saltA, parameters: params)
        let b = try engine.deriveKey(password: "pw", salt: saltB, parameters: params)
        XCTAssertNotEqual(a, b)
    }

    func test_sealOpen_roundTrips() throws {
        let key = try engine.randomBytes(count: CryptoSizes.key)
        let aad = Data([1, 2, 3, 4])
        let message = Data("the eagle lands at dawn".utf8)

        let sealed = try engine.seal(plaintext: message, key: key, associatedData: aad)
        XCTAssertEqual(sealed.nonce.count, CryptoSizes.nonce)

        let opened = try engine.open(
            ciphertext: sealed.ciphertext,
            nonce: sealed.nonce,
            key: key,
            associatedData: aad
        )
        XCTAssertEqual(opened, message)
    }

    func test_open_wrongKey_fails() throws {
        let key = try engine.randomBytes(count: CryptoSizes.key)
        let wrong = try engine.randomBytes(count: CryptoSizes.key)
        let sealed = try engine.seal(plaintext: Data("hi".utf8), key: key, associatedData: Data())
        XCTAssertThrowsError(try engine.open(
            ciphertext: sealed.ciphertext, nonce: sealed.nonce, key: wrong, associatedData: Data()
        )) { XCTAssertEqual($0 as? CryptoError, .authenticationFailed) }
    }

    func test_open_tamperedAAD_fails() throws {
        let key = try engine.randomBytes(count: CryptoSizes.key)
        let sealed = try engine.seal(plaintext: Data("hi".utf8), key: key, associatedData: Data([0]))
        XCTAssertThrowsError(try engine.open(
            ciphertext: sealed.ciphertext, nonce: sealed.nonce, key: key, associatedData: Data([9])
        )) { XCTAssertEqual($0 as? CryptoError, .authenticationFailed) }
    }

    func test_randomBytes_lengthAndUniqueness() throws {
        let a = try engine.randomBytes(count: 32)
        let b = try engine.randomBytes(count: 32)
        XCTAssertEqual(a.count, 32)
        XCTAssertNotEqual(a, b)
    }
}
