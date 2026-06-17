//  UTType+Cipherbox.swift
//  The exported uniform type for `.cipherbox` artifacts.

import UniformTypeIdentifiers

extension UTType {
    /// Cipherbox encrypted artifact (declared in Info.plist as exported type).
    static let cipherbox = UTType(exportedAs: "com.cipherbox.cipher")
}
