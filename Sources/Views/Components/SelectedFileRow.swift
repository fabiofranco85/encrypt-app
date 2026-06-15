//  SelectedFileRow.swift
//  Shows a chosen file with a button to clear the selection.

import SwiftUI

struct SelectedFileRow: View {
    let file: PickedFile
    var onRemove: () -> Void

    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: "doc.fill")
                .font(.title2)
                .foregroundStyle(AppTheme.accent)
            VStack(alignment: .leading) {
                Text(file.filename).font(.subheadline).lineLimit(1)
                Text(file.formattedSize).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
            }
            .accessibilityLabel("Remove file")
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
}
