# Sacred Frequencies — Feature Reference

> **Status**: **End-to-end working** — Sanity → R2 → `AVPlayer` verified on device (June 2026)  
> **Priority**: **Game changer** — primary App Store differentiation & user personalization  
> **Related**: `IN_PROGRESS.md` (explorer), `ARCHITECTURE.md` (vision)  
> **Last Updated**: June 8, 2026 (player polish + loop fixes)

---

## Why this feature exists

Apple App Review expects **app-like engagement** — native capabilities and user-owned data that go beyond a free website. The Divine Codex website is the open reference; the **iOS app is the practice companion**.

Sacred Sites proved the pattern:
- **Reflection journal** (voice/text) → CloudKit  
- **Favorites** → CloudKit, cross-device  

For Divine Codex, **Sacred Frequencies** is the anchor feature (journal + deeper Explorer links come next).

| Website / YouTube | Divine Codex app |
|-------------------|------------------|
| One-off videos or articles | Frequencies tied to **emanations** in the cosmology map |
| No memory of the user | **Favorites**, future playlists & practice history |
| Generic browsing | Explore Sophia → **play her frequency** in context |
| No personal practice log | Future **Remembrance journal** linked to what you practiced |
| Tab chaos | **Lock-screen controls**, loop, timer, offline (planned) |

**Decision (June 2026):** Prioritize Frequencies **before** further Cosmo Stage orb polish. Polish is ongoing; personalization is the strategic bet.

---

## Product vision

Sacred Frequencies are **chants, vowels, and meditation sounds** authored in Sanity, with:

- Instruction text (how to practice)  
- Optional **hosted audio** (MP3 / AAC / HLS — URL in Sanity, not in Sanity Enterprise video hosting)  
- **Cover images** (15–20 cohesive cosmic/sacred visuals for v1; reuse across surfaces)  
- Links to **emanations** (`associatedEmanations`) so practice connects to the Explorer map  

Content pipeline (Dennis):
1. Author frequency text in Sanity Studio  
2. Generate MP3s via AI or recording (review pronunciation of sacred names)  
3. Host audio on **Cloudflare R2** (see [Media hosting](#media-hosting-assessment) below)
4. Upload cover images to Sanity  
5. Scale from **~5 hero frequencies** → 15–20 when the loop feels right  

**Do not** rip audio from YouTube — inspiration only; ship owned/licensed assets.

---

## Sanity schema (live in Studio)

Document type: `frequency` (Studio nav: **Frequencies & Utterances**). Schema lives in `sanity-studio-divine-codex/schemaTypes/frequency.ts`.

### iOS-facing fields (must match `Frequency.swift`)

| Field | Purpose |
|-------|---------|
| `title` | Display name (renamed from early `name`; GROQ coalesces legacy `name`) |
| `slug` | URL slug — `options.source: 'title'` |
| `order` | Sort order in library (Studio list ordered by `order` asc) |
| `shortDescription` | Card / list subtitle |
| `practiceNotes` | How to chant — shown in player (renamed from early `notes`) |
| `pronunciationGuide` | Phonetic / sounding instructions |
| `audio.url` | R2 HTTPS URL (`.m4a` or `.mp3`) |
| `audio.loopable` | Default loop when player opens |
| `coverImage` | Sanity CDN image (player hero + list thumbnail) |
| `associatedEmanations` | References to `emanation` docs |

### Editorial fields (Studio / website — not fetched by iOS v1)

`phoneticSequence`, `variants`, `meaningOrIntention`, `category`, `recommendedRepetitions` — kept for Codex authoring. GROQ falls back to `phoneticSequence` for `shortDescription` / `pronunciationGuide` when those iOS fields are empty.

### `audio` object shape

```ts
audio: {
  url: string,              // R2 pub-….r2.dev or custom domain
  loopable: boolean,        // initial loop toggle in app
  durationSeconds?: number, // optional; future Now Playing UI
  provider?: "r2" | "mux" | "other"
}
```

### GROQ query (authoritative — matches iOS app)

```groq
*[_type == "frequency"] | order(coalesce(order, 9999) asc){
  _id,
  "title": coalesce(title, name),
  "slug": slug.current,
  "shortDescription": coalesce(shortDescription, phoneticSequence),
  "practiceNotes": coalesce(practiceNotes, notes),
  "pronunciationGuide": coalesce(pronunciationGuide, phoneticSequence),
  order,
  "audioUrl": coalesce(audio.url, audioUrl),
  "audioLoopable": coalesce(audio.loopable, true),
  coverImage,
  "associatedEmanationIds": associatedEmanations[]._ref
}
```

Fetched at app launch via `SanityViewModel.fetchFrequencies()` alongside emanations.

### Seeded examples (from early Studio work)

- **Primordial Vowels** — `i, e, o, u, a`  
- **I AM THAT I AM** — `eh-YEH ah-SHER eh-YEH`  
- **OH GO BEE JA DA**  

iOS `Frequency.sampleSet` (DEBUG previews) mirrors the first two with practice copy.

---

## Image strategy (15–20 assets)

| Set | Count | Use |
|-----|-------|-----|
| Core cosmology | 3–4 | Monad, Pleroma, generic Aeon atmosphere |
| Key emanations | 6–8 | Sophia, Barbelo, Christos, etc. |
| Frequency / chant mood | 4–6 | Abstract sacred visuals (violet flame, gold light) |
| Player fallback | 1–2 | Neutral cosmic backdrop |

**Style:** Deep cosmic dark, violet/gold, contemplative — match app Liquid Glass mood. Consistent art direction beats volume.

**Reuse:** One strong Pleroma image can cover multiple frequencies until bespoke art exists.

**Creation:** AI gen + curation, or small commissioned set, or hybrid.

**Hosting:** Cover images stay in **Sanity CDN** — not R2. Easier Studio workflow; `RemoteSanityImage` already works.

---

## Media hosting assessment

> **Decision (June 8, 2026):** **Cloudflare R2** for MP3s and early MP4s. **Mux Video** as an upgrade path for longer/adaptive video later. Sanity remains the catalog (metadata + URLs).

### What is Cloudflare R2?

**R2** is **Cloudflare’s object storage** product — the same category as Amazon S3, but with **no egress (bandwidth) fees** when serving files over HTTPS. A normal **free Cloudflare account** includes R2 access.

- **Cloudflare** = the company (CDN, DNS, security, R2, Workers, etc.)  
- **R2** = the storage bucket where you upload `.mp3` and `.mp4` files  
- You do **not** need a separate “R2 company” — sign up at [cloudflare.com](https://www.cloudflare.com), then enable R2 in the dashboard  

**Mux Player** (web embed) is **not** used in the iOS app. The app uses native **`AVPlayer`**. Mux **Video** (hosting/encoding) is optional later for HLS streaming URLs stored in Sanity.

### Architecture overview

```
Sanity Studio     →  titles, practice notes, cover images, playback URLs
       ↓
Cloudflare R2     →  MP3 frequencies + short MP4 videos (HTTPS URLs)
Mux Video (later) →  optional HLS for longer teaching videos
       ↓
iOS AVPlayer      →  plays URL from Sanity (no re-release to swap media)
```

| Media type | Host (v1) | Notes |
|------------|-----------|-------|
| Cover images | **Sanity CDN** | Already integrated |
| **MP3 frequencies** | **Cloudflare R2** | Simple files, loop-friendly, lowest cost |
| **Short MP4** (≤ ~2–3 min) | **R2** progressive MP4 | `AVPlayer` plays direct MP4 |
| **Longer / HD video** (later) | **Mux Video** (HLS) | Adaptive streaming, thumbnails, analytics |

### Why hybrid (not one provider)?

| Approach | Verdict |
|----------|---------|
| **R2 for MP3** | Best fit — upload file, paste URL, no video pipeline |
| **Mux for all MP3** | Overkill — priced per-minute for video workflows |
| **R2 for all video (forever)** | Fine for v1; may buffer on cellular for long clips |
| **Mux for video when needed** | HLS adaptive quality, auto thumbnails, free tier to experiment |

### Cost expectations (Divine Codex scale)

**v1 library (estimate):** ~20 MP3s (~60 MB) + ~5–10 MP4s (~150–500 MB), modest play counts.

| Service | Free tier highlights | Expected v1 cost |
|---------|----------------------|------------------|
| **Cloudflare R2** | 10 GB storage/mo, 1M Class A ops, 10M Class B ops, **free egress** | **$0/mo** (well under limits) |
| **Mux Video** (optional) | 10 videos stored, 100K delivery minutes/mo on free plan | **$0/mo** until video volume grows |
| **Sanity images** | Existing project CDN | Already on plan |

Paid Mux (if exceeded): roughly **$0.0024/min** storage, **$0.0008/min** delivery (720p) — still modest at niche-app traffic.

**Bottom line:** Expect **$0/month** for a long time with R2 + Sanity images. Add Mux only when video warrants it.

### Phased hosting plan

#### Phase 1 — Launch (now)

1. Create **free Cloudflare account** → enable **R2**  
2. Create bucket (suggested name: `divine-codex-media`)  
3. Enable **public access** (or custom domain later) for HTTPS URLs  
4. Upload MP3s → copy public URL → Sanity `frequency.audio.url`  
5. Upload short MP4s → copy URL → Sanity `emanation.video.url`  
6. Cover images → upload in **Sanity Studio** only  

**No app update** required when adding or swapping media — change URL in Sanity.

#### Phase 2 — Video quality

Move **video only** to **Mux** when you need:

- Videos longer than ~5 minutes  
- Adaptive streaming on cellular  
- Auto-generated poster/thumbnail URLs  
- Playback analytics  

Keep **all audio on R2**.

Mux workflow: upload → HLS playback URL → paste into Sanity `video.url`. iOS `AVPlayer` plays HLS natively.

#### Phase 3 — Personalization (future)

- Offline download of favorite MP3s (local cache)  
- Signed URLs if premium/gated content (R2 and Mux both support)  

### Sanity field conventions (media)

```ts
// frequency
audio: {
  url: string,              // R2 HTTPS URL to .mp3 (or .m4a)
  loopable: boolean,
  provider?: "r2" | "mux"   // ops note for Dennis; optional in app v1
}

// emanation (existing video object — extend provider)
video: {
  url: string,              // R2 .mp4 OR Mux HLS .m3u8
  posterImage: image,       // Sanity image preferred
  provider?: "r2" | "mux"
}
```

### Content upload workflow

1. Author text in Sanity Studio  
2. Generate or record MP3 → review pronunciation of sacred names  
3. Upload MP3 to R2 bucket  
4. Copy HTTPS URL into Sanity `audio.url`  
5. Upload cover image to Sanity `coverImage`  
6. For video: start with R2 MP4; re-host on Mux later if needed (update URL once)  

**Do not** rip audio/video from YouTube — owned or licensed assets only.

### R2 URLs — which one goes in Sanity?

Cloudflare shows **three different URL concepts**. Only one belongs in the app.

| URL type | Example | Use |
|----------|---------|-----|
| **S3 API endpoint** | `https://….r2.cloudflarestorage.com/divine-codex-media` | **Upload tools only** (Dashboard, `wrangler`, Cyberduck). Requires auth. **Do not** paste into Sanity or the iOS app. |
| **Public Development URL** | `https://pub-xxxxxxxx.r2.dev/your-file.m4a` | **Dev & testing** — enable in bucket Settings. Fine for now. |
| **Custom domain** (recommended for production) | `https://media.yourdomain.com/your-file.m4a` | **App Store / production** — connect a domain you own to the bucket before wide release. |

Cloudflare warns against relying on the **Public Development URL** in production because of rate limits, branding, and abuse risk. For Divine Codex **right now** (first files, testing in Simulator): **enable Public Development URL** and use it. Plan a **custom domain** before TestFlight or public launch.

**Audio formats:** `.m4a` and `.mp3` are both fine for R2 + iOS `AVPlayer`.

### R2 setup checklist (Dennis)

- [x] Create free Cloudflare account  
- [x] Enable **R2** (credit card on file for free-tier overage protection)  
- [x] Create bucket `divine-codex-media`  
- [x] Upload test audio (`.m4a` in `frequencies/` prefix)  
- [x] Enable **Public Development URL** on the bucket (OK for testing)  
- [x] Copy **object URL** (`https://pub-….r2.dev/frequencies/…`) — not the S3 API endpoint  
- [x] Verify URL plays in Safari  
- [x] Paste URL into Sanity `frequency` → `audio.url`  
- [x] Confirm app player plays audio after fetch  
- [ ] Before App Store: attach **custom domain** to bucket; update Sanity URLs if domain changes

**Dev base URL (June 2026):** `https://pub-ecedb50375844dbabfd670477da2bdda.r2.dev`

### Provider comparison (reference)

| Need | R2 | Mux Video |
|------|----|-----------|
| MP3 loop practice | ✅ Best | Overkill |
| Short MP4, few users | ✅ Free | ✅ Free tier |
| Long HD adaptive video | ⚠️ OK | ✅ Best |
| iOS `AVPlayer` | ✅ Direct URL | ✅ HLS URL |
| Mux Player (web) | N/A | ✅ Website only |

### Deferred (not needed v1)

- DRM / signed URLs  
- Putting images on R2 (Sanity is easier)  
- Mux Player inside iOS  
- Encoding MP3s through a video pipeline  

---

## iOS implementation (current)

### User flow

1. **Home** → tap **Sacred Frequencies** (Liquid Glass button above tagline)  
2. **FrequenciesLibraryView** — list all frequencies; filter **favorites** (heart in toolbar)  
3. Tap row → **FrequencyPlayerView** (`fullScreenCover`) — hero cover art, play/pause, loop, practice text, favorite  
4. **Close** (✕) returns to library; list remains underneath  
5. Without `audioUrl`: text practice + “audio coming soon” banner still works  

### Player layout (June 2026)

- **`onGeometryChange`** (not `GeometryReader`) drives responsive hero cover sizing  
- Cover art is a **dynamic square** (~54–62% of viewport height) — dominates first screen on phone and iPad  
- Title + transport controls sit below cover; pronunciation / practice text scrolls when needed on smaller devices  
- Placeholder gradient + waveform icon when `coverImage` is missing

### Code map

| File | Role |
|------|------|
| `Model/Frequency.swift` | Decoded Sanity model + DEBUG `sampleSet` |
| `ViewModel/SanityViewModel.swift` | `frequencies`, `fetchFrequencies()` |
| `ViewModel/SacredFrequenciesViewModel.swift` | `AVPlayer`, loop, favorites (UserDefaults) |
| `View/Frequencies/FrequenciesLibraryView.swift` | Browse + favorites filter |
| `View/Frequencies/FrequencyPlayerView.swift` | Full-screen player UI |
| `View/Home/HomeView.swift` | Home CTA + `fullScreenCover` entry |
| `Divine_Codex_iOSApp.swift` | Injects `SacredFrequenciesViewModel`; prefetches on launch |

### Personalization (v1)

- **Favorites** persisted in `UserDefaults` (`sacredFrequencyFavorites`)  
- **Next:** CloudKit private database — mirror Sacred Sites pattern for cross-device sync  

### Audio (v1)

- `AVAudioSession` category `.playback`  
- `AVPlayer` with end-of-track observer  
- **Loop:** `applyLoopDefault(from:)` seeds toggle from Sanity `audio.loopable` on player `onAppear`; user toggle is **not** overwritten by `play()`  
- **Loop off:** track rewinds to start on natural end; play button restarts from beginning  
- **Not yet:** `MPNowPlayingInfoCenter`, lock-screen controls, background mini-player

---

## Suggested v1 content pack (ship before scaling)

1. Primordial vowels  
2. One “I AM” / divine name frequency  
3. One Sophia remembrance  
4. One Barbelo / Pleroma opening  
5. One neutral ambient bed for player idle state  

**5 frequencies + 8–10 images** is enough for credible App Store v1 if player + favorites + emanation links work.

---

## Roadmap

### Near term (content — Dennis)

- [x] Create **Cloudflare account** + R2 bucket (see [R2 setup checklist](#r2-setup-checklist-dennis))  
- [x] Align Sanity Studio `frequency` fields with GROQ above (`title`, `audio`, `practiceNotes`, `order`, …)  
- [x] First test frequency with R2 audio → verified in app  
- [ ] Publish 3–5 hero frequencies with practice copy  
- [ ] Upload 3+ `.m4a` files to R2 → `audio.url` in Sanity  
- [ ] Upload 8–10 cover images to Sanity

### Near term (code)

- [ ] **CloudKit favorites** sync  
- [ ] **“Practice this frequency”** from `CosmoDetailView` when emanation has linked frequencies  
- [ ] Lock screen / **Now Playing** info  
- [ ] Mini player while browsing library  
- [ ] User playlists or “practice sets”  

### Medium term (personalization stack)

- [ ] **Remembrance journal** (voice/text, tagged to emanation + frequency practiced)  
- [ ] Explorer **journey progress** (visited layers, CloudKit)  
- [ ] **Daily spark** widget (frequency phrase or emanation snippet)  
- [ ] Offline cache for audio + images  

### Explicitly deferred

- Cosmo Stage orb **3D polish** (can resume anytime; not blocking Frequencies)  
- Replacing `CosmoScene.swift` (kept for reference)  

---

## App Review framing (when submitting)

> The website presents Gnostic cosmology as reference material. The iOS app adds **personal spiritual practice**: sacred audio frequencies with looped chanting, favorites synced across the user’s Apple devices, and integration with the interactive cosmology explorer.

Demo account not required if favorites work with iCloud / local storage and content loads from Sanity CDN.

---

## Session log

### June 7, 2026 — Strategy & foundation

**Discussed:**
- App Store need for engagement beyond web content  
- Sacred Sites journal + favorites as proven CloudKit pattern  
- Frequencies as strongest v1 differentiator vs YouTube (context, habit, ownership)  
- Content: AI-assisted MP3s, 15–20 images, external audio hosting  
- Prioritize Frequencies over orb polish  

**Built:**
- `Frequency` model, Sanity fetch, library + player UI  
- Home entry point, favorites (UserDefaults), loop + `AVPlayer`  
- Empty state when no Sanity documents yet  

**Explorer context (same period, separate track):**
- Cosmo Stage replaced carousel; full-screen detail; breadcrumb wayfinding  
- Consort pairs ready when `consortId` populated in Sanity  

### June 8, 2026 — Media hosting strategy

**Discussed:**
- MP3 frequencies + MP4 emanation videos need external hosting (Sanity Enterprise not used)  
- Mux Player reviewed — excellent for **web**, but iOS uses native `AVPlayer`  
- Cost sensitivity for indie/small-app scale  

**Decided:**
- **Cloudflare R2** for MP3s and short MP4s (free tier, no egress fees)  
- **Mux Video** deferred until longer/adaptive video is needed  
- **Sanity CDN** for cover images and posters  
- Dennis creating free Cloudflare account to start  

### June 8, 2026 — End-to-end playback + player polish

**Built:**
- R2 bucket `divine-codex-media` with Public Development URL; test `.m4a` at `frequencies/` prefix  
- Sanity `frequency` schema aligned with `Frequency.swift` (`title`, `audio.url`, `audio.loopable`, `order`, `coverImage`, `practiceNotes`)  
- GROQ coalesces legacy field names (`name`, `notes`, `phoneticSequence`)  
- **First successful play** on iOS: Sanity fetch → R2 URL → `AVPlayer`  

**Player UI:**
- `FrequencyPlayerView` presented via **`fullScreenCover`** (covers library; ✕ to dismiss)  
- Hero cover art sized with **`onGeometryChange`** (preferred over `GeometryReader`)  
- Dynamic square cover dominates launch viewport; guidance text scrolls on small devices  

**Loop fixes (`SacredFrequenciesViewModel`):**
- `applyLoopDefault(from:)` on player open — Sanity seeds initial loop state  
- User loop toggle no longer reset when `play()` starts a new `AVPlayerItem`  
- Loop off: rewind at track end so play restarts from beginning  

---

## Open questions

- R2 **custom domain** timing (before TestFlight vs App Store)  
- Whether favorites migrate to CloudKit before or after first TestFlight  
- Link frequencies from Explorer detail by `associatedEmanationIds` match — UI pattern (button vs section)  
- When to move first video from R2 → Mux (length/quality trigger)

---

## Maintenance note

Update this file when:
- Sanity schema changes  
- Media hosting changes (R2 bucket name, custom domain, Mux adoption)  
- New iOS capabilities ship (CloudKit, Now Playing, Explorer links)  
- Content milestones reached (e.g. “10 frequencies live”)  
- App Review feedback mentions practice/personalization features