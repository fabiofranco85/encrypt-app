# CLAUDE.md

Guidance for AI agents (and humans) working in this repository.

## What this is

**Hushbox** is an iOS (iPhone) app that encrypts and decrypts **text** and
**files** with a user-supplied password. Everything happens **on-device** — no
network, no accounts, no telemetry. The password never leaves memory and is
never written to disk or logs.

Tagline: *Lock your words and files behind a password.*

## Product requirements (the contract)

These are the immutable acceptance criteria. Do not regress them.

1. Encrypt **text** or a **file** using a password.
2. Decrypt a previously produced artifact using the password.
3. Generated **file** artifacts can be **copied, shared, and saved**.
4. Generated **text** artifacts can **only be copied to the clipboard**
   (no share, no save).
5. The same rules apply to *decrypted* output: decrypted text is copy-only;
   a decrypted file can be copied, shared, and saved.
6. Wrong password (or tampered data) fails loudly and safely — never produces
   garbage output silently.

## Crypto design (do not weaken)

- **KDF:** Argon2id (libsodium `crypto_pwhash`), RFC 9106 hybrid variant.
- **Cipher:** XChaCha20-Poly1305-IETF AEAD (24-byte random nonce, 128-bit tag).
- **Salt:** 16 random bytes per artifact. **Nonce:** 24 random bytes per artifact.
- KDF parameters (ops/mem limits) are stored *in the artifact* so future
  parameter changes stay backward-compatible.
- File names / metadata are encrypted (carried inside the AEAD plaintext),
  never in the clear container header.
- Full rationale: [`docs/crypto-design.md`](docs/crypto-design.md).

All crypto goes through the `CryptoEngine` protocol. The libsodium
implementation (`SodiumCryptoEngine`) is the only place that touches the native
library. **Never** call libsodium directly from view models or views.

## Architecture

- SwiftUI, Swift 6, strict concurrency.
- `@Observable` view models, `@MainActor`-isolated UI.
- MVVM: `Views` ⇄ `ViewModels` ⇄ `CryptoService` ⇄ `CryptoEngine`.
- Pure, deterministic logic (container codec, armor, payload, password
  strength) lives in `Sources/Crypto` and is unit-tested with **no** native
  dependency.
- Details: [`docs/architecture.md`](docs/architecture.md).

## Repository layout

```
project.yml              XcodeGen project definition (source of truth for the build)
CLAUDE.md                this file
README.md                human-facing overview + setup
docs/                    research + guidelines (read before coding)
Sources/
  App/                   @main entry, theme
  Models/                value types (container, payload, errors, results)
  Crypto/                engine protocol, sodium engine, codecs, service, strength
  ViewModels/            @Observable view models
  Views/                 SwiftUI screens + reusable components
  Utilities/             clipboard, haptics, file export, UTType, helpers
  Resources/             Assets, Info.plist
Tests/
  HushboxTests/          pure unit tests (no native dep) — run anywhere with Xcode
  HushboxIntegrationTests/  real-crypto round trips (require libsodium build)
```

## Build & test

This app is built with Xcode on macOS. The project is generated from
`project.yml` so it is reproducible and reviewable.

```bash
brew install xcodegen          # one-time
xcodegen generate              # produces Hushbox.xcodeproj from project.yml
open Hushbox.xcodeproj

# Tests (CLI):
xcodebuild test \
  -project Hushbox.xcodeproj \
  -scheme Hushbox \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

> Note: this repo is developed in a Linux CI/agent environment where the Swift
> Apple SDKs and Xcode are unavailable, so the build cannot be compiled here.
> Keep code changes conservative and well-typed; rely on the test suite design
> in [`docs/testing-strategy.md`](docs/testing-strategy.md). The pure unit tests
> are written to run without the native libsodium dependency.

## Conventions

- Follow [`docs/documentation-guidelines.md`](docs/documentation-guidelines.md)
  for doc comments and [`docs/ios-best-practices.md`](docs/ios-best-practices.md)
  for code style.
- Never log, print, or persist passwords or plaintext.
- Keep secret-bearing buffers (`Data`) local; do not stash them in singletons.
- New crypto behavior must be covered by tests before it ships.
- Conventional-ish commit subjects (e.g. `feat:`, `fix:`, `docs:`, `test:`).

## Working agreements for agents

1. Read `docs/` before changing behavior.
2. When you change the artifact/container format, bump the format version and
   keep decode backward-compatible. Add a round-trip test.
3. When you touch UX, keep accessibility (Dynamic Type, VoiceOver labels,
   contrast) intact — see [`docs/ux-design.md`](docs/ux-design.md).
4. Prefer adding a test that fails first, then make it pass.
