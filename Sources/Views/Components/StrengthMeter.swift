//  StrengthMeter.swift
//  Visualizes password strength. Communicates level by text, not color alone.

import SwiftUI

struct StrengthMeter: View {
    let strength: PasswordStrength

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.2))
                    Capsule()
                        .fill(AppTheme.strengthColor(strength.level))
                        .frame(width: geometry.size.width * strength.score)
                        .animation(.easeInOut(duration: 0.25), value: strength.score)
                }
            }
            .frame(height: 6)

            Text(strength.label)
                .font(.caption)
                .foregroundStyle(AppTheme.strengthColor(strength.level))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Password strength")
        .accessibilityValue(strength.label)
    }
}
