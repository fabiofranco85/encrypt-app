import XCTest
@testable import Hushbox

/// End-to-end encrypt → decrypt using the REAL libsodium engine.
final class CryptoServiceRoundTripTests: XCTestCase {
    private let service = CryptoService(engine: SodiumCryptoEngine())
    // Lighter-than-default parameters to keep CI fast.
    private let params = CryptoParameters(opsLimit: 1, memLimit: 8 * 1024 * 1024)
    private let password = "correct horse battery staple"

    func test_text_roundTrip() throws {
        let message = "Привет — hello — 🌍 secret message"
        let artifact = try service.encryptText(message, password: password, parameters: params)
        guard case let .text(armored) = artifact.content else { return XCTFail() }

        let decrypted = try service.decrypt(.armoredText(armored), password: password)
        XCTAssertEqual(decrypted.content, .text(message))
    }

    func test_file_roundTrip_binaryData() throws {
        let original = Data((0..<2048).map { _ in UInt8.random(in: 0...255) })
        let artifact = try service.encryptFile(
            data: original, filename: "secret.bin", password: password, parameters: params
        )
        guard case let .file(container, name) = artifact.content else { return XCTFail() }
        XCTAssertEqual(name, "secret.bin.hushbox")

        let decrypted = try service.decrypt(.container(container), password: password)
        XCTAssertEqual(decrypted.content, .file(data: original, filename: "secret.bin"))
        XCTAssertEqual(decrypted.allowedActions, [.copy, .share, .save])
    }

    func test_wrongPassword_throws() throws {
        let artifact = try service.encryptText("hi", password: password, parameters: params)
        guard case let .text(armored) = artifact.content else { return XCTFail() }
        XCTAssertThrowsError(try service.decrypt(.armoredText(armored), password: "wrong")) {
            XCTAssertEqual($0 as? CryptoError, .authenticationFailed)
        }
    }
}
