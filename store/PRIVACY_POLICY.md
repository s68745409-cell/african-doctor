# African Doctor — Privacy Policy

_Last updated: 26 April 2026_

African Doctor ("the app", "we", "us") is a Flutter-based mobile application
that identifies African medicinal plants from a photo and shows their
traditional uses. This policy describes what information the app handles and
why.

## 1. Information the app does NOT collect

- We do **not** require an account, email address, phone number, or any
  personal identifier to use the app.
- We do **not** track your location.
- We do **not** build a profile of you, your device, or your plant scans.
- We do **not** share any data with advertising networks. The app is
  ad-free.
- We do **not** sell data to third parties. There is no "data broker"
  relationship.

## 2. Data sent to third-party services

To identify a plant and load related videos, the app forwards the following
to external services only when you explicitly take an action:

| Action | Data sent | Destination |
|---|---|---|
| Tap **Capture** or **Upload** | The photo you chose (JPEG bytes). | `edgarphiri1-african-doctor-classifier.hf.space` (Hugging Face Space) for image classification. The photo is used only to return a ranked list of plant labels, is not stored, and is not used to train any model owned by us. |
| View a plant's **Community Wisdom** | The identified plant's scientific name as a search query. | YouTube Data API v3 (`googleapis.com`). No account, no user identifier, no device identifier is sent. |
| Tap a **TikTok hashtag** link | Nothing sent by the app directly; the TikTok app or mobile browser opens using the plant name as a hashtag. | TikTok's own privacy policy applies. |

The app does not include any third-party SDK that collects data in the
background. The only network calls are the two above, triggered by your
explicit action.

## 3. Data stored on your device

The following are stored in your device's app sandbox using
`SharedPreferences`. They are **never** uploaded anywhere:

- Whether you have accepted the safety disclaimer.
- Your scan history (the names of plants you identified and timestamps).
- Per-video flag and upvote counts for the "Community Wisdom" section.
- A 24-hour cache of the YouTube video list for each plant you viewed.

You can clear all of this by uninstalling the app or via your device's app
storage settings.

## 4. Photos, camera, and storage permissions

The camera and photo library permissions are requested only at the moment
you tap **Capture** or **Upload**. We do not access the camera or library
in the background.

## 5. Medical disclaimer

African Doctor is an **educational** tool. It is not a medical device and
it is not a substitute for professional medical advice, diagnosis, or
treatment. Traditional medicine information is presented as cultural
heritage and may be incomplete or inappropriate for your situation. Consult
a qualified healthcare professional or a recognised traditional healer
before using any plant for medicinal purposes. If you are pregnant,
breastfeeding, have a chronic illness, or are taking prescription
medication, the risks can be especially serious.

## 6. Children's privacy

The app is intended for users aged 13 and over. We do not knowingly collect
any information about children under 13. Because the app does not collect
personal information from anyone, no special procedures are required.

## 7. Changes to this policy

If we ever add features that change what data the app handles, we will
update this policy and post a notice on the project's GitHub repository:

- https://github.com/s68745409-cell/african-doctor

## 8. Contact

- GitHub issues: https://github.com/s68745409-cell/african-doctor/issues
- Email (project maintainer): s68745409@gmail.com
