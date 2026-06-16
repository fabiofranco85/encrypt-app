# Architecture

## Layers

```
        ┌─────────────────────────────────────────────┐
  UI    │ Views (SwiftUI, @MainActor)                  │
        │  RootView, EncryptView, DecryptView, …       │
        └───────────────▲─────────────────────────────┘
                        │ binds to
        ┌───────────────┴─────────────────────────────┐
 State  │ ViewModels (@Observable, @MainActor)         │
        │  EncryptViewModel, DecryptViewModel          │
        └───────────────▲─────────────────────────────┘
                        │ calls (async)
        ┌───────────────┴─────────────────────────────┐
 Use    │ CryptoService (Sendable)                     │
 cases  │  encryptText / encryptFile / decrypt         │
        └───────────────▲─────────────────────────────┘
              │                         │
   ┌──────────┴─────────┐   ┌───────────┴──────────────┐
   │ Pure codecs        │   │ CryptoEngine (protocol)   │
   │ container / armor / │   │  SodiumCryptoEngine       │
   │ payload / strength  │   │  (libsodium, the only     │
   │ (no native dep)     │   │   native-touching code)   │
   └────────────────────┘   └───────────────────────────┘
```

## Why this shape

- **Testability:** the pure codecs and the `CryptoService` can be exercised
  with a `FakeCryptoEngine`, so the entire app logic is unit-testable without
  building libsodium. Only `SodiumCryptoEngineTests` needs the native lib.
- **Single crypto choke point:** all primitive calls go through `CryptoEngine`.
  Swapping/upgrading the primitive is a one-file change.
- **Secrets stay shallow:** passwords/plaintext are passed as locals down the
  call stack and not retained by services or view models beyond what the UI
  needs.

## Key types

| Type | Responsibility |
|------|----------------|
| `CryptoEngine` (protocol) | `deriveKey`, `seal`, `open`, `randomBytes` |
| `SodiumCryptoEngine` | libsodium implementation of `CryptoEngine` |
| `CipherContainer` / `CipherContainerCodec` | binary artifact format (v1) |
| `InnerPayload` / `InnerPayloadCodec` | encrypted metadata + data blob |
| `MessageArmor` | Base64 PEM-like wrapping for text artifacts |
| `CryptoService` | use cases: encrypt text/file, decrypt anything |
| `PasswordStrength` | heuristic strength scoring for the UI meter |
| `EncryptViewModel` / `DecryptViewModel` | `@Observable` presentation state |
| `Artifact` / `ArtifactKind` | result + which actions are allowed |

## Action policy (enforced in the model)

`Artifact.allowedActions` is the single source of truth for what the UI offers:

- text artifact → `[.copy]`
- file artifact → `[.copy, .share, .save]`

Views render only the actions present in this set, so the product rule
("text is copy-only") cannot be violated from the UI by accident.

## Concurrency

- Views & view models are `@MainActor`.
- `CryptoService.encrypt*/decrypt` are `async`; the Argon2 KDF runs on a
  background executor (`Task.detached` / nonisolated engine) so the UI stays
  responsive and shows a progress overlay.
- All value types crossing actor boundaries are `Sendable`.
