# Divine Codex iOS — IN PROGRESS

> **Status**: Early Development  
> **Last Updated**: May 29, 2026  
> **Current Focus**: Foundational architecture + setup

## Current Session Focus

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

- **Sanity Studio is now live** with working schema and seeded content. Review the actual implementation section above.
- Collaborate on refining the schema as the RealityKit Cosmology Explorer is built (new explorer fields, additional relationships, etc.).
- Begin defining GROQ queries and TypeScript models in the iOS app that consume `divineCodex`, `emanation`, and `frequency`.
- Build and style the real custom Liquid Glass TabBarView.
- Wire up the TabBar into HomeView and implement basic navigation between Home / Explorer / Search / Settings.


