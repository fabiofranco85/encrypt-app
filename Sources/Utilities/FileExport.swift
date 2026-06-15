//  FileExport.swift
//  Helpers for sharing (temp file URL) and saving (FileDocument) artifacts.

import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// A generic file document used by `.fileExporter` for "Save to Files".
struct ExportableDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.data] }

    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

/// Writes bytes to a uniquely-named temporary file so they can be shared via
/// `ShareLink`/the system share sheet with a meaningful filename.
enum TempFileStore {
    static func write(_ data: Data, filename: String) throws -> URL {
        let safeName = sanitize(filename)
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent(safeName)
        try data.write(to: url, options: .atomic)
        return url
    }

    private static func sanitize(_ filename: String) -> String {
        let trimmed = filename.trimmingCharacters(in: .whitespacesAndNewlines)
        let illegal = CharacterSet(charactersIn: "/\\:*?\"<>|")
        let cleaned = trimmed.components(separatedBy: illegal).joined(separator: "_")
        return cleaned.isEmpty ? "artifact" : cleaned
    }
}
