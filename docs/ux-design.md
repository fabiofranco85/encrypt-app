# UX Design

Cipherbox should feel calm, trustworthy, and effortless — security software that
doesn't feel like security software.

## Design principles

1. **One clear job per screen.** Encrypt or Decrypt; Text or File. No modes
   hidden behind menus.
2. **The password is the hero.** Big, obvious, with a reveal toggle and a live
   strength meter when encrypting, and a confirm field to prevent lockouts.
3. **Honest feedback.** Argon2 is intentionally slow; we show a friendly
   progress overlay instead of a frozen button.
4. **Safe by construction.** The UI only ever shows the actions the artifact
   allows (text = copy-only). Destructive ambiguity is impossible.
5. **Delight in the details.** Smooth transitions, a tasteful lock animation,
   success/error haptics — never gratuitous.

## Visual language

- **Brand mark:** a padlock built from SF Symbols inside a soft gradient.
- **Accent:** indigo→violet gradient (`AppTheme`), system background materials.
- **Typography:** system font, Dynamic Type throughout; monospaced for
  ciphertext previews.
- **Corners & depth:** rounded cards (`.regularMaterial`), subtle shadows.
- Full **dark mode** parity.

## Primary flow — Encrypt

1. Pick **Text** or **File** (segmented).
2. Text: type/paste the message. File: tap to pick a file (shows name + size).
3. Enter password → strength meter animates. Enter confirm password.
4. Tap **Encrypt** → progress overlay (“Deriving key…”).
5. **Result card** appears with a preview and the allowed actions:
   - Text → **Copy** (only).
   - File → **Copy**, **Share**, **Save to Files**.
6. Success haptic. A subtle “locked” animation plays.

## Primary flow — Decrypt

1. Provide input: paste an armored message **or** pick a `.cipherbox` file
   (also reachable via the system share sheet → "Open in Cipherbox").
2. Enter password.
3. Tap **Decrypt** → progress overlay.
4. Result:
   - Decrypted **text** → shown in a readable card, **Copy** only.
   - Decrypted **file** → name + size, with **Copy**, **Share**, **Save**.
5. Wrong password → inline, friendly error + error haptic; inputs preserved.

## Accessibility

- Every control has a VoiceOver label/hint; the strength meter announces its
  level as text, not color alone.
- Dynamic Type to the largest sizes; layouts use stacks/`ScrollView`, never
  fixed heights that clip.
- Contrast meets WCAG AA in light and dark.
- Respects Reduce Motion (animations degrade to fades).

## Microcopy

- Calm and plain. "Enter a password to lock this." / "Couldn’t unlock —
  check the password and try again." No jargon, no blame.
- Empty states explain the next action, not just "nothing here".

## States to handle (every screen)

- Empty / idle, in-progress, success, recoverable error, and validation
  (empty password, mismatched confirm, empty message, no file chosen).
