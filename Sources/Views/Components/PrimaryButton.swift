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
            .padding(.vertical, 16)
            .foregroundStyle(.white)
            .background(AppTheme.brandGradient, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
        .disabled(isBusy)
    }
}
