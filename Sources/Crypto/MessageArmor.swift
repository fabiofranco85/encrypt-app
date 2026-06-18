//  MessageArmor.swift
//  Base64 "PEM-like" wrapping for text artifacts so an encrypted message can be
//  pasted into chat/email and survive reflow.

import Foundation

enum MessageArmor {
    static let header = "-----BEGIN QUIETBOX MESSAGE-----"
    static let footer = "-----END QUIETBOX MESSAGE-----"
    private static let lineWidth = 64

    /// Wraps container bytes into an armored, copy-pasteable block.
    static func armor(_ data: Data) -> String {
        let base64 = data.base64EncodedString()
        let wrapped = stride(from: 0, to: base64.count, by: lineWidth).map { start -> String in
            let from = base64.index(base64.startIndex, offsetBy: start)
            let to = base64.index(from, offsetBy: lineWidth, limitedBy: base64.endIndex) ?? base64.endIndex
            return String(base64[from..<to])
        }
        return ([header] + wrapped + [footer]).joined(separator: "\n")
    }

    /// Parses an armored block back into container bytes.
    ///
    /// Tolerant of surrounding text, arbitrary whitespace/line wrapping, and a
    /// bare (header-less) Base64 string.
    /// - Throws: ``CryptoError/malformedArtifact`` if no valid Base64 is found.
    static func dearmor(_ string: String) throws -> Data {
        var body = string
        if let headerRange = body.range(of: header),
           let footerRange = body.range(of: footer) {
            body = String(body[headerRange.upperBound..<footerRange.lowerBound])
        }
        let keptScalars = body.unicodeScalars.filter {
            !CharacterSet.whitespacesAndNewlines.contains($0)
        }
        let compact = String(String.UnicodeScalarView(keptScalars))

        guard !compact.isEmpty, let data = Data(base64Encoded: compact) else {
            throw CryptoError.malformedArtifact
        }
        return data
    }
}
