//  UIModels.swift
//  Small value types shared by the view models and views.

import Foundation

/// What the user is encrypting.
enum SourceKind: String, CaseIterable, Identifiable, Sendable {
    case text
    case file

    var id: String { rawValue }
    var title: String { self == .text ? "Text" : "File" }
    var systemImage: String { self == .text ? "text.alignleft" : "doc" }
}

/// How the user supplies an artifact to decrypt.
enum DecryptInputMode: String, CaseIterable, Identifiable, Sendable {
    case paste
    case file

    var id: String { rawValue }
    var title: String { self == .paste ? "Paste" : "File" }
    var systemImage: String { self == .paste ? "doc.on.clipboard" : "doc" }
}

/// A file the user picked, read into memory.
struct PickedFile: Equatable, Sendable {
    var filename: String
    var data: Data

    var byteCount: Int { data.count }

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(byteCount), countStyle: .file)
    }
}
