//  AppInfo.swift
//  App identity strings and external links surfaced in the About sheet.

import Foundation

/// Static, app-level metadata used by the UI (e.g. the About sheet).
enum AppInfo {
    /// Marketing version + build, read from the bundle (`1.0.0 (1)`).
    static var versionString: String {
        let version = bundleString("CFBundleShortVersionString") ?? "—"
        let build = bundleString("CFBundleVersion") ?? "—"
        return "\(version) (\(build))"
    }

    /// Public privacy-policy URL.
    ///
    /// App Store Review Guideline 5.1.1(i) requires a privacy policy linked both
    /// in App Store Connect metadata **and** inside the app. This points at the
    /// public gist copy of `docs/privacy-policy.md`.
    ///
    /// - Important: Paste this exact URL into App Store Connect ▸ App
    ///   Information ▸ Privacy Policy so the in-app and store links match. The
    ///   source of truth is `docs/privacy-policy.md`; if you edit it, also
    ///   update the gist (`gh gist edit 699d83b8182a251d8226ab15b05064dc`).
    static let privacyPolicyURL = URL(
        string: "https://gist.github.com/fabiofranco85/699d83b8182a251d8226ab15b05064dc"
    )!

    private static func bundleString(_ key: String) -> String? {
        Bundle.main.object(forInfoDictionaryKey: key) as? String
    }
}
