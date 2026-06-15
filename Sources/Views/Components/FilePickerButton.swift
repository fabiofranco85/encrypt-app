//  FilePickerButton.swift
//  A button that presents the system file importer and returns a read file.

import SwiftUI
import UniformTypeIdentifiers

struct FilePickerButton: View {
    let title: String
    let systemImage: String
    let allowedTypes: [UTType]
    let onPick: (PickedFile) -> Void

    @State private var isPresented = false
    @State private var importError: String?

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
        .fileImporter(
            isPresented: $isPresented,
            allowedContentTypes: allowedTypes,
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                do {
                    onPick(try FileReader.read(url: url))
                } catch {
                    importError = "Couldn’t read that file."
                }
            case .failure:
                importError = "Couldn’t open the file picker."
            }
        }
        .alert("File error", isPresented: .constant(importError != nil)) {
            Button("OK") { importError = nil }
        } message: {
            Text(importError ?? "")
        }
    }
}
