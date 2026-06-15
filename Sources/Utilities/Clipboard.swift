//  Clipboard.swift
//  Copy helpers. Secrets are copied with a short expiration so they do not
//  linger on the system pasteboard indefinitely.

import UIKit
import UniformTypeIdentifiers

enum Clipboard {
    /// How long copied secrets remain on the pasteboard before auto-clearing.
    static let secretLifetime: TimeInterval = 90

    /// Copies text with an expiration (used for messages / decrypted text).
    static func copy(text: String) {
        let expiry = Date().addingTimeInterval(secretLifetime)
        UIPasteboard.general.setItems(
            [[UTType.utf8PlainText.identifier: text]],
            options: [.expirationDate: expiry]
        )
    }

    /// Copies raw artifact/file bytes under the given type, with expiration.
    static func copy(data: Data, type: UTType) {
        let expiry = Date().addingTimeInterval(secretLifetime)
        UIPasteboard.general.setItems(
            [[type.identifier: data]],
            options: [.expirationDate: expiry]
        )
    }
}
