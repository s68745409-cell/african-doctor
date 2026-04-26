# Release checklist — pushing African Doctor to Google Play

This checklist covers the steps **only you** can perform (signing into
Google, paying the $25 fee, uploading screenshots from your phone, etc.).

## 1. One-time account setup (~15 min, ~$25 USD)

- [ ] Create a Google Play Console account at https://play.google.com/console
      (personal account is fine for MVP).
- [ ] Pay the one-time $25 registration fee.
- [ ] Accept the Google Play Developer Distribution Agreement.
- [ ] Enable 2-factor authentication on the Google account.

## 2. Host the privacy policy

Play Store requires a public URL for the privacy policy. Easiest path:

- [ ] Push this repo to GitHub (already done).
- [ ] In repo **Settings → Pages**, enable GitHub Pages from branch
      `main` / folder `/store`. Once live, your privacy policy URL will be
      `https://s68745409-cell.github.io/african-doctor/PRIVACY_POLICY.html`
      (you'll need to convert `.md` → `.html` or use a static-site
      generator; simplest is to rename `PRIVACY_POLICY.md` to
      `index.md` inside `/store`).
- [ ] Verify the URL loads in a private browser window.

## 3. Create the app in Play Console

- [ ] Click **Create app** at the top right.
- [ ] Fill the fields from `STORE_LISTING.md`.
- [ ] Declare: it is an app (not a game), it is free, and it complies with
      the Play policies + US export laws.
- [ ] Complete the **Content rating** questionnaire (values in
      `STORE_LISTING.md`).
- [ ] Complete the **Data safety** form (values in `STORE_LISTING.md`).
- [ ] Complete **App access** → "All functionality is available without
      restrictions". (No login walls.)
- [ ] Complete **Ads** → "No, my app does not contain ads".
- [ ] Complete **Target audience** → minimum age 13+.
- [ ] Complete **Government apps** → No.
- [ ] Complete **News apps** → No.
- [ ] Complete **Health apps** → **Yes**, this is a health-related app.
      When prompted, declare: "Informational / educational tool. Does
      not claim medical benefits, does not provide diagnosis or
      treatment."

## 4. Upload the release bundle

- [ ] **Testing → Internal testing → Create new release**.
- [ ] Upload `african-doctor-release.aab` (attached to the session).
- [ ] Release name: `0.1.0 MVP`.
- [ ] Release notes: "First MVP release. Plant identification,
      offline seed library of 15 African medicinal plants, community
      videos."
- [ ] Add at least 1 internal tester (your own email is fine).
- [ ] Submit for review (internal testing typically approved in
      minutes — hours).

## 5. Before promoting to production

- [ ] Replace every `verified_by: SEED DATA — pending partner verification`
      entry in `assets/data/plants.json` with a real healer or
      botanist attribution. **Do not ship to Production until this is
      done — safety liability is real.**
- [ ] Capture at least 2 phone screenshots (showing disclaimer, home,
      plant detail, capture flow). Upload to Play Console.
- [ ] Add a **feature graphic** (1024x500 PNG, see
      `STORE_LISTING.md`).
- [ ] Consider a **Closed testing** track before Production so a small
      group of traditional-medicine experts can sanity-check the
      medicinal content.

## 6. Keystore safety (CRITICAL)

You received `african-doctor.keystore` as a session attachment. This file
is the ONLY way to publish future updates to your app on Google Play.

- [ ] Download it immediately.
- [ ] Copy it to at least **two** safe locations (e.g. an encrypted USB
      stick + a password-manager file attachment).
- [ ] Store the passwords (in `android/key.properties`) in your password
      manager, NOT in the repo.
- [ ] **If you lose this keystore, you cannot publish updates.** Google
      offers Play App Signing as a workaround (they hold the upload
      signature); enable it in Play Console → App signing.

## 7. Post-launch

- [ ] Invite partnering botanists / healers to test and verify seed data.
- [ ] Monitor crash reports in Play Console → **Vitals**.
- [ ] Prepare Phase 2 (Firestore) and Phase 3 (on-device TFLite) so the
      app works in rural areas with no data.
