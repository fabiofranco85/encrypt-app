---
title: Quietbox Privacy Policy
---

# Quietbox Privacy Policy

_Last updated: 16 June 2026_

Quietbox is an iPhone app that encrypts and decrypts text and files with a
password. This policy explains, plainly, what Quietbox does and does not do with
your information.

## The short version

**Quietbox does not collect any data.** Everything happens on your device.
There are no accounts, no servers, no network connections, no analytics, and no
tracking. We never see your password, your messages, or your files — they never
leave your iPhone.

## What we collect

**Nothing.** Quietbox has no backend and makes no network requests. We do not
collect, transmit, store, sell, or share any personal data or usage data.

## How your data is handled on your device

- **Passwords** are held in memory only for as long as it takes to derive a key
  and perform encryption or decryption. They are never written to disk, never
  logged, and never transmitted.
- **Text** you encrypt or decrypt is processed in memory. Encrypted text can be
  copied to your clipboard; that is handled by iOS, under your control.
- **Files** you encrypt or decrypt are processed on device. When you choose to
  **share** or **save** an artifact, Quietbox writes it to a location you pick
  (or hands it to the iOS share sheet) at your request. Temporary files created
  for sharing live in the app's sandboxed temporary directory and are managed by
  iOS.

Because all processing is on device and nothing is transmitted off the device,
none of this data is "collected" as defined by Apple's App Privacy guidelines.

## Cryptography

Quietbox uses well-known, published cryptography from the libsodium library:
Argon2id (RFC 9106) for password-based key derivation and
XChaCha20-Poly1305-IETF for authenticated encryption. The cryptographic
parameters and salts are stored inside each artifact so it can be decrypted
later with the correct password. **If you lose your password, your data cannot
be recovered — not by you, and not by us.**

## Permissions

Quietbox requests access to files only when you explicitly pick a file to
encrypt, or choose where to save a decrypted file. It does not request access to
your contacts, location, camera, microphone, photos library, or any other
sensitive data, and it has no network entitlement.

## Children's privacy

Quietbox does not collect data from anyone, including children.

## Changes to this policy

If this policy changes, the updated version will be posted at this URL with a new
"last updated" date.

## Contact

Questions about this policy? Contact the developer at
**fabiofranco.php@gmail.com**.
