# App Store listing — copy-paste fields (Quietbox v1.0)

Everything to paste into **App Store Connect** when creating the listing. Character
limits are noted; current drafts are within them. Pair this with
[`app-store-connect-checklist.md`](app-store-connect-checklist.md) for the click-path.

---

## Name & subtitle

- **App Name** (≤30): `Quietbox`
- **Subtitle** (≤30): `Encrypt text & files, offline`

## Promotional text (≤170, editable anytime without review)

```
Lock your words and files behind a password — entirely on your iPhone. No accounts, no servers, no tracking. Strong Argon2id + XChaCha20 encryption, built in.
```

## Keywords (≤100 total, comma-separated, no spaces, don't repeat the name/category)

```
encrypt,decrypt,password,secure,private,privacy,vault,cipher,lock,offline,file,secret,protect,AES
```

## Description (≤4000)

```
Quietbox locks your private words and files behind a password — and nothing else. No accounts to create, no servers to trust, no internet connection required. Everything happens on your iPhone, and your password never leaves it.

WHAT IT DOES
• Encrypt any text or file with a password.
• Decrypt it later — on any iPhone with Quietbox and the same password.
• Encrypted text becomes a block you can copy and paste anywhere: a note, a message, an email.
• Encrypted files become a .quietbox artifact you can copy, share, or save.
• Open a .quietbox file from the Files app or a share sheet to decrypt it.

PRIVATE BY DESIGN
• 100% on-device. No accounts. No network. No analytics. No tracking.
• Your password lives in memory only long enough to do the work — never written to disk, never logged, never sent anywhere.
• Because there is no backend, no one — including the developer — can see your data or recover it for you.

STRONG, MODERN ENCRYPTION
• Argon2id (RFC 9106) turns your password into a key and resists brute-force cracking.
• XChaCha20-Poly1305 authenticated encryption protects and verifies your data.
• A wrong password or tampered data fails loudly and safely — Quietbox never hands you garbage output.

THOUGHTFUL DETAILS
• Live password-strength meter and confirm-password to prevent lockouts.
• Progress feedback for the deliberately slow key derivation.
• Full Dark Mode, Dynamic Type, and VoiceOver support.
• Built for the latest iPhone look with the new Liquid Glass design.

IMPORTANT
If you lose your password, your data cannot be recovered. Keep it somewhere safe — Quietbox holds no keys and has no way to reset it. That is exactly what makes it private.

Lock your words and files behind a password. That's Quietbox.
```

## URLs

- **Support URL** (required): `https://gist.github.com/fabiofranco85/e2736f132e5bdfc37143ee962b2167e5`
- **Privacy Policy URL** (required): `https://gist.github.com/fabiofranco85/699d83b8182a251d8226ab15b05064dc`
- **Marketing URL** (optional): leave blank, or reuse the support URL.

## Category

- **Primary:** Utilities
- **Secondary** (optional): Productivity

## Pricing & availability

- **Price:** Free (no in-app purchases).
- **Availability:** your choice. Note: any distribution still triggers US export rules (see checklist §5) — restricting storefronts does not remove that.

---

## App Privacy ("nutrition label")

- Click **Get Started** → answer **"No, we do not collect data from this app."**
- Result: **Data Not Collected.** (True — all processing is on-device, no network.)

## Age rating

Answer **None / No** to every content question (no violence, no mature/suggestive
content, no profanity, no gambling, no contests, etc.). Also:
- **Unrestricted web access:** No
- **Made for Kids:** No

Expected result: **4+**.

## Export compliance (encryption)

Export compliance is answered in App Store Connect (the Info.plist does **not**
declare `ITSAppUsesNonExemptEncryption` — that caused upload error 90592). When
App Store Connect asks:
- Uses encryption: **Yes**
- Uses only exemptions (OS-only / HTTPS / authentication / DRM): **No** — Quietbox
  encrypts arbitrary user data with its own standard algorithms.
- Proprietary/non-standard algorithms: **No** → **no US CCATS needed.**
- Distributing in France: **No** → **no French declaration needed.**
- Remaining item: the **US BIS year-end self-classification report** under License
  Exception ENC. See [`app-store-connect-checklist.md`](app-store-connect-checklist.md) §5
  and verify for your situation.

---

## App Review Information

- **Sign-in required:** No (there are no accounts).
- **Demo account:** not applicable.
- **Contact:** your name, phone, and email (e.g. fabiofranco.php@gmail.com).
- **Notes** (paste this):

```
Quietbox works fully offline with no account — there is nothing to sign into, and the app makes no network requests.

To test encryption → decryption (text):
1. On the Encrypt tab, keep "Text" selected and type any message, e.g. "hello world".
2. Enter the same password in both fields, e.g. "Test1234!".
3. Tap Encrypt, then tap Copy to copy the encrypted block.
4. Switch to the Decrypt tab, keep "Paste" selected, and paste the block.
5. Enter the same password and tap Decrypt — the original message appears.

To test a file:
1. On Encrypt choose "File", pick any file, set a password, tap Encrypt.
2. Save or Share the resulting .quietbox artifact.
3. Decrypt it from the Decrypt tab's "File" option, or by opening the .quietbox file from the Files app.

A wrong password intentionally fails with an error rather than producing output — this is the expected, safe behavior. No data leaves the device.
```

---

## Screenshots (required)

Capture from an **iOS 26** iPhone simulator, **portrait**. For an iPhone-only app you
need the **6.9" iPhone** set (e.g. iPhone 16 Pro Max / 17 Pro Max, **1320 × 2868**);
smaller sizes are derived automatically. 3–10 images; suggested 5:

| # | Screen | Suggested caption |
|---|--------|-------------------|
| 1 | Encrypt (text) with a filled message + strong-password meter | "Encrypt anything with a password" |
| 2 | Result card with the glass Copy / Share / Save buttons | "Copy, share, or save — your choice" |
| 3 | Decrypt screen | "Decrypt with the same password" |
| 4 | Wrong-password error | "Wrong password fails safely — never garbage" |
| 5 | About sheet | "100% on-device. No accounts. No tracking." |

Capture command (per screen, after navigating there):
```bash
xcrun simctl io booted screenshot ~/Desktop/quietbox-01.png
```

## What's New

Not required for the first release. For later updates, summarize changes here (≤4000).
