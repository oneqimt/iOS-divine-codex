# Sacred Frequencies — Feature Reference

> **Status**: Foundation implemented (June 2026)  
> **Priority**: **Game changer** — primary App Store differentiation & user personalization  
> **Related**: `IN_PROGRESS.md` (explorer), `ARCHITECTURE.md` (vision)  
> **Last Updated**: June 7, 2026

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
3. Host audio externally (Cloudflare R2, Mux, S3 + CDN, etc.)  
4. Upload cover images to Sanity  
5. Scale from **~5 hero frequencies** → 15–20 when the loop feels right  

**Do not** rip audio from YouTube — inspiration only; ship owned/licensed assets.

---

## Sanity schema (target)

Document type: `frequency` (already listed in Studio nav under Frequencies & Utterances).

| Field | Purpose |
|-------|---------|
| `title` or `name` | Display name (GROQ uses `coalesce(title, name)`) |
| `slug` | URL slug |
| `shortDescription` | Card / list subtitle |
| `practiceNotes` | How to chant — shown in player |
| `pronunciationGuide` | Phonetic line (e.g. vowels, divine names) |
| `order` | Sort order in library |
| `audio.url` | Externally hosted audio URL |
| `audio.loopable` | Default `true` for practice |
| `coverImage` | Sanity image asset (player + list thumbnail) |
| `associatedEmanations` | References to `emanation` docs |

Optional Studio object shape:

```ts
audio: {
  url: string,        // MP3, AAC, or HLS
  loopable: boolean,
  durationSeconds?: number
}
coverImage: image
```

### GROQ query (authoritative — matches iOS app)

```groq
*[_type == "frequency"] | order(order asc){
  _id,
  "title": coalesce(title, name),
  "slug": slug.current,
  shortDescription,
  practiceNotes,
  pronunciationGuide,
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

---

## iOS implementation (current)

### User flow

1. **Home** → tap **Sacred Frequencies** (Liquid Glass button above tagline)  
2. **FrequenciesLibraryView** — list all frequencies; filter **favorites** (heart in toolbar)  
3. Tap row → **FrequencyPlayerView** (sheet) — cover, play/pause, loop, practice text, favorite  
4. Without `audioUrl`: text practice + “audio coming soon” banner still works  

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
- `AVPlayer` with end-of-track observer; **loop** when `audioLoopable` / user toggle on  
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

- [ ] Align Sanity Studio `frequency` fields with GROQ above  
- [ ] Publish first 3 text-only frequencies → verify in app  
- [ ] Host 3 MP3s → add `audio.url`  
- [ ] Upload 8–10 cover images  

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

---

## Open questions

- Exact Sanity field names in Studio vs GROQ `coalesce` fallbacks — verify on first real document  
- Preferred audio host (R2 vs Mux vs other)  
- Whether favorites migrate to CloudKit before or after first TestFlight  
- Link frequencies from Explorer detail by `associatedEmanationIds` match — UI pattern (button vs section)  

---

## Maintenance note

Update this file when:
- Sanity schema changes  
- New iOS capabilities ship (CloudKit, Now Playing, Explorer links)  
- Content milestones reached (e.g. “10 frequencies live”)  
- App Review feedback mentions practice/personalization features