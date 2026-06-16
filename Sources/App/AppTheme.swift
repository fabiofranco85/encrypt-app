//  AppTheme.swift
//  Centralized colors, gradients, and spacing for a consistent, calm look.

import SwiftUI

enum AppTheme {
    static let accent = Color(red: 0.388, green: 0.286, blue: 0.901)
    static let accentSecondary = Color(red: 0.62, green: 0.36, blue: 0.95)

    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [accent, accentSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }

    static let cornerRadius: CGFloat = 18

    /// Color for a password-strength level (always paired with a text label so
    /// information is never conveyed by color alone).
    static func strengthColor(_ level: PasswordStrengthLevel) -> Color {
        switch level {
        case .empty: return .secondary
        case .weak: return .red
        case .fair: return .orange
        case .good: return .yellow
        case .strong: return .green
        }
    }
}
