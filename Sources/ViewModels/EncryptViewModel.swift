//  EncryptViewModel.swift
//  Presentation state + orchestration for the Encrypt screen.

import Foundation
import Observation

@MainActor
@Observable
final class EncryptViewModel {
    var sourceKind: SourceKind = .text
    var messageText: String = ""
    var pickedFile: PickedFile?
    var password: String = ""
    var confirmPassword: String = ""

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

    var passwordStrength: PasswordStrength {
        PasswordStrength.evaluate(password)
    }

    var passwordsMatch: Bool {
        confirmPassword.isEmpty || password == confirmPassword
    }

    var hasContent: Bool {
        switch sourceKind {
        case .text: return !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .file: return pickedFile != nil
        }
    }

    var canEncrypt: Bool {
        !isWorking
            && hasContent
            && !password.isEmpty
            && password == confirmPassword
    }

    // MARK: Actions

    func encrypt() async {
        guard canEncrypt else { return }
        errorMessage = nil
        artifact = nil
        isWorking = true
        defer { isWorking = false }

        let service = self.service
        let password = self.password
        let kind = self.sourceKind
        let message = self.messageText
        let file = self.pickedFile

        self.password = ""
        self.confirmPassword = ""

        do {
            let result = try await Task.detached(priority: .userInitiated) {
                switch kind {
                case .text:
                    return try service.encryptText(message, password: password)
                case .file:
                    guard let file else { throw CryptoError.malformedArtifact }
                    return try service.encryptFile(
                        data: file.data,
                        filename: file.filename,
                        password: password
                    )
                }
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
        messageText = ""
        pickedFile = nil
        password = ""
        confirmPassword = ""
        artifact = nil
        errorMessage = nil
    }
}
