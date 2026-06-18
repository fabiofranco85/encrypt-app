import XCTest
@testable import Quietbox

@MainActor
final class DecryptViewModelTests: XCTestCase {
    private let service = CryptoService(engine: FakeCryptoEngine())

    private func armoredMessage(_ text: String, password: String) throws -> String {
        let artifact = try service.encryptText(text, password: password)
        guard case let .text(armored) = artifact.content else {
            throw CryptoError.malformedArtifact
        }
        return armored
    }

    func test_canDecrypt_requiresInputAndPassword() {
        let viewModel = DecryptViewModel(service: service)
        XCTAssertFalse(viewModel.canDecrypt)
        viewModel.pastedText = "data"
        XCTAssertFalse(viewModel.canDecrypt)
        viewModel.password = "pw"
        XCTAssertTrue(viewModel.canDecrypt)
    }

    func test_decryptPastedText_recoversMessage() async throws {
        let armored = try armoredMessage("hidden words", password: "pw")
        let viewModel = DecryptViewModel(service: service)
        viewModel.inputMode = .paste
        viewModel.pastedText = armored
        viewModel.password = "pw"

        await viewModel.decrypt()

        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.artifact?.content, .text("hidden words"))
        XCTAssertEqual(viewModel.artifact?.allowedActions, [.copy])
    }

    func test_decrypt_wrongPassword_setsError() async throws {
        let armored = try armoredMessage("hidden words", password: "pw")
        let viewModel = DecryptViewModel(service: service)
        viewModel.pastedText = armored
        viewModel.password = "nope"

        await viewModel.decrypt()

        XCTAssertNil(viewModel.artifact)
        XCTAssertEqual(viewModel.errorMessage, CryptoError.authenticationFailed.userMessage)
    }

    func test_loadFile_switchesToFileModeAndClearsResult() {
        let viewModel = DecryptViewModel(service: service)
        viewModel.load(file: PickedFile(filename: "x.quietbox", data: Data([1, 2, 3])))
        XCTAssertEqual(viewModel.inputMode, .file)
        XCTAssertEqual(viewModel.pickedFile?.filename, "x.quietbox")
    }
}
