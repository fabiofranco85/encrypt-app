//  DecryptView.swift
//  The Decrypt screen: paste an armored message or pick a .hushbox file,
//  enter the password, and recover the original text or file.

import SwiftUI
import UniformTypeIdentifiers

struct DecryptView: View {
    @Bindable var viewModel: DecryptViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                inputModePicker
                inputSection
                PasswordField(title: "Password", text: $viewModel.password)
                decryptButton

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
                ProcessingOverlay(message: "Decrypting…")
            }
        }
        .errorAlert(message: $viewModel.errorMessage)
    }

    private var inputModePicker: some View {
        Picker("Input", selection: $viewModel.inputMode.animation()) {
            ForEach(DecryptInputMode.allCases) { mode in
                Label(mode.title, systemImage: mode.systemImage).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    @ViewBuilder
    private var inputSection: some View {
        switch viewModel.inputMode {
        case .paste:
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text("Encrypted message").font(.subheadline).foregroundStyle(.secondary)
                TextEditor(text: $viewModel.pastedText)
                    .font(.system(.footnote, design: .monospaced))
                    .frame(minHeight: 140)
                    .padding(8)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                    .accessibilityLabel("Encrypted message to decrypt")
            }
        case .file:
            if let file = viewModel.pickedFile {
                SelectedFileRow(file: file) { viewModel.pickedFile = nil }
            } else {
                FilePickerButton(
                    title: "Choose a .hushbox file",
                    systemImage: "doc.badge.plus",
                    allowedTypes: [.hushbox, .data]
                ) { viewModel.pickedFile = $0 }
            }
        }
    }

    private var decryptButton: some View {
        PrimaryButton(title: "Decrypt", systemImage: "lock.open.fill", isBusy: viewModel.isWorking) {
            Task { await viewModel.decrypt() }
        }
        .disabled(!viewModel.canDecrypt)
        .opacity(viewModel.canDecrypt ? 1 : 0.5)
    }
}
