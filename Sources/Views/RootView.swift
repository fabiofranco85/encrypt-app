//  RootView.swift
//  Hosts the Encrypt/Decrypt mode switch and the active screen.

import SwiftUI

struct RootView: View {
    @Binding var mode: AppMode
    let encryptViewModel: EncryptViewModel
    let decryptViewModel: DecryptViewModel

    @State private var showingAbout = false

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
            .navigationTitle("Quietbox")
            .navigationBarTitleDisplayMode(.inline)
            .background(backgroundGradient)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAbout = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .accessibilityLabel("About and privacy policy")
                }
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
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
