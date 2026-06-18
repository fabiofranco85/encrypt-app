# Documentation Guidelines

How we document Cipherbox. Applies to source comments, docs, and commit messages.

## Principles

- **Document the *why*, not the obvious *what*.** Code says what it does; a
  comment should explain intent, trade-offs, invariants, or security
  reasoning.
- **Security-relevant decisions are always documented** (parameter choices,
  why a value is constant, what an invariant protects).
- Keep docs close to code; update them in the same change.

## Swift doc comments

Use Swift's `///` documentation comments on all non-trivial public and
internal types and methods. Follow Apple's markup:

```swift
/// Derives a symmetric key from a password using Argon2id.
///
/// The derivation is intentionally slow and memory-hard to resist
/// offline brute-force attacks. Parameters are stored in the artifact so
/// they can be increased later without breaking old artifacts.
///
/// - Parameters:
///   - password: The user-supplied secret. Never logged or persisted.
///   - salt: 16 random bytes unique to this artifact.
///   - parameters: Argon2id ops/mem limits.
/// - Returns: A 32-byte key suitable for XChaCha20-Poly1305.
/// - Throws: ``CryptoError/keyDerivationFailed`` if the KDF fails.
func deriveKey(password: String, salt: Data, parameters: CryptoParameters) throws -> Data
```

Rules:
- One-sentence summary line first, then details.
- Document every parameter, return value, and thrown error for non-trivial
  APIs. Use symbol links (```` ``Type/case`` ````) where helpful.
- Mark security caveats explicitly (e.g. "Never logged or persisted").

## File headers

Each source file starts with a short banner: the type's role and any
file-level invariant. No author/date lines (git owns that).

```swift
//  CipherContainer.swift
//  The on-disk/on-wire binary format for a Cipherbox artifact (v1).
//  Header fields are PLAINTEXT; all secrets live inside the AEAD ciphertext.
```

## Markdown docs (`docs/`)

- One topic per file; link between them.
- Lead with a short summary a newcomer can skim.
- Use tables for option/parameter matrices.
- Cite external sources at the bottom with links.

## Commit messages

- Imperative subject, ≤ 72 chars, conventional prefix:
  `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`.
- Body explains *why* when not obvious.

## What never goes in docs, comments, or commits

- Real passwords, keys, or plaintext samples.
- Secrets in fixtures must be clearly fake and labeled as test data.
