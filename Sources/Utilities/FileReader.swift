//  FileReader.swift
//  Reads a (possibly security-scoped) picked URL into a PickedFile.

import Foundation

enum FileReader {
    /// Reads the contents of a picked file URL, handling security-scoped access.
    static func read(url: URL) throws -> PickedFile {
        let needsScope = url.startAccessingSecurityScopedResource()
        defer { if needsScope { url.stopAccessingSecurityScopedResource() } }
        let data = try Data(contentsOf: url)
        return PickedFile(filename: url.lastPathComponent, data: data)
    }
}
