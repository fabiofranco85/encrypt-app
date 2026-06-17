# Testing Strategy

Goal: **everything that can be tested without a Mac/simulator is**, and the
native crypto is covered by a clearly separated integration suite.

## Two test targets

### 1. `CipherboxTests` — pure unit tests (no native dependency)

Run anywhere Xcode can build the app target; do not require libsodium to be
exercised (they use a `FakeCryptoEngine`). Coverage:

- **`CipherContainerCodecTests`** — encode→decode round trip; magic/version
  validation; rejects truncated input; header is treated as associated data;
  field byte-offsets are stable.
- **`InnerPayloadCodecTests`** — text and file payloads round-trip; Unicode
  filenames; empty data; rejects malformed input.
- **`MessageArmorTests`** — armor→dearmor round trip; tolerates added
  whitespace/line wrapping; accepts bare Base64; rejects garbage.
- **`ByteReaderWriterTests`** — big-endian integer read/write, bounds checks.
- **`PasswordStrengthTests`** — monotonic scoring; thresholds for empty / weak
  / fair / strong / excellent.
- **`CryptoServiceTests`** (with `FakeCryptoEngine`) — encrypt text → armored
  copy-only artifact; encrypt file → copy/share/save artifact with restored
  name; decrypt routes text vs file; wrong "password" → error; tamper → error.
- **`EncryptViewModelTests` / `DecryptViewModelTests`** — validation rules,
  state transitions (idle→working→result/error), allowed-action policy, that
  text artifacts never expose share/save.

### 2. `CipherboxIntegrationTests` — real crypto (requires libsodium)

- **`SodiumCryptoEngineTests`** — KDF determinism for fixed salt+params; KDF
  changes with salt; AEAD seal/open round trip; wrong key fails; nonce/salt
  sizes; `randomBytes` length + non-repetition.
- **`CryptoServiceRoundTripTests`** — full encrypt→decrypt with the *real*
  engine for both text and files, including a binary file payload and a wrong
  password.

## Conventions

- Arrange-Act-Assert; one behavior per test; descriptive names
  (`decrypt_withWrongPassword_throwsAuthenticationFailed`).
- Fixtures use obviously fake secrets (e.g. `"correct horse battery staple"`).
- No sleeps; async tests use `await`.
- Deterministic: the `FakeCryptoEngine` uses a reproducible transform so
  assertions are exact.

## Running

```bash
xcodegen generate
xcodebuild test -project Cipherbox.xcodeproj -scheme Cipherbox \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

The unit target is the fast inner loop; run the integration target before
shipping crypto changes.

## What we deliberately do not test

- libsodium internals (trusted dependency).
- SwiftUI rendering pixels (we test view-model logic instead).
