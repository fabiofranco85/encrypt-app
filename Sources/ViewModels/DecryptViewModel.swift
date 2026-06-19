//  DecryptViewModel.swift
//  Presentation state + orchestration for the Decrypt screen.

import Foundation
import Observation

@MainActor
@Observable
final class DecryptViewModel {
    var inputMode: DecryptInputMode = .paste
    var pastedText: String = ""
    var pickedFile: PickedFile?
    var password: String = ""

    private(set) var isWorking = false
    private(set) var artifact: Artifact?
    var errorMessage: String?

    private let service: CryptoService

    /// `nonisolated` so the model can be created from `App.init` (a nonisolated
    /// context). It only stores the (Sendable) service and default values.
    nonisolated init(service: CryptoService) {
        self.service = service
    }

    // MARK: Derived state

    var hasInput: Bool {
        switch inputMode {
        case .paste: return !pastedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .file: return pickedFile != nil
        }
    }

    var canDecrypt: Bool {
        !isWorking && hasInput && !password.isEmpty
    }

    // MARK: Actions

    /// Pre-loads a `.quietbox` file opened from outside the app (share sheet /
    /// Files), switching to file mode.
    func load(file: PickedFile) {
        inputMode = .file
        pickedFile = file
        artifact = nil
        errorMessage = nil
    }

    func decrypt() async {
        guard canDecrypt else { return }
        errorMessage = nil
        artifact = nil
        isWorking = true
        defer { isWorking = false }

        let service = self.service
        let password = self.password
        let mode = self.inputMode
        let text = self.pastedText
        let file = self.pickedFile

        self.password = ""

        do {
            let result = try await Task.detached(priority: .userInitiated) {
                let source: DecryptSource
                switch mode {
                case .paste:
                    source = .armoredText(text)
                case .file:
                    guard let file else { throw CryptoError.malformedArtifact }
                    source = .container(file.data)
                }
                return try service.decrypt(source, password: password)
            }.value
            artifact = result
            Haptics.success()
        } catch let error as CryptoError {
            errorMessage = error.userMessage
            Haptics.error()
        } catch {
            errorMessage = "Something went wrong. Please try again."
            Haptics.error()
        }
    }

    func dismissResult() {
        artifact = nil
    }

    func clearInputs() {
        pastedText = ""
        pickedFile = nil
        password = ""
        artifact = nil
        errorMessage = nil
    }
}
