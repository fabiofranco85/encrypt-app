//  UTType+Quietbox.swift
//  The exported uniform type for `.quietbox` artifacts.

import UniformTypeIdentifiers

extension UTType {
    /// Quietbox encrypted artifact (declared in Info.plist as exported type).
    static let quietbox = UTType(exportedAs: "com.cipherbox.cipher")
}
