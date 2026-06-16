//  ResultCard.swift
//  Shows an encrypt/decrypt result and offers ONLY the actions the artifact
//  allows (text = copy-only; file = copy / share / save).

import SwiftUI
import UniformTypeIdentifiers

struct ResultCard: View {
    let artifact: Artifact
    var onDismiss: () -> Void = {}

    @State private var copied = false
    @State private var showExporter = false
    @State private var shareURL: URL?
    @State private var exportMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            header
            preview
            actions
        }
        .padding(AppTheme.Spacing.medium)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay(alignment: .top) { copiedToast }
        .onAppear(perform: prepareShareIfNeeded)
        .fileExporter(
            isPresented: $showExporter,
            document: ExportableDocument(data: fileInfo?.data ?? Data()),
            contentType: exportContentType,
            defaultFilename: exportBaseName
        ) { result in
            if case .success = result {
                Task { @MainActor in Haptics.success() }
            } else {
                exportMessage = "Couldn’t save the file."
            }
        }
        .alert(
            "Save error",
            isPresented: Binding(get: { exportMessage != nil }, set: { if !$0 { exportMessage = nil } })
        ) {
            Button("OK", role: .cancel) { exportMessage = nil }
        } message: {
            Text(exportMessage ?? "")
        }
    }

    // MARK: Sections

    private var header: some View {
        HStack {
            Label(headerTitle, systemImage: headerIcon)
                .font(.headline)
            Spacer()
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Dismiss result")
        }
    }

    @ViewBuilder
    private var preview: some View {
        switch artifact.content {
        case .text(let text):
            ScrollView {
                Text(text)
                    .font(.system(.footnote, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 180)
            .padding(AppTheme.Spacing.small)
            .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))

        case .file(let data, let filename):
            HStack(spacing: AppTheme.Spacing.medium) {
                Image(systemName: "doc.fill")
                    .font(.largeTitle)
                    .foregroundStyle(AppTheme.accent)
                VStack(alignment: .leading) {
                    Text(filename).font(.subheadline).lineLimit(1)
                    Text(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(AppTheme.Spacing.small)
            .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private var actions: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            ForEach(artifact.allowedActions, id: \.self) { action in
                actionView(for: action)
            }
        }
    }

    @ViewBuilder
    private func actionView(for action: ArtifactAction) -> some View {
        switch action {
        case .copy:
            Button(action: copy) { ActionChip(title: "Copy", systemImage: "doc.on.doc") }
        case .share:
            if let shareURL {
                ShareLink(item: shareURL) { ActionChip(title: "Share", systemImage: "square.and.arrow.up") }
            }
        case .save:
            Button { showExporter = true } label: { ActionChip(title: "Save", systemImage: "tray.and.arrow.down") }
        }
    }

    @ViewBuilder
    private var copiedToast: some View {
        if copied {
            Label("Copied", systemImage: "checkmark.circle.fill")
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.green, in: Capsule())
                .foregroundStyle(.white)
                .offset(y: -14)
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    // MARK: Actions logic

    @MainActor
    private func copy() {
        switch artifact.content {
        case .text(let text):
            Clipboard.copy(text: text)
        case .file(let data, let filename):
            Clipboard.copy(data: data, type: contentType(forExtension: (filename as NSString).pathExtension))
        }
        Haptics.tap()
        withAnimation { copied = true }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            withAnimation { copied = false }
        }
    }

    @MainActor
    private func prepareShareIfNeeded() {
        guard let info = fileInfo, shareURL == nil else { return }
        shareURL = try? TempFileStore.write(info.data, filename: info.filename)
    }

    // MARK: Derived values

    private var fileInfo: (data: Data, filename: String)? {
        if case let .file(data, filename) = artifact.content { return (data, filename) }
        return nil
    }

    private var headerTitle: String {
        artifact.isText ? "Result" : "File ready"
    }

    private var headerIcon: String {
        artifact.isText ? "text.alignleft" : "doc.badge.gearshape"
    }

    private var exportContentType: UTType {
        guard let filename = fileInfo?.filename else { return .data }
        return contentType(forExtension: (filename as NSString).pathExtension)
    }

    private var exportBaseName: String {
        guard let filename = fileInfo?.filename else { return "artifact" }
        let base = (filename as NSString).deletingPathExtension
        return base.isEmpty ? filename : base
    }

    private func contentType(forExtension ext: String) -> UTType {
        guard !ext.isEmpty else { return .data }
        if ext.lowercased() == CryptoService.fileExtension { return .hushbox }
        return UTType(filenameExtension: ext) ?? .data
    }
}

/// Shared styling for a secondary action button.
private struct ActionChip: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.medium))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(AppTheme.accent)
    }
}
