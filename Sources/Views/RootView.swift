//  RootView.swift
//  Hosts the Encrypt/Decrypt mode switch and the active screen.

import SwiftUI

struct RootView: View {
    @Binding var mode: AppMode
    let encryptViewModel: EncryptViewModel
    let decryptViewModel: DecryptViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.medium) {
                modePicker

                Group {
                    switch mode {
                    case .encrypt:
                        EncryptView(viewModel: encryptViewModel)
                    case .decrypt:
                        DecryptView(viewModel: decryptViewModel)
                    }
                }
                .transition(.opacity)
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .navigationTitle("Hushbox")
            .navigationBarTitleDisplayMode(.inline)
            .background(backgroundGradient)
        }
    }

    private var modePicker: some View {
        Picker("Mode", selection: $mode.animation(.easeInOut)) {
            ForEach(AppMode.allCases) { mode in
                Label(mode.title, systemImage: mode.systemImage).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Choose Encrypt or Decrypt")
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [AppTheme.accent.opacity(0.08), .clear],
            startPoint: .top,
            endPoint: .center
        )
        .ignoresSafeArea()
    }
}
