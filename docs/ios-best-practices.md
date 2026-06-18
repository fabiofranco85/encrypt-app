# iOS Development Best Practices (2026)

Research-backed conventions this project follows. Sources are listed at the
bottom. Targeting **iOS 17+**, **Swift 6**, **Xcode 16+**.

## Language & concurrency

- **Swift 6 strict concurrency.** Enable complete checking. Data races are
  compile-time errors via `Sendable` + actor isolation. Value types crossing
  isolation boundaries must be `Sendable`.
- **`async`/`await` over completion handlers.** No nested callbacks. Long /
  CPU-bound work (Argon2 KDF) runs off the main actor.
- **`@MainActor` for UI.** Views and view models that drive UI are main-actor
  isolated. Heavy work hops to a background executor and returns results.
- **Actors / Sendable services for shared mutable state.** Our crypto engine
  is stateless and `Sendable`; no shared mutable state is exposed.

## State & architecture

- **`@Observable` macro** (Observation framework) for view-model state — not
  the legacy `ObservableObject`/`@Published`. Less boilerplate, granular
  re-renders based on exactly which properties a view reads.
- **MVVM**, sized to the app: Views are dumb and declarative; ViewModels own
  presentation state and orchestration; a `CryptoService` owns the use cases;
  a `CryptoEngine` owns primitives.
- **Dependency injection** via initializers (protocol-typed) so view models can
  be tested with fakes. No global singletons for logic.
- **Modularize with Swift Package Manager.** Keep pure logic free of UIKit so
  it is portable and testable.

## Error handling

- Typed domain errors (`CryptoError`) mapped to **user-facing, non-technical**
  messages at the view-model boundary. Never surface raw errors or stack traces.
- Centralize presentation: view models expose an optional `alert`/`errorState`
  the view renders. Avoid scattered `do/catch` in views.
- **Fail safe:** an authentication/integrity failure must never yield partial
  or garbage plaintext.

## Security (this app's core)

- **On-device only.** No networking entitlement, no analytics, no logging of
  secrets. The app works fully in airplane mode.
- Never `print`/log passwords or plaintext, even in DEBUG.
- Keep secret buffers local and short-lived; don't retain them in long-lived
  objects. Avoid unnecessary copies of plaintext.
- Use the system clipboard with an **expiration** for copied secrets so they do
  not linger indefinitely.
- Use platform crypto (libsodium) — never hand-roll primitives.

## UX, accessibility & platform fit

- **Human Interface Guidelines:** native controls, SF Symbols, system
  materials, respect safe areas and Dynamic Type.
- **Accessibility is non-negotiable:** VoiceOver labels/hints on every
  interactive element, Dynamic Type support, sufficient contrast, no
  color-only signaling (pair color with text/icon).
- **Haptics** for meaningful state changes (success/failure) via
  `UINotificationFeedbackGenerator`.
- **Dark mode** and large-text layouts must both look intentional.
- Show progress for operations that take >100 ms (Argon2 is deliberately slow).

## Files & sharing

- **`ShareLink`** / `UIActivityViewController` for sharing file artifacts.
- **`.fileExporter`** for "Save to Files".
- **`.fileImporter`** for picking files/artifacts to process; access
  security-scoped URLs with `startAccessingSecurityScopedResource()`.
- Declare a custom **exported UTType** (`com.cipherbox.cipher`, extension
  `.quietbox`) and `CFBundleDocumentTypes` so artifacts open back into the app.

## Testing

- **XCTest**; fast, deterministic unit tests for all pure logic.
- Inject fakes through protocols; do not require the simulator for logic tests.
- Separate **integration tests** that exercise the real native crypto.
- Property/round-trip style tests for serialization and encryption.

## Project hygiene

- Generate the Xcode project from **XcodeGen `project.yml`** so the build is
  reproducible and diffs are reviewable (a hand-edited `.pbxproj` is not).
- Keep `Info.plist` keys minimal and intentional.
- SwiftLint-friendly style; small files; one primary type per file.

## Sources

- [Swift Best Practices Every iOS Developer Should Know in 2026 — Halil Özel](https://halilozel1903.medium.com/swift-best-practices-every-ios-developer-should-know-in-2026-3062455db4aa)
- [How to Optimize iOS Apps for Speed and Stability in 2026 — Forasoft](https://www.forasoft.com/blog/article/ios-app-optimization-best-practices)
- [Mastering SwiftUI Concurrency: Scalable iOS Apps Guide 2026 — Zignuts](https://www.zignuts.com/blog/mastering-swiftui-concurrency-scalable-ios-app)
- [Swift 6 iOS Development 2026 — Softaims](https://softaims.com/blog/swift-ios-development-guide-2026)
- [swift-sodium — jedisct1](https://github.com/jedisct1/swift-sodium)
- [Libsodium password hashing documentation](https://libsodium.gitbook.io/doc/password_hashing)
