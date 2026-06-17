import XCTest
@testable import Cipherbox

/// Exercises the full encrypt/decrypt pipeline (container + payload + armor)
/// using the deterministic FakeCryptoEngine — no native dependency required.
final class CryptoServiceTests: XCTestCase {
    private let service = CryptoService(engine: FakeCryptoEngine())
    private let password = "correct horse battery staple"

    // MARK: Text

    func test_encryptText_producesCopyOnlyArtifact() throws {
        let artifact = try service.encryptText("meet me at noon", password: password)
        XCTAssertTrue(artifact.isText)
        XCTAssertEqual(artifact.allowedActions, [.copy])
        if case let .text(armored) = artifact.content {
            XCTAssertTrue(armored.contains(MessageArmor.header))
        } else {
            XCTFail("Expected text content")
        }
    }

    func test_encryptText_thenDecrypt_recoversMessage() throws {
        let message = "meet me at noon 🌙"
        let encrypted = try service.encryptText(message, password: password)
        guard case let .text(armored) = encrypted.content else { return XCTFail() }

        let decrypted = try service.decrypt(.armoredText(armored), password: password)
        XCTAssertEqual(decrypted.content, .text(message))
        XCTAssertEqual(decrypted.allowedActions, [.copy])
    }

    // MARK: File

    func test_encryptFile_producesShareableArtifactNamedCipherbox() throws {
        let artifact = try service.encryptFile(
            data: Data([0xDE, 0xAD, 0xBE, 0xEF]),
            filename: "photo.jpg",
            password: password
        )
        XCTAssertEqual(artifact.allowedActions, [.copy, .share, .save])
        if case let .file(_, filename) = artifact.content {
            XCTAssertEqual(filename, "photo.jpg.cipherbox")
        } else {
            XCTFail("Expected file content")
        }
    }

    func test_encryptFile_thenDecrypt_recoversBytesAndName() throws {
        let original = Data((0..<512).map { UInt8(truncatingIfNeeded: $0) })
        let encrypted = try service.encryptFile(data: original, filename: "report.pdf", password: password)
        guard case let .file(containerData, _) = encrypted.content else { return XCTFail() }

        let decrypted = try service.decrypt(.container(containerData), password: password)
        XCTAssertEqual(decrypted.allowedActions, [.copy, .share, .save])
        XCTAssertEqual(decrypted.content, .file(data: original, filename: "report.pdf"))
    }

    // MARK: Failure modes

    func test_decrypt_wrongPassword_throwsAuthenticationFailed() throws {
        let encrypted = try service.encryptText("hi", password: password)
        guard case let .text(armored) = encrypted.content else { return XCTFail() }
        XCTAssertThrowsError(try service.decrypt(.armoredText(armored), password: "wrong")) {
            XCTAssertEqual($0 as? CryptoError, .authenticationFailed)
        }
    }

    func test_decrypt_tamperedCiphertext_throwsAuthenticationFailed() throws {
        let encrypted = try service.encryptFile(data: Data([1, 2, 3]), filename: "x.bin", password: password)
        guard case let .file(original, _) = encrypted.content else { return XCTFail() }
        // Flip a byte inside the ciphertext region (past the 64-byte header).
        var containerData = original
        containerData[70] ^= 0xFF
        XCTAssertThrowsError(try service.decrypt(.container(containerData), password: password)) {
            XCTAssertEqual($0 as? CryptoError, .authenticationFailed)
        }
    }

    func test_encrypt_emptyPassword_throws() {
        XCTAssertThrowsError(try service.encryptText("hi", password: "")) {
            XCTAssertEqual($0 as? CryptoError, .emptyPassword)
        }
    }

    func test_decrypt_emptyPassword_throws() {
        XCTAssertThrowsError(try service.decrypt(.armoredText("anything"), password: "")) {
            XCTAssertEqual($0 as? CryptoError, .emptyPassword)
        }
    }
}
