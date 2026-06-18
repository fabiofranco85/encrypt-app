//  AboutView.swift
//  Lightweight About / Privacy sheet. Hosts the in-app privacy-policy link
//  required by App Store Review Guideline 5.1.1(i).

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    header
                }

                Section {
                    Text("Quietbox encrypts and decrypts your text and files entirely on this device. No accounts, no network, no telemetry. Your password never leaves memory.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Link(destination: AppInfo.privacyPolicyURL) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                    .accessibilityHint("Opens the Quietbox privacy policy in your browser")

                    LabeledContent("Version", value: AppInfo.versionString)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 44))
                .foregroundStyle(AppTheme.brandGradient)
                .accessibilityHidden(true)
            Text("Quietbox")
                .font(.title2.bold())
            Text("Lock your words and files behind a password.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.small)
        .listRowBackground(Color.clear)
    }
}
