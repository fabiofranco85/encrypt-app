//  CipherboxApp.swift
//  App entry point. Wires up the production crypto engine and routes `.cipherbox`
//  files opened from outside the app into the Decrypt screen.

import SwiftUI

/// Top-level screen selection.
enum AppMode: String, CaseIterable, Identifiable, Sendable {
    case encrypt
    case decrypt

    var id: String { rawValue }
    var title: String { self == .encrypt ? "Encrypt" : "Decrypt" }
    var systemImage: String { self == .encrypt ? "lock.fill" : "lock.open.fill" }
}

@main
struct CipherboxApp: App {
    @State private var mode: AppMode = .encrypt
    @State private var encryptViewModel: EncryptViewModel
    @State private var decryptViewModel: DecryptViewModel

    init() {
        let service = CryptoService(engine: SodiumCryptoEngine())
        _encryptViewModel = State(initialValue: EncryptViewModel(service: service))
        _decryptViewModel = State(initialValue: DecryptViewModel(service: service))
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                mode: $mode,
                encryptViewModel: encryptViewModel,
                decryptViewModel: decryptViewModel
            )
            .tint(AppTheme.accent)
            .onOpenURL { url in
                // A `.cipherbox` file was opened from Files / a share sheet.
                Task { @MainActor in
                    guard let file = try? FileReader.read(url: url) else { return }
                    decryptViewModel.load(file: file)
                    mode = .decrypt
                }
            }
        }
    }
}
