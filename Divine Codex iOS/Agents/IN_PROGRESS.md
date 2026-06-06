# Divine Codex iOS — IN PROGRESS

> **Status**: Early Development  
> **Last Updated**: June 3, 2026 (ExplorerViewModel moved to Environment + explicit State(initialValue:) in App.init() + caching to eliminate first-tab lag)  
> **Current Focus**: Panning feature for CosmoScene + initialization perf for Explorer tab

## Current Session Focus (June 2, 2026)

**CosmoScene stabilization, camera focus, and component work**

- Performed major cleanup and structural repair of `CosmoScene.swift` after extensive refactoring.
- Fully integrated the modern `ExplorerViewModel` + `ExplorerNode` data model into the 3D scene (replacing old mock `LocalCosmology` data).
- Implemented smooth camera focus animation when selecting nodes, using stable framing that preserves scene context.
- Added single-node visual emphasis (smooth scale) on the focused entity only.
- Refined 3D tap interaction model:
  - Tapping the currently focused node toggles it off and returns the camera to the default overview.
  - Tapping a different node while focused first returns the camera to the default state (important preparation for future panning).
- Created reusable `NodeLabelView` component for displaying node titles.
- Updated `ExplorerNodeButton` to use `NodeLabelView` and aligned its Liquid Glass styling with the TabBarView pattern (using `GlassEffectContainer`).
- Began integration of node labels into the 3D scene via a reliable 2D overlay + projection approach.
- Fixed numerous compilation and view hierarchy issues introduced during heavy editing.

This work brings `CosmoScene` to a stable, modern foundation using the real data model. The camera focus and interaction rules are now solid in preparation for adding manual panning/orbit controls and the detail card + leader line UI.

---

## Current Session Focus (June 3, 2026)

**Panning / manual orbit + dolly for CosmoScene**

- Added full manual camera control to `CosmoScene`:
  - Single-finger drag (minimumDistance: 10) → orbits yaw/pitch around a pivot (last focused node's look-at point or the overview center).
  - Two-finger pinch (MagnificationGesture) → dolly (in/out) with a robust accumulated model that does not jump when lifting and re-pinching.
- Used `.simultaneousGesture` for both so panning works even when starting the drag over a 2D overlay button (label or open detail card). Tiny movements (<10pt) still deliver clean taps to the `ExplorerNodeButton`s.
- While `isUserPanning`, the `SceneEvents.Update` subscription drives `applyUserOrbit` instead of the scripted `animateCameraStep`. `isCameraAnimating` is forced false on gesture start.
- The 2D overlay `ForEach` of `ExplorerNodeButton` (compact `NodeLabelView` or expanded `NodeDetailView`) continues to receive fresh `updateLabelScreenPositions` every frame. Because projection uses the *live* camera (post-orbit or mid-dolly), the cards/labels stay perfectly pinned to their 3D nodes as the user pans. This fulfills the "detail stays pinned to the node's projected point" requirement.
- Selecting any node (via 2D button tap or 3D raycast) cancels manual panning (`isUserPanning = false`) and starts a scripted focus animation to that node from the current (possibly panned) camera pose.
- Clearing selection (tap empty 3D space, tap the x in an open detail, or tap the selected node again) returns camera to overview via animation.
- Cleaned up a duplicate `ForEach` for the overlay buttons (would have rendered every label/detail twice).
- Improved live label projection by removing the unnecessary `DispatchQueue.main.async` wrapper (subscription is main-threaded) for lower latency during fast pans.
- State vars, snapshot logic on gesture entry, `applyUserOrbit`, `resetCameraAndHighlightState`, and distance clamping (5–120) are all in place.
- The interaction model now supports the future "node becomes detail" tween while panned: the large detail card will follow its 3D anchor fluidly.

**TUNING KNOBS (still relevant)**
- `label3DOffsetScaleFactor` / `label3DOffsetBase` in `CosmoScene.swift` control vertical lift of the 2D cards above the 3D entity centers (scale-aware for large nodes like Pleroma).
- In `NodeLabelView.swift`: the vertical padding ternary for stronger 3D compact bg.
- In `applyUserOrbit` / gesture: `sensitivity: Float = 0.004`; pitch clamp ±(π/2 - 0.05); orbitDistance clamp 5...120.
- Pivot choice on pan entry: prefers `cameraTargetLookAt` (so orbiting a focused node feels natural).

Panning is now the primary way to explore the scene once a node is selected or from overview. Scripted focus still "just works" on top of it and interrupts cleanly. Detail cards follow without extra code because they are live-projected overlays, not RealityKit attachments.

**Explorer tab initialization lag follow-up**
- Moved `@State private var explorerViewModel = ExplorerViewModel()` out of `ExplorerView` into app-level ownership (parallel to `SanityViewModel`).
- `ExplorerViewModel` is now injected via `.environment(...)` from `Divine_Codex_iOSApp`.
- Data sync (local + server codices merge) moved to `HomeView` (always-present tab host) using `.onAppear` + `.onChange(of: sanity.codices)`.
- Removed all creation and sync logic from `ExplorerView` itself.
- Added `SanityViewModel.preview` + `PreviewSanityClient` (and updated all related `#Preview`s) so the Environment requirement doesn't break canvas previews.
- Result: any perceived cost of VM init / localHierarchy load now happens at app launch, not on first visit to the Explorer tab. Server data is merged independently of tab visibility.
- Further ViewModel polish: introduced `ExplorerNode.localNodes` static cache (computed once) and a no-op guard in `updateWithServerData` so repeated sync calls (from HomeView .onAppear / codices changes) are essentially free and don't emit unnecessary @Observable updates.
- Lag fully resolved: User applied (and we synced) the explicit `_explorerViewModel = State(initialValue: ExplorerViewModel())` assignment inside `App.init()` (matching the exact pattern used for `_sanity`). This gives deterministic creation timing right after token/client setup. Updated comments in Divine_Codex_iOSApp.swift. Confirmed BUILD SUCCEEDED. Explorer tab now initializes cleanly on first visit.

---

## Current Session Focus (June 1, 2026)

**Explorer data modeling & integration**

- Introduced first-class local models for the upper cosmology: `Monad`, `Pleroma`, and `Aeon` (all with `ExplorerVisuals` for RealityKit placement and styling).
- Created `ExplorerNode` (enum) as the unified representation for the scene graph — capable of holding both local stable data and dynamic `DivineCodex` entries from Sanity (Barbelo, Sophia, other Invisibles).
- Refactored `ExplorerViewModel` to own a `[ExplorerNode]` list and merge local hierarchy with server data via `updateWithServerData(_:)`.
- Wired `fetchCodices()` to trigger on `ExplorerView.onAppear` (with basic error message display in the UI).
- Passed the `explorerViewModel` into `CosmoScene` (preparing for real data-driven rendering).
- Made `DivineCodex` + all nested types, plus the new local models, conform to `Equatable` + `Hashable` (required for SwiftUI observation and `.onChange`).
- Added `LocalCosmologySeeds` as the source of truth for stable local top-level data (Monad → Pleroma → Aeons).
- Added diagnostic logging in `CosmoScene.onAppear` so we can see both raw Sanity data and the combined `ExplorerNode` list.

This work establishes the proper data foundation for the Cosmology Explorer scene while keeping the upper cosmology (Monad / Pleroma / Aeons) as stable local data.

**ExplorerNodeButton styling & visual testing**

- Renamed the component to `ExplorerNodeButton` (clearer naming, avoids potential OS/framework collisions).
- Simplified the button to display only the title for now (short description will be shown in the future detail overlay/popup).
- Applied Liquid Glass styling using `Capsule` + `.glassEffect(.clear, in: .capsule)` with dark translucent fill and gold accent on selection — designed to match the existing TabBar aesthetic.
- Temporarily placed a horizontal test row of `ExplorerNodeButton`s (using local seeds for Monad, Pleroma, and Aeon) directly inside `CosmoScene` on a black background. This allows real-time visual evaluation of the Liquid Glass effect in the running simulator/device.
- Cleaned up leftover placeholder comments and test scaffolding from earlier iterations.

The button is now in a good state for the next phase of work: binding real `ExplorerNode` data and styling the full explorer canvas.

## Current Session Focus

**Wired up the DivineCodex fetch pipeline end-to-end** (May 30, 2026):

- Established the foundational Sanity content layer with proper Swift 6 concurrency semantics.
- Built a modern `@Observable` view model architecture.
- Confirmed a working round-trip from GROQ query → typed Swift values, verified by console output of the two seeded codex documents (`The Call of the Vowels`, `The Restoration of Sophia`).

**Models (`DivineCodex.swift`)**
- Defined `Sendable` value-type models: `DivineCodex`, `Slug`, `SanityImage`, `AssetReference`, `PortableTextBlock`, `TextSpan`, `ImageSource`.
- Added a `nonisolated` `Codable` conformance on `DivineCodex` via extension so it satisfies `T: Decodable & Sendable` from any isolation domain (including `@MainActor` callers).
- Mapped Sanity's wire format to Swift property names via `CodingKeys` (`_id` → `id`, `body` → `description`).
- Made `TextSpan.marks` optional to tolerate spans without marks, which Sanity omits rather than sending as `[]`.

**View model (`SanityViewModel.swift`)**
- Introduced `@Observable @MainActor SanityViewModel` with `codices`, `isLoading`, and `errorMessage` state.
- Injected `SanityClientProtocol` for testability and preview-friendliness.
- Implemented `fetchCodices()` with structured error handling and `OSLog` `Logger` output (privacy-annotated).

**App composition (`Divine_Codex_iOSApp.swift`)**
- Owned a single `SanityViewModel` as `@State` at the `App` level.
- Injected it via the new typed `.environment(_:)` API for `@Observable` (no `EnvironmentObject`).
- Constructed `SanityClient` with environment-appropriate CDN behavior (fresh in DEBUG, cached in RELEASE).
- Kicked off an initial `fetchCodices()` smoke test from a root `.task`.

**Views**
- `ExplorerView` reads the view model via `@Environment(SanityViewModel.self)`.

**Cleanup**
- Removed duplicate model declarations that were causing redeclaration and ambiguity errors across the target.
- Resolved a "Multiple commands produce `SanityClient.stringsdata`" build error caused by `SanityClient.swift` being listed twice in Compile Sources.


## Key Decisions & Rationale

- **Device & Orientation Strategy**: iPads get full portrait + landscape. Smaller phones are portrait-only in some views. Larger phones may support landscape selectively. (This area is known to be tricky.)
- **Geometry Reading**: Strong preference to avoid `GeometryReader`. Primary tool will be `.onGeometryChange` (iOS 18+), ideally centralized through managers.
- **Design System**: Using "Liquid Glass" as the foundational UI language throughout the app.
- **Navigation & Presentation Model**:
  - Main menu uses a custom Liquid Glass Tab Bar with 4 tabs: Home, Explorer, Search, Settings.
  - Tapping the **Explorer** tab navigates to an intermediate `ExplorerView`.
  - `ExplorerView` acts as a transitional, mood-setting screen that introduces the Cosmology Explorer and explains how to interact with it.
  - The actual RealityKit Cosmology Scene is launched from *within* `ExplorerView` using `.fullScreenCover(isPresented:)`.
  - The immersive 3D experience has no menu or persistent navigation.
- **RealityKit Cosmology Explorer**: Early vision documented in ARCHITECTURE.md. Layered 3D representation of Gnostic cosmology is the heart of the app.
- **Sanity Schema**: Still undecided. Current models in `Model/DivineCodex.swift` are generic placeholders. Expect refactoring once the schema is defined in Sanity Studio.

## Open Questions / Blockers

- Final device/orientation rules and implementation approach (OrientationManager, DeviceMotionManager, ScreenSizeHelper)
- How content from Sanity (especially emanations) will drive the RealityKit Cosmology Explorer scene
- Exact fields needed on `emanation` vs `divineCodex` (will be refined once Studio is live)

## Important Context for Next Session

- This project is in very early stages.
- Working with both Grok and Claude.
- Website exists at: https://divine-codex-chi.vercel.app/
- ARCHITECTURE.md contains the current source of truth for vision and technical direction.

## Architecture & Design Notes

- See `ARCHITECTURE.md` (in this folder) for the main reference.
- Key high-level sections:
  - Platform & Design System (Liquid Glass + Device/Orientation rules)
  - RealityKit Scene Structure for the Cosmology Explorer
  - Tech Stack (iOS 26.5 + SwiftUI + RealityKit)

## Recent Work / Changes
- **DivineCodex fetch pipeline working end-to-end** (May 30, 2026): Sendable Codable models with Sanity key mappings, `@Observable` `@MainActor` `SanityViewModel` with injected `SanityClientProtocol`, and app-level environment composition driving an initial fetch on launch. Verified by console output of seeded codex documents. See "Current Session Focus" above for details.
- **Sanity Studio foundation complete** (May 29, 2026): Full schema implemented + custom desk structure + seeded content. See detailed section below under "Sanity Schema – Actual Implementation".
- Set up basic folder structure (`Model/`, `View/`, `Components/`, `Util/`, etc.)
- Created initial `DivineCodex.swift` model (generic starting point)
- Added `secret.swift` (should remain untracked)
- Improved git hygiene (`.gitignore`, `.gitattributes`, `bin/reset-xcode.sh`)
- Began documenting in `ARCHITECTURE.md`
- Created `ExplorerView.swift` as the transitional screen before launching the full-screen Cosmology Scene via `.fullScreenCover`
- Built initial HomeView skeleton (with logo + temporary tab bar placeholder)
- Removed default ContentView boilerplate
- Updated `Divine_Codex_iOSApp.swift` to use `HomeView` as the root view (no SplashView for now)
- First successful build + run on simulator (HomeView displaying correctly)

## Secrets / Environment Status

**DO NOT COMMIT ACTUAL SECRETS**

- `secret.swift` (and any similar files) must stay out of git.
- Current Sanity token is being rotated (was used across projects).
- Proper secret management approach still needs to be decided (e.g. `Secrets.xcconfig`, build settings, etc.).

## Sanity Setup Status

- New personal Organization created for Divine Codex (separate billing from client project).
- Project created inside the new Organization.
- Currently on Free tier.
**Sanity Studio created and deployed** (May 29, 2026) with initial schema and seeded content. See detailed implementation section below.

### Sanity Schema – Current Implementation (June 6, 2026) ✅ AUTHORITATIVE

> This section supersedes the May 29 "Actual Implementation" section below.

**Key decision:** the app renders a node tree, so the data is a node tree. The `emanation` self-reference (`parent`) is the backbone; `divineCodex` was removed as redundant.

**Hierarchy (how it maps to the 3D scene):**

```
Monad      → emanation, emanationType "Monad",  parent = null   (root node)
Pleroma    → emanation, emanationType "Pleroma", parent = Monad  (first child)
12 Aeons   → emanation, emanationType "Aeon",    parent = Pleroma  ┐
12 consorts→ emanation, emanationType "Aeon",    parent = Pleroma  ┘ 24 second-child nodes
                                                 consort ↔ links each pair
```

**Document Types (current):**

| Type            | Purpose                                                                 |
|-----------------|-------------------------------------------------------------------------|
| `emanation`     | **The spine.** Cosmological nodes (Monad, Pleroma, Aeons). Drives the 3D scene AND carries its own detail content. |
| `emanationType` | Taxonomy. Currently only: **Monad, Pleroma, Aeon** (The One & Syzygy removed). |
| `frequency`     | Sacred utterances / meditation sounds.                                  |
| ~~`divineCodex`~~ | **Removed.** Was the editorial layer; made redundant once `emanation` became self-contained. Reversible via git if a long-form "teachings" layer is wanted later. |

**`emanation` fields (relevant changes):**
- `parent` → self-reference (hierarchy).
- `consort` → self-reference for syzygy pairs (**renamed from `counterpart`**). Stored as "consort"; surfaced as "Syzygy" in the app. Set on both members.
- `order` → number; traditional sequence among siblings (the 12 syzygies). Distinct from `explorer.layerOrder` (z-depth).
- `gender` → masculine / feminine / neutral / pair.
- `shortDescription`, `description` (Portable Text) → detail text.
- `media` → array of images (caption + alt) for the detail view. **(new)**
- `video` → object: `url` (HLS/MP4), `posterImage`, `provider`. External host (Mux/Cloudflare/Vimeo/etc.) — Sanity only hosts video on Enterprise. AVPlayer plays HLS natively on iOS. **(new)**
- `explorer` → unchanged: `layerOrder`, `position {x,y,z}`, `color` (hex), `scale`, `isVisibleByDefault`, `geometryHint`.

**Relationships:**
- `emanation.parent` → self (hierarchy)
- `emanation.consort` → self (syzygy pair)
- `emanation.emanationType` → `emanationType`
- `frequency.associatedEmanations` → array of `emanation` (frequency↔emanation link survives independently of the removed divineCodex)

**Studio structure (`studioStructure.ts`):** nav now leads with **Cosmology** (Emanations + Emanation Types), then Frequencies & Utterances.

**Retrieval (confirmed):** one flat GROQ query returns all emanations with explorer data + `parentId`/`consortId`; build the tree in Swift. Map `position{x,y,z}` → `SIMD3<Float>`, `color` hex → `UIColor`, `geometryHint` → `MeshResource`.

```groq
*[_type == "emanation"] | order(order asc){
  _id, name, "slug": slug.current, gender, order,
  "type": emanationType->name,
  "parentId": parent._ref,
  "consortId": consort._ref,
  explorer{ layerOrder, position, color, scale, isVisibleByDefault, geometryHint },
  shortDescription, media, video
}
```

**Current dataset state (test data):** types = Monad / Pleroma / Aeon. Emanations = The One (→Monad), Autogenes / Barbelo / Sophia / Christos (→Aeon). Old broken parent/counterpart refs were cleared. Real backbone nodes (Monad/Pleroma emanations) + the 24 Aeon pairs not yet seeded.


**Core Documents:**
- `divineCodex` → Primary flexible content document (editorial layer). This will be the main document used for most content and detail views.
- `emanation` → First-class structural document. This represents the actual cosmological entities (Aeons, Syzygies, Treasury, Mysteries, etc.).

**Key Decisions:**
- `emanation` will be a document type (not a simple enum). It will have an `emanationType` reference (similar to the `religion` document pattern from the Sacred Sites project).
- An `emanation` can declare properties for masculine/feminine (for Syzygies).
- Explorer-specific fields (layerOrder, position, color, scale, isVisibleByDefault, etc.) will likely exist on both `divineCodex` and `emanation`.
- Use standard Sanity `reference` fields for hierarchy (e.g. `parent` on emanation).
- `divineCodex` will have a reference to `emanation` (this will drive the "aeon type" / entity association dropdown).

**Notes:**
- This is the first iteration. Refactoring is expected once we start building the RealityKit Cosmology Explorer and see real data needs.
- Queries will live in ViewModels or a dedicated queries file (not scattered).
- Mutations will be handled in CloudKit / Firebase, not Sanity.
- Portable Text usage will be light (mainly detail views).


**Document Types Created in Sanity Studio:**

| Type            | Purpose                                                        | Key Characteristics                                        |
|-----------------|----------------------------------------------------------------|------------------------------------------------------------|
| `divineCodex`   | **Primary editorial hub**. Everything maps into these entries. | Main content used for most detail views in the app.        |
| `emanation`     | Structural cosmology entities (Aeons, Syzygies, etc.)          | Drives the 3D RealityKit scene.                            |
| `emanationType` | Taxonomy (The One, Aeon, Syzygy, etc.)                         | Simple reference target (like `religion` in Sacred Sites). |
| `frequency`     | Sacred utterances / deep meditation sounds                     | New type added during this session.                        |

**Core Relationships:**
- `divineCodex.primaryEmanation` → `emanation` (required)
- `divineCodex.relatedEmanations` → array of `emanation`
- `divineCodex.frequencies` → array of `frequency`
- `emanation.emanationType` → `emanationType`
- `emanation.parent` → self (hierarchy)
- `emanation.counterpart` → self (for Syzygies)
- `frequency.associatedEmanations` → array of `emanation`

**Explorer Visualization Fields** (shared pattern on both `divineCodex` and `emanation`):

```ts
explorer: {
  layerOrder: number,           // Z-depth / rendering order
  position: { x, y, z: number },
  color: string,                // Hex (#C9A227)
  scale: number,
  isVisibleByDefault: boolean,
  geometryHint: string,         // "sphere" | "torus" | "octahedron" | "icosahedron" | "light" etc.
  notes?: string                // Guidance for the 3D scene
}
```

These fields were explicitly designed to feed the RealityKit Cosmology Explorer.

**Custom Studio Structure:**
- Prominent **Divine Codex** section at the top (the main object).
- **Cosmology** group containing Emanations + Emanation Types.
- **Frequencies & Utterances** section.
- Clean icons and logical ordering for good iOS + content team UX.

**Seeded Example Content (published):**
- 3 Emanation Types: The One, Aeon, Syzygy
- 5 Emanations with full explorer data: The One, Barbelo, Autogenes, Sophia, Christos
- 3 Frequencies (using your examples):
  - "Primordial Vowels" → `i, e, o, u, a`
  - "I AM THAT I AM" → `eh-YEH ah-SHER eh-YEH`
  - "OH GO BEE JA DA"
- 2 Divine Codex entries that demonstrate cross-linking (`The Call of the Vowels` and `The Restoration of Sophia`)

**Other Studio Updates:**
- `sanity.cli.ts` updated with `appId` + improved deployment comments.
- Added `.nvmrc` (Node 22.15) for consistent environment.

## Next Session Priorities

- **Build pretty Liquid Glass Node components** — Create `Components/Node.swift` (and supporting views) that render `ExplorerNode` data beautifully using the app's Liquid Glass design language. This will be used both in 2D overlays and as the visual representation layer for the 3D scene.
- **Bind ExplorerNode data to the RealityKit scene** — Update `CosmoScene` to create entities from the new `ExplorerNode` list (instead of old `MockCosmicNode` mocks). Use `explorer` visuals from local models + map explorer data from `DivineCodex`.
- **Improve hierarchy merging** — Make `ExplorerViewModel.updateWithServerData` smarter about where Sanity entries (Barbelo, Sophia, Invisibles) should attach in the tree (under specific Aeons).
- **Sanity Studio is now live** with working schema and seeded content. Review the actual implementation section above.
- **Render `sanity.codices` in `ExplorerView`** (or a dedicated list view) so real data drives the UI, not just console output.
- **Remove the smoke-test `print` statements** from `fetchCodices()` once a view actually consumes `sanity.codices`. The `OSLog` `Logger` lines stay; the `print`s go.
- **Move the `.task { await sanity.fetchCodices() }`** off `Divine_Codex_iOSApp` and onto whichever view first displays codices, so loading is coupled to need rather than launch.
- **Grow the `DivineCodex` model deliberately**: Sanity payloads already include `shortDescription`, `keywords`, `explorer`, `primaryEmanation`, `relatedEmanations`, `frequencies`, `sources`, `publishedAt`, etc. Add fields only when a view needs them.
- **Build a Portable Text renderer** — a small view that walks `[PortableTextBlock]` and styles spans by `marks`, ideally backed by `AttributedString`.
- **Image loading via `AsyncImage`** once codices include images. `SanityImage` + `AssetReference` already model the asset ref; a URL builder (`https://cdn.sanity.io/images/{projectId}/{dataset}/{ref}`) is the missing piece.
- **Add a Swift Testing target for `SanityViewModel`** — fake `SanityClientProtocol`, assert `fetchCodices()` populates `codices` on success and `errorMessage` on failure.
- Collaborate on refining the schema as the RealityKit Cosmology Explorer is built (new explorer fields, additional relationships, etc.).
- Build and style the real custom Liquid Glass `TabBarView`.
- Wire up the TabBar into `HomeView` and implement basic navigation between Home / Explorer / Search / Settings.



