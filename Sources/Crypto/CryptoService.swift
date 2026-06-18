//  CryptoService.swift
//  The use-case layer: turns "encrypt this text/file" and "decrypt this" into
//  artifacts, composing the codecs with a CryptoEngine. Holds no state and no
//  secrets beyond the locals of each call.

import Foundation

/// Where to read an artifact from when decrypting.
enum DecryptSource: Equatable, Sendable {
    case armoredText(String)
    case container(Data)
}

/// High-level encrypt/decrypt operations.
struct CryptoService: Sendable {
    let engine: any CryptoEngine

    init(engine: any CryptoEngine) {
        self.engine = engine
    }

    /// File extension applied to encrypted file artifacts.
    static let fileExtension = "quietbox"

    // MARK: Encrypt

    /// Encrypts a text message into an armored, copy-only artifact.
    func encryptText(
        _ message: String,
        password: String,
        parameters: CryptoParameters = .interactive
    ) throws -> Artifact {
        let container = try seal(payload: .text(message), password: password, parameters: parameters)
        return Artifact(content: .text(MessageArmor.armor(container)))
    }

    /// Encrypts a file into a `.quietbox` artifact (copy / share / save).
    func encryptFile(
        data: Data,
        filename: String,
        password: String,
        parameters: CryptoParameters = .interactive
    ) throws -> Artifact {
        let container = try seal(
            payload: .file(named: filename, data: data),
            password: password,
            parameters: parameters
        )
        let outputName = "\(filename).\(Self.fileExtension)"
        return Artifact(content: .file(data: container, filename: outputName))
    }

    // MARK: Decrypt

    /// Decrypts an armored message or a `.quietbox` container, returning either
    /// recovered text (copy-only) or a recovered file (copy / share / save).
    func decrypt(_ source: DecryptSource, password: String) throws -> Artifact {
        guard !password.isEmpty else { throw CryptoError.emptyPassword }

        let raw: Data
        switch source {
        case .armoredText(let text):
            raw = try MessageArmor.dearmor(text)
        case .container(let data):
            raw = data
        }

        let container = try CipherContainerCodec.decode(raw)
        let associatedData = raw.prefix(CipherContainer.associatedDataLength)
        let key = try engine.deriveKey(
            password: password,
            salt: container.salt,
            parameters: container.parameters
        )
        let plaintext = try engine.open(
            ciphertext: container.ciphertext,
            nonce: container.nonce,
            key: key,
            associatedData: Data(associatedData)
        )
        let payload = try InnerPayloadCodec.decode(plaintext)

        switch payload.kind {
        case .text:
            return Artifact(content: .text(String(decoding: payload.data, as: UTF8.self)))
        case .file:
            let name = payload.filename.isEmpty ? "decrypted.bin" : payload.filename
            return Artifact(content: .file(data: payload.data, filename: name))
        }
    }

    // MARK: - Internals

    private func seal(
        payload: InnerPayload,
        password: String,
        parameters: CryptoParameters
    ) throws -> Data {
        guard !password.isEmpty else { throw CryptoError.emptyPassword }

        let salt = try engine.randomBytes(count: CryptoSizes.salt)
        let key = try engine.deriveKey(password: password, salt: salt, parameters: parameters)
        let associatedData = CipherContainerCodec.associatedData(parameters: parameters, salt: salt)
        let sealed = try engine.seal(
            plaintext: InnerPayloadCodec.encode(payload),
            key: key,
            associatedData: associatedData
        )
        let container = CipherContainer(
            parameters: parameters,
            salt: salt,
            nonce: sealed.nonce,
            ciphertext: sealed.ciphertext
        )
        return CipherContainerCodec.encode(container)
    }
}
