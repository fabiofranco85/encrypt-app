# Hushbox 🔒

[![CI](https://github.com/fabiofranco85/encrypt-app/actions/workflows/ci.yml/badge.svg)](https://github.com/fabiofranco85/encrypt-app/actions/workflows/ci.yml)

**Lock your words and files behind a password.**

Hushbox is an iPhone app that encrypts and decrypts **text** and **files** with
a password — entirely **on-device**. No accounts, no network, no telemetry.

- 🔐 **Strong by default:** Argon2id key derivation + XChaCha20-Poly1305
  authenticated encryption (libsodium).
- 📝 **Text:** encrypt a message into a copy-pasteable block (copy-only).
- 📎 **Files:** encrypt any file into a `.hushbox` artifact you can **copy,
  share, or save**.
- 🔓 **Decrypt:** paste a message or open a `.hushbox` file (also from the
  system share sheet). Recovered text is copy-only; recovered files can be
  copied, shared, or saved.
- ✨ **Thoughtful UX:** live password-strength meter, confirm-password to
  prevent lockouts, progress feedback for the (deliberately slow) KDF, haptics,
  full dark mode, Dynamic Type, and VoiceOver support.

## Why these algorithms?

Argon2id is the OWASP/IETF (RFC 9106) top recommendation for turning a password
into a key: it is *memory-hard*, defeating cheap GPU/ASIC brute force.
XChaCha20-Poly1305 is authenticated encryption, so tampering or a wrong password
fails loudly instead of producing garbage. See
[`docs/crypto-design.md`](docs/crypto-design.md) for the full scheme and the
artifact format.

## Project structure

| Path | What |
|------|------|
| `CLAUDE.md` | Working agreement + product contract |
| `docs/` | Research, crypto design, architecture, UX, testing |
| `project.yml` | XcodeGen project definition (build source of truth) |
| `Sources/` | App, Models, Crypto, ViewModels, Views, Utilities, Resources |
| `Tests/HushboxTests/` | Pure unit tests (no native dependency) |
| `Tests/HushboxIntegrationTests/` | Real-crypto round-trip tests |

## Build & run

Requires **macOS + Xcode 16+**. The Xcode project is generated from
`project.yml` (reproducible and reviewable).

```bash
brew install xcodegen          # one-time
xcodegen generate              # creates Hushbox.xcodeproj
open Hushbox.xcodeproj          # build & run on an iPhone 16 simulator
```

## Test

```bash
xcodegen generate
xcodebuild test \
  -project Hushbox.xcodeproj \
  -scheme Hushbox \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

The `HushboxTests` target is dependency-free (uses a deterministic fake engine)
and forms the fast inner loop. `HushboxIntegrationTests` exercises the real
libsodium engine end-to-end.

## A note on the build environment

This repository was authored in a Linux agent environment where the Apple
toolchain (Xcode/Swift iOS SDK) is unavailable, so it could not be compiled here.
The architecture deliberately isolates all platform/native code behind protocols
so the logic is fully covered by tests that run on any Mac with Xcode. See
[`docs/testing-strategy.md`](docs/testing-strategy.md).

## Export compliance

Hushbox uses standard, well-known cryptography (libsodium). When distributing
via the App Store you must answer Apple's export-compliance questions; set
`ITSAppUsesNonExemptEncryption` in `Info.plist` according to your distribution
and legal review.

## License

See repository.
