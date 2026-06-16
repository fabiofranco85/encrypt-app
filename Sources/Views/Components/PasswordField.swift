//  PasswordField.swift
//  Secure text entry with a reveal toggle.

import SwiftUI

struct PasswordField: View {
    let title: String
    @Binding var text: String
    var textContentType: UITextContentType? = .password

    @State private var isRevealed = false

    var body: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            Group {
                if isRevealed {
                    TextField(title, text: $text)
                } else {
                    SecureField(title, text: $text)
                }
            }
            .textContentType(textContentType)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .submitLabel(.done)

            Button {
                isRevealed.toggle()
            } label: {
                Image(systemName: isRevealed ? "eye.slash.fill" : "eye.fill")
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel(isRevealed ? "Hide password" : "Show password")
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
}
