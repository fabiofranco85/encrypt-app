import XCTest
@testable import Hushbox

@MainActor
final class EncryptViewModelTests: XCTestCase {
    private func makeViewModel() -> EncryptViewModel {
        EncryptViewModel(service: CryptoService(engine: FakeCryptoEngine()))
    }

    func test_canEncrypt_requiresContentAndMatchingPasswords() {
        let viewModel = makeViewModel()
        XCTAssertFalse(viewModel.canEncrypt)

        viewModel.messageText = "hello"
        viewModel.password = "secret"
        XCTAssertFalse(viewModel.canEncrypt, "needs confirm to match")

        viewModel.confirmPassword = "secret"
        XCTAssertTrue(viewModel.canEncrypt)
    }

    func test_passwordsMatch_flag() {
        let viewModel = makeViewModel()
        viewModel.password = "abc"
        viewModel.confirmPassword = "abd"
        XCTAssertFalse(viewModel.passwordsMatch)
        viewModel.confirmPassword = "abc"
        XCTAssertTrue(viewModel.passwordsMatch)
    }

    func test_encryptText_setsCopyOnlyArtifact() async {
        let viewModel = makeViewModel()
        viewModel.sourceKind = .text
        viewModel.messageText = "top secret"
        viewModel.password = "pw"
        viewModel.confirmPassword = "pw"

        await viewModel.encrypt()

        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.artifact?.allowedActions, [.copy])
        XCTAssertEqual(viewModel.artifact?.isText, true)
    }

    func test_encryptFile_setsFileArtifactWithAllActions() async {
        let viewModel = makeViewModel()
        viewModel.sourceKind = .file
        viewModel.pickedFile = PickedFile(filename: "a.bin", data: Data([1, 2, 3]))
        viewModel.password = "pw"
        viewModel.confirmPassword = "pw"

        await viewModel.encrypt()

        XCTAssertEqual(viewModel.artifact?.allowedActions, [.copy, .share, .save])
    }

    func test_clearInputs_resetsEverything() {
        let viewModel = makeViewModel()
        viewModel.messageText = "x"
        viewModel.password = "y"
        viewModel.confirmPassword = "y"
        viewModel.clearInputs()
        XCTAssertTrue(viewModel.messageText.isEmpty)
        XCTAssertTrue(viewModel.password.isEmpty)
        XCTAssertNil(viewModel.artifact)
    }
}
