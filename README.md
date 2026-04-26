# African Doctor

A Flutter mobile app that identifies African medicinal plants from a photo and
shows their traditional uses, preparation methods and safety warnings.

> ⚠️ **This is an MVP.** The medicinal data shipped with the app is seed data
> compiled from widely-published ethnobotanical references and is clearly
> flagged as *pending partner verification*. It is **not** a substitute for
> professional medical advice. Every entry must be replaced with a verified
> record from a partnering botanist or traditional-healers' association
> before this app is released publicly.

## Features

- **Camera capture / gallery upload** — identify any plant from a photo.
- **Plant.id identification** — the [Plant.id v3 REST API](https://web.plant.id/)
  returns a ranked list of candidate species with a confidence score (free
  tier: 100 identifications). The legacy Pl@ntNet integration is kept in
  `IdentificationResult.fromPlantNetJson` for easy provider-switching.
- **85 % confidence threshold** — below this, the app refuses to display
  traditional-medicine information and tells the user to consult a local
  expert.
- **Offline seed library** — 15 well-documented African medicinal plants
  (Moringa, Neem, Aloe, Artemisia afra, Hibiscus sabdariffa, Sutherlandia,
  Devil's Claw, Prunus africana, Warburgia, Vernonia amygdalina, Cassia
  abbreviata, Adansonia digitata, Carica papaya, Tamarindus indica, Zingiber
  officinale) with scientific names, local names, traditional uses,
  preparation, and safety warnings.
- **Community wisdom** — fetches related videos via the YouTube Data API v3
  and lets users deep-link into TikTok hashtags for the identified plant.
- **Crowdsourced moderation** — per-video flag/upvote counters; any video
  with 3+ local flags is hidden. (Swap this for a server-aggregated count
  before shipping.)
- **Safety interstitial** — a mandatory disclaimer screen shown on first
  launch.
- **Scan history** — stored locally with `SharedPreferences`.
- **Multilingual seed data** — plant entries include names in Swahili, Bemba,
  Nyanja, Yoruba, Hausa, Shona, Zulu, Xhosa, Afrikaans, Sotho, Kikuyu, Wolof,
  Igbo, Tswana (more can be added without code changes).

## Prerequisites

- Flutter **≥ 3.41** (stable channel).
- A [Plant.id API key](https://web.plant.id/) (free tier: 100 IDs).
- A [YouTube Data API v3 key](https://console.cloud.google.com/apis/credentials)
  (free quota).

## Configuration

Copy `.env.example` to your local `.env` (gitignored) **or** pass the keys at
build time with `--dart-define`:

```bash
# Option A — local .env file (easiest for development)
cp .env.example .env
# then edit .env and paste your keys

# Option B — pass keys at build/run time (recommended for CI)
flutter run \
  --dart-define=PLANT_ID_API_KEY=pk_xxx \
  --dart-define=YOUTUBE_API_KEY=yk_xxx
```

If `PLANT_ID_API_KEY` is missing the identification screen shows an error. If
`YOUTUBE_API_KEY` is missing the "Community wisdom" section simply renders a
note asking the user to add a key — the rest of the app works fine.

## Running

```bash
flutter pub get
flutter run
```

## Testing

```bash
flutter analyze
flutter test
```

## Project layout

```
lib/
├── main.dart                     # entrypoint + theme
├── data/plant_repository.dart    # loads assets/data/plants.json
├── models/                       # Plant, IdentificationResult, CommunityVideo
├── services/
│   ├── plant_id_service.dart     # Plant.id v3 /identification client
│   ├── youtube_service.dart      # YouTube search + TikTok deep link
│   └── cache_service.dart        # SharedPreferences-backed cache
├── screens/
│   ├── disclaimer_screen.dart    # safety interstitial
│   ├── home_screen.dart          # capture + offline library
│   ├── result_screen.dart        # identification results
│   ├── plant_detail_screen.dart  # traditional-use info + community videos
│   └── history_screen.dart
├── widgets/
│   ├── confidence_badge.dart
│   └── video_card.dart           # thumbnail + flag/upvote UI
└── utils/constants.dart          # thresholds, endpoints, TTLs

assets/
└── data/plants.json              # seed medicinal-plant database
```

## Ethics and data ownership

This app digitises traditional knowledge that belongs to the communities who
have stewarded it for generations. Before adding any new plant to
`assets/data/plants.json` you must:

1. Obtain **prior informed consent** from the healer or community providing
   the knowledge.
2. Record the contributor's name / institution in the `verified_by` field.
3. Document preparation and warnings accurately — misinformation can kill.
4. Never strip the seed-data warnings when replacing placeholder text with
   verified content.

Please also flag endangered species (e.g. *Prunus africana*, *Warburgia
salutaris*) with sustainability notes, and consider a "sustainable harvesting"
field in the data schema.

## Roadmap

| Phase | Focus            | Status |
|-------|------------------|--------|
| 1     | MVP identification + seed DB + community links  | ✅ this PR |
| 2     | Firestore backend for curated plant DB + moderation | ⬜ |
| 3     | TensorFlow Lite on-device model trained on African flora | ⬜ |
| 4     | Multi-language UI (`flutter gen-l10n`) | ⬜ |
| 5     | Partnership MoUs with botanical gardens & healer associations | ⬜ |
| 6     | GPS tagging + biodiversity mapping contributions | ⬜ |

## License

MIT for the code. The medicinal data in `assets/data/plants.json` is seed
content that must be replaced with verified, consented entries before public
release.
