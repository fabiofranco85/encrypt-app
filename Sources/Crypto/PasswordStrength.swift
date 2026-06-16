//  PasswordStrength.swift
//  A lightweight, deterministic password-strength heuristic for the UI meter.
//  This is a UX aid, not a security guarantee — the KDF does the real work.

import Foundation

enum PasswordStrengthLevel: Int, CaseIterable, Sendable {
    case empty
    case weak
    case fair
    case good
    case strong

    var label: String {
        switch self {
        case .empty: return "Enter a password"
        case .weak: return "Weak"
        case .fair: return "Fair"
        case .good: return "Good"
        case .strong: return "Strong"
        }
    }
}

/// The result of evaluating a password.
struct PasswordStrength: Equatable, Sendable {
    let level: PasswordStrengthLevel
    /// Normalized 0...1 score for the meter fill.
    let score: Double
    /// Rough Shannon entropy estimate, in bits.
    let estimatedBits: Double

    var label: String { level.label }

    /// Estimates strength from the character pool size and length, with a small
    /// penalty for low character variety (e.g. "aaaaaaaa").
    static func evaluate(_ password: String) -> PasswordStrength {
        guard !password.isEmpty else {
            return PasswordStrength(level: .empty, score: 0, estimatedBits: 0)
        }

        var pool = 0
        let scalars = password.unicodeScalars
        if scalars.contains(where: { CharacterSet.lowercaseLetters.contains($0) }) { pool += 26 }
        if scalars.contains(where: { CharacterSet.uppercaseLetters.contains($0) }) { pool += 26 }
        if scalars.contains(where: { CharacterSet.decimalDigits.contains($0) }) { pool += 10 }
        if scalars.contains(where: { isSymbol($0) }) { pool += 32 }
        if scalars.contains(where: { $0.value > 127 }) { pool += 100 }
        pool = max(pool, 1)

        let uniqueRatio = Double(Set(scalars.map { $0.value }).count) / Double(scalars.count)
        let varietyPenalty = 0.5 + 0.5 * uniqueRatio // 0.5...1.0
        let bits = Double(scalars.count) * log2(Double(pool)) * varietyPenalty

        let level: PasswordStrengthLevel
        switch bits {
        case ..<28: level = .weak
        case ..<48: level = .fair
        case ..<72: level = .good
        default: level = .strong
        }

        return PasswordStrength(
            level: level,
            score: min(bits / 96.0, 1.0),
            estimatedBits: bits
        )
    }

    private static func isSymbol(_ scalar: Unicode.Scalar) -> Bool {
        guard scalar.value <= 127 else { return false }
        let isAlphanumeric = CharacterSet.alphanumerics.contains(scalar)
        let isSpace = CharacterSet.whitespaces.contains(scalar)
        return !isAlphanumeric && !isSpace
    }
}
