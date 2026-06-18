//  PrimaryButton.swift
//  The prominent gradient call-to-action, with a busy state.

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let systemImage: String
    var isBusy: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.small) {
                if isBusy {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: systemImage)
                }
                Text(isBusy ? "Working…" : title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .foregroundStyle(.white)
        }
        // Liquid Glass prominent CTA, tinted with the Cipherbox brand color so the
        // purple identity survives the move from the old gradient fill.
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .tint(AppTheme.accent)
        .disabled(isBusy)
    }
}
