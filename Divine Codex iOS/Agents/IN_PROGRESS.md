# Divine Codex iOS — IN PROGRESS

> **Status**: Early Development  
> **Last Updated**: June 2026  
> **Current Focus**: ExplorerNode data model + integration of local + Sanity cosmology data

## Current Session Focus (June 2026)

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

### Sanity Schema – Current Direction (First Iteration)

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


