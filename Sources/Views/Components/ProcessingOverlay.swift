//  ProcessingOverlay.swift
//  Friendly progress overlay shown while the (intentionally slow) KDF runs.

import SwiftUI

struct ProcessingOverlay: View {
    var message: String = "Deriving key…"

    var body: some View {
        ZStack {
            Color.black.opacity(0.25).ignoresSafeArea()
            VStack(spacing: AppTheme.Spacing.medium) {
                ProgressView()
                    .controlSize(.large)
                Text(message)
                    .font(.callout)
            }
            .padding(AppTheme.Spacing.large)
            // Floating modal layer → Liquid Glass. Colors stay adaptive so the
            // label reads against whatever shows through the glass.
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
        .transition(.opacity)
    }
}
