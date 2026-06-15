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
                    .tint(.white)
                Text(message)
                    .font(.callout)
                    .foregroundStyle(.white)
            }
            .padding(AppTheme.Spacing.large)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
        .transition(.opacity)
    }
}
