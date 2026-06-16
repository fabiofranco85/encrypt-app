//  EncryptView.swift
//  The Encrypt screen: choose text or file, set a password, produce an artifact.

import SwiftUI
import UniformTypeIdentifiers

struct EncryptView: View {
    @Bindable var viewModel: EncryptViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                sourcePicker
                inputSection
                passwordSection
                encryptButton

                if let artifact = viewModel.artifact {
                    ResultCard(artifact: artifact) { viewModel.dismissResult() }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.vertical, AppTheme.Spacing.medium)
            .animation(.easeInOut, value: viewModel.artifact)
        }
        .scrollDismissesKeyboard(.interactively)
        .overlay {
            if viewModel.isWorking {
                ProcessingOverlay(message: "Encrypting…")
            }
        }
        .errorAlert(message: $viewModel.errorMessage)
    }

    private var sourcePicker: some View {
        Picker("What to encrypt", selection: $viewModel.sourceKind.animation()) {
            ForEach(SourceKind.allCases) { kind in
                Label(kind.title, systemImage: kind.systemImage).tag(kind)
            }
        }
        .pickerStyle(.segmented)
    }

    @ViewBuilder
    private var inputSection: some View {
        switch viewModel.sourceKind {
        case .text:
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text("Message").font(.subheadline).foregroundStyle(.secondary)
                TextEditor(text: $viewModel.messageText)
                    .frame(minHeight: 140)
                    .padding(8)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                    .accessibilityLabel("Message to encrypt")
            }
        case .file:
            if let file = viewModel.pickedFile {
                SelectedFileRow(file: file) { viewModel.pickedFile = nil }
            } else {
                FilePickerButton(
                    title: "Choose a file",
                    systemImage: "doc.badge.plus",
                    allowedTypes: [.item]
                ) { viewModel.pickedFile = $0 }
            }
        }
    }

    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            PasswordField(title: "Password", text: $viewModel.password, textContentType: .newPassword)
            StrengthMeter(strength: viewModel.passwordStrength)

            PasswordField(title: "Confirm password", text: $viewModel.confirmPassword, textContentType: .newPassword)
            if !viewModel.passwordsMatch {
                Label("Passwords don’t match", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
    }

    private var encryptButton: some View {
        PrimaryButton(title: "Encrypt", systemImage: "lock.fill", isBusy: viewModel.isWorking) {
            Task { await viewModel.encrypt() }
        }
        .disabled(!viewModel.canEncrypt)
        .opacity(viewModel.canEncrypt ? 1 : 0.5)
    }
}
