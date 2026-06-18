# Cipherbox 🔒

[![CI](https://github.com/fabiofranco85/encrypt-app/actions/workflows/ci.yml/badge.svg)](https://github.com/fabiofranco85/encrypt-app/actions/workflows/ci.yml)

**Lock your words and files behind a password.**

Cipherbox is an iPhone app that encrypts and decrypts **text** and **files** with
a password — entirely **on-device**. No accounts, no network, no telemetry.

- 🔐 **Strong by default:** Argon2id key derivation + XChaCha20-Poly1305
  authenticated encryption (libsodium).
- 📝 **Text:** encrypt a message into a copy-pasteable block (copy-only).
- 📎 **Files:** encrypt any file into a `.cipherbox` artifact you can **copy,
  share, or save**.
- 🔓 **Decrypt:** paste a message or open a `.cipherbox` file (also from the
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
| `Tests/CipherboxTests/` | Pure unit tests (no native dependency) |
| `Tests/CipherboxIntegrationTests/` | Real-crypto round-trip tests |

## Build & run

Requires **macOS + Xcode 26+** (Cipherbox targets **iOS 26** and uses the Liquid
Glass design). The Xcode project is generated from `project.yml` (reproducible
and reviewable).

```bash
brew install xcodegen          # one-time
xcodegen generate              # creates Cipherbox.xcodeproj
open Cipherbox.xcodeproj          # build & run on an iPhone 16 simulator
```

## Test

```bash
xcodegen generate
xcodebuild test \
  -project Cipherbox.xcodeproj \
  -scheme Cipherbox \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

The `CipherboxTests` target is dependency-free (uses a deterministic fake engine)
and forms the fast inner loop. `CipherboxIntegrationTests` exercises the real
libsodium engine end-to-end.

## Ship it

Step-by-step instructions to run Cipherbox in the simulator, test it on your own
iPhone via TestFlight, and publish to the App Store (including the
encryption export-compliance and privacy steps this app needs) are in
[`docs/shipping-guide.md`](docs/shipping-guide.md).

## A note on the build environment

This repository was authored in a Linux agent environment where the Apple
toolchain (Xcode/Swift iOS SDK) is unavailable, so it could not be compiled here.
The architecture deliberately isolates all platform/native code behind protocols
so the logic is fully covered by tests that run on any Mac with Xcode. See
[`docs/testing-strategy.md`](docs/testing-strategy.md).

## Export compliance

Cipherbox implements standard, well-known cryptography (libsodium) on top of the
OS, so its encryption is **non-exempt**. `ITSAppUsesNonExemptEncryption` is set
to `true` in `Info.plist`, which streamlines App Store submission and implies a
French encryption declaration (if distributing in France) and US BIS
self-classification (mass-market, License Exception ENC). See
[`docs/shipping-guide.md`](docs/shipping-guide.md) §3.4 — and treat it as a
legal determination for your distribution, not legal advice.

## Privacy

Cipherbox collects no data — everything is on-device. The privacy policy lives at
[`docs/privacy-policy.md`](docs/privacy-policy.md) and is published publicly as a
[gist](https://gist.github.com/fabiofranco85/699d83b8182a251d8226ab15b05064dc)
(the URL used in App Store Connect and in the app's **About** sheet).

## License

[MIT](LICENSE).
