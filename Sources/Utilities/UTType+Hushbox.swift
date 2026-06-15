//  UTType+Hushbox.swift
//  The exported uniform type for `.hushbox` artifacts.

import UniformTypeIdentifiers

extension UTType {
    /// Hushbox encrypted artifact (declared in Info.plist as exported type).
    static let hushbox = UTType(exportedAs: "com.hushbox.cipher")
}
