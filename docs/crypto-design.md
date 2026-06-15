# Cryptographic Design

Hushbox protects text and files with a password. This document specifies the
exact scheme and the artifact format. **Changing any of this requires a format
version bump and a backward-compatible decoder.**

## Goals & threat model

- **Confidentiality + integrity** of user data at rest, protected by a password.
- Resist **offline brute force** of weak passwords (memory-hard KDF).
- Detect **tampering / corruption** (authenticated encryption).
- **On-device only.** No key escrow, no recovery. If the password is lost, the
  data is unrecoverable — by design.
- Out of scope: protecting against a compromised device/OS, shoulder-surfing,
  or coercion.

## Primitives

| Role | Algorithm | Notes |
|------|-----------|-------|
| Key derivation | **Argon2id** (libsodium `crypto_pwhash`) | RFC 9106 hybrid; memory-hard |
| Encryption | **XChaCha20-Poly1305-IETF** AEAD | 256-bit key, 192-bit nonce, 128-bit tag |
| Salt | 16 random bytes (`crypto_pwhash_SALTBYTES`) | unique per artifact |
| Nonce | 24 random bytes | unique per artifact; random is safe at this size |
| RNG | libsodium `randombytes` | CSPRNG |

Why Argon2id: it won the Password Hashing Competition and is the OWASP/IETF
top recommendation. It is memory-hard (defeats cheap GPU/ASIC parallelism that
weakens PBKDF2/bcrypt) and the hybrid `id` variant also resists side channels.

Why XChaCha20-Poly1305: AEAD gives confidentiality + integrity in one pass; the
extended 192-bit nonce makes random nonces collision-safe without a counter.

### Default KDF parameters

We default to libsodium's **INTERACTIVE** profile for responsive UX on a phone,
because each artifact already has a unique 16-byte salt and the data is local:

- `opsLimit = crypto_pwhash_OPSLIMIT_INTERACTIVE` (2)
- `memLimit = crypto_pwhash_MEMLIMIT_INTERACTIVE` (64 MiB)

These are **stored in the artifact**, so we can raise them later and still open
old artifacts. A "MODERATE" profile can be selected without changing the format.

## Key schedule

```
salt  = random(16)
key   = Argon2id(password, salt, opsLimit, memLimit) -> 32 bytes
nonce = random(24)
```

The 32-byte key is used directly as the XChaCha20-Poly1305 key. It is never
stored; only the salt + parameters are, so it is re-derived on decrypt.

## Inner payload (encrypted)

To keep metadata (like the original filename) confidential, we encrypt a small
**inner payload**, not the raw bytes. The inner payload is the AEAD plaintext:

```
+--------+------------------+-------------------------+------------------+
| kind   | filenameLength   | filename (UTF-8)        | data             |
| 1 byte | 2 bytes (BE)     | filenameLength bytes    | remaining bytes  |
+--------+------------------+-------------------------+------------------+
kind: 0x00 = text, 0x01 = file
text: filenameLength = 0; data = UTF-8 of the message
file: filename = original name (e.g. "report.pdf"); data = file bytes
```

## Container format (v1)

The container is what gets written to a `.hushbox` file or armored into text.
**Only the header is plaintext.** All secrets are inside `ciphertext`.

```
Offset  Size  Field        Value / meaning
0       4     magic        ASCII "HUSH"
4       1     version      0x01
5       1     kdfId        0x01 = Argon2id
6       1     cipherId     0x01 = XChaCha20-Poly1305-IETF
7       1     reserved     0x00
8       8     opsLimit     UInt64 big-endian
16      8     memLimit     UInt64 big-endian (bytes)
24      16    salt         random
40      24    nonce        random
64      ..    ciphertext   AEAD(inner payload) + 16-byte Poly1305 tag
```

The first 64 bytes (the header) are passed to the AEAD as **associated data**,
so any tampering with the parameters is also detected.

## Text armoring

Text artifacts are copy-only. The binary container is Base64-encoded and wrapped:

```
-----BEGIN HUSHBOX MESSAGE-----
<base64, wrapped at 64 columns>
-----END HUSHBOX MESSAGE-----
```

The decoder is whitespace-tolerant and also accepts a bare Base64 string, so a
pasted message survives email/chat reflow. Decrypting accepts either an armored
string or a raw `.hushbox` file.

## Failure behavior

- Wrong password → key derives but AEAD authentication fails →
  `CryptoError.authenticationFailed`. No plaintext is produced.
- Truncated/garbage/edited header → `CryptoError.malformedArtifact` or
  authentication failure.
- Unknown version/algorithm id → `CryptoError.unsupportedVersion`.

## Interoperability

The scheme is standard libsodium (`crypto_pwhash` + `crypto_aead_xchacha20-
poly1305_ietf`). Given the documented container layout, an artifact can be
decrypted by any libsodium binding, not just this app.

## Sources

- [RFC 9106 — Argon2](https://www.rfc-editor.org/rfc/rfc9106)
- [Libsodium password hashing](https://libsodium.gitbook.io/doc/password_hashing)
- [Libsodium AEAD — XChaCha20-Poly1305](https://libsodium.gitbook.io/doc/secret-key_cryptography/aead)
