# Google Play Store listing — African Doctor

Copy these fields directly into the Google Play Console when creating the
app listing.

## App details

| Field | Value |
|---|---|
| App name | **African Doctor** |
| Default language | English (United States) — en-US |
| App or game | App |
| Free or paid | Free |
| Application ID | `com.africandoctor.app` |
| Contact email | s68745409@gmail.com |
| Website | https://github.com/s68745409-cell/african-doctor |
| Privacy policy URL | *Host `PRIVACY_POLICY.md` on GitHub Pages or a public URL, then paste here.* |

## Short description (max 80 characters)

> Identify African medicinal plants from a photo. Traditional uses, safety notes.

*(79 chars)*

## Full description (max 4000 characters)

> **African Doctor** helps you identify African medicinal plants from a photo and learn their traditional uses, preparation methods, and safety warnings — all in one app, with a built-in offline library for areas without reliable data.
>
> **What the app does**
> - Capture a leaf or plant with your phone camera, or pick a photo from your gallery.
> - A medicinal-plant image-classification model returns a ranked list of candidate species with a confidence score.
> - If confidence is at least 85%, you get a clear educational profile: scientific name, local names in 14 African languages (Swahili, Bemba, Nyanja, Yoruba, Hausa, Shona, Zulu, Xhosa, Afrikaans, Sotho, Kikuyu, Wolof, Igbo, Tswana), traditional use, preparation, and — critically — safety warnings and contraindications.
> - Below that, a "Community Wisdom" section pulls related short-form videos (YouTube) and offers a one-tap hashtag link to TikTok, so you can see how people are currently using the plant. You can flag misinformation; videos flagged 3+ times are hidden from your feed.
> - Offline library: 15 well-documented African medicinal plants ship inside the app and work with no internet connection (Moringa oleifera, Azadirachta indica / neem, Aloe vera, Artemisia afra, Hibiscus sabdariffa, Sutherlandia frutescens, Harpagophytum procumbens / devil's claw, Prunus africana, Warburgia salutaris, Vernonia amygdalina, Cassia abbreviata, Adansonia digitata / baobab, Carica papaya, Tamarindus indica, Zingiber officinale / ginger).
> - Scan history: every identification is saved locally so you can revisit it later.
>
> **Safety first**
> - The app shows a mandatory disclaimer on first launch before you can use it.
> - If the identifier is not at least 85% confident, the app refuses to display medicinal information and instead recommends consulting a local expert. We would rather say "I don't know" than risk a dangerous misidentification.
> - Every warning in the medicinal database is displayed prominently, not hidden under a "read more".
>
> **Ethics and data ownership**
> - Traditional knowledge belongs to the communities that have stewarded it for generations.
> - The seed database in the first release is compiled from widely-published ethnobotanical references and is clearly flagged as *pending partner verification*. Each entry is being replaced, one by one, with verified records from partnering botanists and traditional healers' associations.
> - The app is **educational**. It is not a medical device and is not a substitute for professional medical advice, diagnosis, or treatment.
>
> **Privacy**
> - No account required. No tracking. No ads.
> - The app makes two kinds of network request, and only when you explicitly ask: one photo upload to a plant-classification endpoint, and one keyword search to the YouTube Data API. Neither request sends any personal identifier.
>
> Open source: https://github.com/s68745409-cell/african-doctor

## Category & tags

- Category: **Health & Fitness** (alternative: Education)
- Tags: Medical, Education, Reference

## Content rating

Fill out the IARC questionnaire with:
- Violence: **No**
- Sexuality: **No**
- Profanity: **No**
- Controlled substances: **No** (plant identification is informational; no
  instructions for drug production or misuse)
- Gambling / user interaction: **No**
- Shares location: **No**
- Digital purchases: **No**

Expected rating: **Everyone** / PEGI 3.

## Data safety

In the "Data safety" form on the Play Console, answer:
- Does your app collect or share any of the required user data types? **No**
- Is all of the user data collected by your app encrypted in transit? **N/A (no user data collected)**
- Do you provide a way for users to request that their data be deleted? **N/A**

The only network payload is the plant photo — which is classified in real
time and not stored — and a keyword string sent to YouTube. Neither carries
a user identifier.

## Assets

| Asset | Size | File |
|---|---|---|
| App icon | 512x512 PNG | `assets/store/icon-512.png` |
| Feature graphic | 1024x500 PNG | `assets/store/feature-graphic.png` |
| Phone screenshots (at least 2) | 1080x1920 or larger | Capture from the app running on your phone after install. |

## Release

1. Internal testing: upload `african-doctor-release.aab` (attached to this
   session) as the first release.
2. Target API level: 35 (required by Google Play in 2025+).
3. Signed by: `african-doctor` alias in `african-doctor.keystore`
   (**KEEP A BACKUP of the keystore** — if you lose it you can never
   update the app again).
