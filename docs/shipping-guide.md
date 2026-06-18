# Shipping Quietbox: Simulator → TestFlight → App Store

A practical, end-to-end guide to run Quietbox locally, test it on your own
iPhone via TestFlight, and publish it to the App Store.

> Quietbox is generated from `project.yml` with **XcodeGen** and uses
> **Argon2id + XChaCha20-Poly1305** (libsodium). Those two facts add a couple of
> steps you wouldn't have in a plain template app — they're called out below.

---

## 0. Prerequisites (one-time)

| Need | Notes |
|------|-------|
| A **Mac** | Apple Silicon or Intel, on a current macOS. |
| **Xcode 26+** | **Required** — Quietbox targets **iOS 26** and uses Liquid Glass, so it needs the iOS 26 SDK. Install from the Mac App Store, then run it once to finish component setup. |
| **Command Line Tools** | `xcode-select --install` (usually installed with Xcode). |
| **Homebrew** | <https://brew.sh> — used to install XcodeGen. |
| **XcodeGen** | `brew install xcodegen` |
| **Apple ID** | Required for any on-device run. |
| **Apple Developer Program** | **$99/year.** Required for TestFlight and App Store. *Not* required for the simulator, and only barely needed for running on your own device (a free Apple ID works for 7-day dev builds). |

Accept the Xcode license once if prompted: `sudo xcodebuild -license accept`.

---

## 1. Run in the iOS Simulator

This is the fastest loop and needs **no** paid account or signing.

### 1a. Generate the project

From the repo root:

```bash
xcodegen generate      # creates Quietbox.xcodeproj from project.yml
open Quietbox.xcodeproj
```

> Re-run `xcodegen generate` any time `project.yml` or the file layout changes.
> The `.xcodeproj` is git-ignored on purpose — `project.yml` is the source of
> truth.

### 1b. Run

1. In Xcode's toolbar, set the **scheme** to `Quietbox` (it should be selected
   automatically).
2. Pick a simulated device from the run-destination menu, e.g.
   **iPhone 16**. (If none are installed: *Xcode ▸ Settings ▸ Components* and
   download a simulator runtime.)
3. Press **⌘R** (Product ▸ Run).

The first build resolves the **swift-sodium** Swift Package — give it a minute.

### 1c. Smoke-test the core flows

- **Encrypt text** → tap **Copy** (text artifacts are copy-only by design).
- **Encrypt a file** (use the Files app / Photos to have something to pick) →
  try **Copy**, **Share**, and **Save**.
- **Decrypt**: paste the armored text back, or open the saved `.quietbox` file →
  confirm you get the original back.
- **Wrong password** → confirm it fails with a friendly error, not garbage.

### 1d. (Optional) Run the test suite from the CLI

```bash
xcodebuild test \
  -project Quietbox.xcodeproj \
  -scheme Quietbox \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

This is exactly what CI runs (47 tests: pure unit + real-crypto integration).

---

## 2. Run on your real iPhone (developer build)

Great for checking haptics, the share sheet, "Open in Quietbox", and real
performance of the (intentionally slow) Argon2id KDF.

### 2a. Set your signing team

1. Open `Quietbox.xcodeproj`, select the **Quietbox** target ▸ **Signing &
   Capabilities**.
2. Check **Automatically manage signing**.
3. Choose your **Team** (your Apple ID's personal team works for development).
4. If the bundle id `com.cipherbox.app` is taken (it must be globally unique for
   distribution), change it — e.g. `com.yourname.quietbox` — in
   **`project.yml`** under `PRODUCT_BUNDLE_IDENTIFIER`, then re-run
   `xcodegen generate`. Editing `project.yml` (not the Xcode UI) keeps the
   change from being wiped on regeneration.

### 2b. Plug in / pair the device

1. Connect the iPhone by cable (or set up wireless debugging via
   *Window ▸ Devices and Simulators*).
2. On the iPhone, tap **Trust** and enter your passcode.
3. Enable **Developer Mode**: *Settings ▸ Privacy & Security ▸ Developer Mode*,
   toggle on, and restart when prompted.

### 2c. Run

1. Select your iPhone as the run destination in Xcode.
2. Press **⌘R**.
3. First launch will fail to open with an "Untrusted Developer" message —
   approve it on the device: *Settings ▸ General ▸ VPN & Device Management* →
   trust your developer certificate. Launch again.

> With a **free** Apple ID the build expires after **7 days** and you can have a
> limited number of apps. With the **paid** program it lasts a year and is the
> path to TestFlight.

---

## 3. TestFlight (beta testing on real devices)

TestFlight distributes signed builds to yourself and invited testers, without
the full App Store review for internal testers.

### 3.1 Create the app record in App Store Connect

1. Go to <https://appstoreconnect.apple.com> ▸ **Apps** ▸ **＋ ▸ New App**.
2. Fill in:
   - **Platform:** iOS
   - **Name:** Quietbox (must be unique across the App Store; pick another if
     taken)
   - **Primary language**
   - **Bundle ID:** select the one matching your project (register it first at
     *Certificates, Identifiers & Profiles ▸ Identifiers* if it's not listed)
   - **SKU:** any internal string, e.g. `quietbox-001`.

### 3.2 Set the version and build number

In `project.yml` these come from:

```yaml
MARKETING_VERSION: "1.0.0"     # user-visible version
CURRENT_PROJECT_VERSION: "1"   # build number — must increase every upload
```

Bump `CURRENT_PROJECT_VERSION` for **every** new upload (1, 2, 3, …), re-run
`xcodegen generate`. (Alternatively `agvtool` / a CI step can auto-increment.)

### 3.3 Archive and upload

**With Xcode (simplest):**

1. Set the run destination to **Any iOS Device (arm64)** — you cannot archive
   against a simulator.
2. **Product ▸ Archive**. The Organizer opens when it finishes.
3. Select the archive ▸ **Distribute App** ▸ **App Store Connect** ▸ **Upload**.
4. Keep the defaults (automatic signing, symbols included) and finish.

**Or from the command line:**

```bash
xcodegen generate

xcodebuild -project Quietbox.xcodeproj -scheme Quietbox \
  -configuration Release \
  -archivePath build/Quietbox.xcarchive \
  -destination 'generic/platform=iOS' \
  archive

xcodebuild -exportArchive \
  -archivePath build/Quietbox.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath build/export
# then upload build/export/Quietbox.ipa with Transporter.app or:
xcrun altool --upload-app -f build/export/Quietbox.ipa -t ios \
  --apiKey <KEY_ID> --apiIssuer <ISSUER_ID>
```

(You'll create `ExportOptions.plist` once — Xcode can generate it during a
manual export, or use `method: app-store-connect`.)

### 3.4 ⚠️ Export compliance (because Quietbox uses encryption)

After the build finishes processing, App Store Connect asks **export compliance**
questions. Quietbox **implements** standard, published cryptography (Argon2id +
XChaCha20-Poly1305 via libsodium) *in addition to* the OS — that is
**non-exempt** encryption, **not** one of the simple exemptions (which cover
only OS-built-in crypto, HTTPS, authentication-only, or DRM). So:

- "Does your app use encryption?" → **Yes**.
- "Does it qualify for the exemptions?" → **No** — Quietbox encrypts arbitrary
  user data with its own crypto, which is non-exempt.

The key is **already set** in `Sources/Resources/Info.plist` so the questionnaire
won't re-appear on every upload:

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<true/>
```

`<true/>` ("uses non-exempt encryption") is the accurate value here. It implies
two real obligations, both standard for an open-source-crypto app:

1. **France:** upload a **French encryption declaration** in App Store Connect —
   *only* if you distribute on the App Store in France. (Exclude France and this
   isn't triggered.)
2. **US BIS:** Quietbox is a **mass-market** product (ECCN 5A992.c/5D992.c) under
   **License Exception ENC §740.17(b)(1)**. You self-classify and file a short
   **annual self-classification report** to BIS (a granted **CCATS** waives the
   annual report).

> **This is a legal/compliance question — verify it for your distribution; this
> guide is not legal advice.** If, after review, you conclude your use *is*
> exempt, set the key to `<false/>` instead. Do not leave it unset, or you'll be
> re-asked on every upload.

### 3.5 Invite testers

- **Internal testers** (up to 100 people on your team): available almost
  immediately after processing — no review. Add them under **TestFlight ▸
  Internal Testing**, they install the **TestFlight** app and accept the invite.
- **External testers** (up to 10,000): require a one-time, light **Beta App
  Review** per build series. Add a test group, fill in "What to Test", submit.

Install **TestFlight** from the App Store on your iPhone, accept the invite, and
run the real signed build. **This is the "check if everything is OK on a real
device" step.**

---

## 4. Publish to the App Store

Once you're happy with the TestFlight build:

### 4.1 Complete the App Store listing

In App Store Connect ▸ your app ▸ the version you're submitting:

- **Screenshots** — required for at least a 6.7" iPhone (e.g. iPhone 16 Pro
  Max). You can capture them from the simulator (**⌘S** saves to Desktop).
- **Description, keywords, support URL, marketing URL** (optional).
- **Promotional text** (optional, editable without review).
- **App icon** — already shipped in the asset catalog (1024px).
- **Category** — e.g. *Utilities*.
- **Age rating** — answer the questionnaire.
- **Privacy policy URL** — **required for every app**, even one that collects no
  data (App Review Guideline 5.1.1(i)). The policy ([`docs/privacy-policy.md`](privacy-policy.md))
  is published as a public gist:
  <https://gist.github.com/fabiofranco85/699d83b8182a251d8226ab15b05064dc>.
  Paste that URL into **App Information ▸ Privacy Policy**. Quietbox also surfaces
  the same link in-app via the **ⓘ About** sheet (the guideline requires it in
  *both* places); the URL lives in one place in code: `AppInfo.privacyPolicyURL`.

### 4.2 App Privacy ("nutrition label")

App Store Connect ▸ **App Privacy**. Quietbox is on-device with no accounts,
no network, and no telemetry, so the honest answer is **"Data Not Collected."**
Declare that and you're done — it's a genuine selling point.

### 4.3 Pick the build and submit

1. In the version page, under **Build**, click **＋** and select the build you
   validated on TestFlight.
2. Re-confirm export compliance if asked.
3. Set **pricing** (Free) under the Pricing tab.
4. Choose release option: **Automatic** (release when approved), **Manual**, or
   **Scheduled**.
5. Click **Add for Review ▸ Submit**.

### 4.4 Review and release

- App Review typically takes from a few hours to a couple of days.
- If **rejected**, you'll get specific reasons in the Resolution Center; fix,
  bump `CURRENT_PROJECT_VERSION`, re-archive, and resubmit.
- If **approved** and you chose Automatic, it goes live on the App Store
  (worldwide, unless you limited availability) within a few hours.

🎉 **Shipped.**

---

## 5. Quick reference

```bash
# Simulator
xcodegen generate && open Quietbox.xcodeproj      # then ⌘R

# Tests (same as CI)
xcodebuild test -project Quietbox.xcodeproj -scheme Quietbox \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Archive for upload
xcodebuild -project Quietbox.xcodeproj -scheme Quietbox -configuration Release \
  -archivePath build/Quietbox.xcarchive -destination 'generic/platform=iOS' archive
```

## 6. Common gotchas

| Symptom | Fix |
|--------|-----|
| "No account for team" / signing errors | Add your Apple ID in *Xcode ▸ Settings ▸ Accounts*; pick the Team in Signing & Capabilities. |
| "Bundle identifier is not available" | It must be globally unique — change `PRODUCT_BUNDLE_IDENTIFIER` in `project.yml`, regenerate. |
| Build number rejected ("already exists") | Increase `CURRENT_PROJECT_VERSION` and re-archive. |
| App won't launch on device | Trust the developer cert in *Settings ▸ General ▸ VPN & Device Management*; enable Developer Mode. |
| Asked export-compliance every upload | Set `ITSAppUsesNonExemptEncryption` in `Info.plist` (see §3.4). |
| Changes to `project.yml` don't show up | Re-run `xcodegen generate`. |
| Can't archive | Destination must be a device / "Any iOS Device", not a simulator. |

---

### Helpful links
- App Store Connect: <https://appstoreconnect.apple.com>
- TestFlight overview: <https://developer.apple.com/testflight/>
- App Review Guidelines: <https://developer.apple.com/app-store/review/guidelines/>
- Encryption & export compliance: <https://developer.apple.com/documentation/security/complying-with-encryption-export-regulations>
