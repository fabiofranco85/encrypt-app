//  Artifact.swift
//  The output of an encrypt/decrypt operation, plus the single source of truth
//  for which actions the UI is allowed to offer.
//
//  Product rule: TEXT artifacts are copy-only; FILE artifacts can be copied,
//  shared, and saved. Encoding the policy here makes it impossible for the UI
//  to violate the rule by accident.

import Foundation

/// An action the user can take on a result.
enum ArtifactAction: String, CaseIterable, Sendable {
    case copy
    case share
    case save
}

/// The payload of a result.
enum ArtifactContent: Equatable, Sendable {
    /// Text shown to the user. Copy-only.
    case text(String)
    /// File bytes with a suggested filename. Copy / share / save.
    case file(data: Data, filename: String)
}

/// A finished result with its allowed actions.
struct Artifact: Identifiable, Equatable, Sendable {
    let id: UUID
    let content: ArtifactContent

    init(id: UUID = UUID(), content: ArtifactContent) {
        self.id = id
        self.content = content
    }

    /// Actions the UI may present, in canonical display order.
    var allowedActions: [ArtifactAction] {
        switch content {
        case .text:
            return [.copy]
        case .file:
            return [.copy, .share, .save]
        }
    }

    var isText: Bool {
        if case .text = content { return true }
        return false
    }
}
