# App Store Connect submission checklist (Hushbox)

A do-this-in-order checklist for the steps that happen **in App Store Connect /
on Apple's side** — the parts that can't live in the repo. For building and
uploading the binary, see [`shipping-guide.md`](shipping-guide.md).

> Legend: ☐ = you do this in a browser / on your Mac. Items marked **decision**
> need a choice from you; the recommended answer for Hushbox is given.

---

## 0. One-time prerequisites

- ☐ **Apple Developer Program** membership — **$99/year**. Required for
  TestFlight and App Store. Enroll at <https://developer.apple.com/programs/>.
- ☐ Signed in to <https://appstoreconnect.apple.com> with that Apple ID.
- ℹ️ **Minimum iOS: 26.** Hushbox uses Liquid Glass, so only devices on iOS 26+
  can install it. Capture your App Store screenshots from an **iOS 26** simulator.

---

## 1. Create the app record

App Store Connect ▸ **Apps** ▸ **＋ New App**:

- ☐ **Platform:** iOS
- ☐ **Name:** `Hushbox` (must be unique across the App Store — have a backup
  name ready in case it's taken)
- ☐ **Primary language:** English (or your choice)
- ☐ **Bundle ID:** `com.hushbox.app` (register it first under *Certificates,
  Identifiers & Profiles ▸ Identifiers* if it isn't listed)
- ☐ **SKU:** any internal string, e.g. `hushbox-001`

---

## 2. Upload a build

- ☐ Follow [`shipping-guide.md`](shipping-guide.md) §3 (archive in Xcode ▸
  Distribute App ▸ App Store Connect ▸ Upload), or the CLI flow.
- ☐ Bump `CURRENT_PROJECT_VERSION` in `project.yml` for every new upload, then
  re-run `xcodegen generate`.
- ☐ Wait for the build to finish **processing** (a few minutes to ~1 hour) so it
  becomes selectable on the version page.

---

## 3. App listing / metadata

On the version page:

- ☐ **Screenshots** — required for **6.9"** (e.g. iPhone 16 Pro Max) and
  **6.7"** iPhone sizes. Capture from the simulator (**⌘S** saves to Desktop).
  Suggested shots: Encrypt (text), Encrypt (file → Copy/Share/Save), Decrypt,
  wrong-password error, the password-strength meter.
- ☐ **Description** — what it does + the "everything on-device, no accounts, no
  network" angle.
- ☐ **Keywords** — e.g. `encrypt, password, privacy, files, AES, secure, vault`.
- ☐ **Support URL** — required. A simple page or the (public) repo/readme link.
- ☐ **Marketing URL** — optional.
- ☐ **Promotional text** — optional (editable later without review).
- ☐ **Category** — *Utilities* (Primary). Secondary optional.
- ☐ **App icon** — already in the build (1024px, no alpha). Nothing to upload
  separately.
- ☐ **Age rating** — answer the questionnaire. Expected result: **4+** (no
  objectionable content).

---

## 4. Privacy

- ☐ **Privacy Policy URL** (App Information ▸ Privacy Policy) — **required for
  every app**, even ones that collect nothing. Paste:
  `https://gist.github.com/fabiofranco85/699d83b8182a251d8226ab15b05064dc`
  *(This matches `AppInfo.privacyPolicyURL` in the app — the app links the same
  policy from its **ⓘ About** sheet. If you edit `docs/privacy-policy.md`, update
  the gist too: `gh gist edit 699d83b8182a251d8226ab15b05064dc`.)*
- ☐ **App Privacy** ("nutrition label") — click **Get Started**, then
  **decision → select "No, we do not collect data from this app."** Hushbox
  processes everything on-device and transmits nothing, so "Data Not Collected"
  is the honest, correct answer. Save.

---

## 5. Export compliance (encryption)

Because the app implements real encryption, App Store Connect asks export
questions. `ITSAppUsesNonExemptEncryption` is already set to `true` in the
build, so it knows the encryption is **non-exempt** and will ask you to confirm
how it qualifies. For Hushbox:

- ☐ The encryption uses **standard, published algorithms** (Argon2id, ChaCha20)
  via libsodium — **not** proprietary. So no US CCATS is required.
- ☐ **France:** not distributing there (see §6), so **no French encryption
  declaration** is needed.
- ☐ **US BIS — the one external legal item.** Uploading to Apple is an *export
  from the United States*, so US export rules apply **regardless of which
  countries you sell in** (see the clarification note your developer left you).
  Hushbox is a free, mass-market product using standard crypto, which fits
  **License Exception ENC (§740.17(b)(1))**. The practical obligation is a short
  **annual self-classification report** to BIS. **Verify this for your
  situation** — start at Apple's guide and BIS:
  - <https://developer.apple.com/documentation/security/complying-with-encryption-export-regulations>
  - <https://www.bis.gov/learn-support/encryption-controls/annual-self-classification>

> This is a compliance question, not legal advice. The crypto choice and the
> `ITSAppUsesNonExemptEncryption=true` value are correct; the BIS report is the
> only paperwork that may apply.

---

## 6. Pricing & availability

- ☐ **Pricing:** Free (Pricing and Availability tab).
- ☐ **Availability — decision.** You said *not* the US for now. You can
  deselect the United States in the availability list. **Note:** distributing in
  *any* country still means the app is exported from Apple's US servers, so the
  US export rule in §5 still applies — deselecting the US storefront does **not**
  remove that obligation.

---

## 7. Submit

- ☐ Under **Build**, click **＋** and pick the processed build you validated on
  TestFlight.
- ☐ Confirm export compliance if re-asked.
- ☐ Choose release: **Automatic**, **Manual**, or **Scheduled**.
- ☐ **Add for Review ▸ Submit.**

Review usually takes a few hours to a couple of days. Rejections come with
specifics in the **Resolution Center** — fix, bump the build number, re-archive,
resubmit.

---

## Quick "is everything ready?" gate

- ☐ Build processed and selectable
- ☐ Screenshots (6.9" + 6.7")
- ☐ Description, keywords, support URL, category, age rating
- ☐ **Privacy Policy URL set** + App Privacy = Data Not Collected
- ☐ Export compliance answered (BIS self-classification verified)
- ☐ Pricing = Free, availability chosen
- ☐ Build selected → Submit
