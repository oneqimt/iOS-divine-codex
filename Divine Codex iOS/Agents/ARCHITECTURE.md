# Divine Codex iOS — Architecture

## Overview

Native iOS companion app to the Divine Codex web experience. The app provides an immersive, mystical exploration of Gnostic cosmology — the Aeons, Sophia’s journey, the 24 Invisibles, the Monad, the Treasury of Light, and the Mysteries of Light — using modern Apple frameworks.

The iOS app is a spiritual and technical counterpart to the Next.js web experience at https://github.com/oneqimt/divine-codex.

## Core Philosophy & Tone (Shared with Web)

- Humanity carries a **Divine Spark** — a fractal of the Monad within each soul.
- Sophia played a key role in bringing this spark into the lower realms.
- Jesus is a **revealer of gnosis**, not a traditional external savior.
- Emphasis on inner awakening, remembrance, and return to the Monad.
- Tone: Mystical, respectful, elegant, contemplative, transcendent.
- Visual language: Deep cosmic dark theme, violet/purple accent (`--violet-flame`), emerald and golden light accents.
- Sacred motif: ✧ (star symbol) used consistently.

## Tech Stack

- **SwiftUI** (primary UI framework, targeting iOS 26.5)
- **Liquid Glass** – foundational design system / component layer used throughout the app for consistent fluid, glass-like, and mystical UI language
- **RealityKit** + **ARKit** (planned for the interactive 3D/immersive Cosmology Explorer)
- **Swift Concurrency** (async/await, actors)
- **SwiftData** or **Core Data** (future local persistence for favorites, progress, notes)
- **Keychain** / **CryptoKit** for secure token storage
- **WidgetKit** (future: contemplative daily reflection widgets)
- **App Intents** / Siri (future: voice-guided journeys)

## Platform & Design System

- **Deployment Target**: iOS 26.5
- **Liquid Glass**: The core visual and interaction foundation used consistently across all screens and components. This provides the fluid, liquid-like behavior, glassmorphism, and sacred aesthetic that defines the app’s experience.
- All major UI elements (buttons, cards, backgrounds, transitions, navigation) are built on or styled through Liquid Glass rather than using raw SwiftUI modifiers directly. This ensures visual and spiritual coherence.

### Device & Orientation Support

This app must support a range of iOS devices with **different orientation rules** depending on screen size and form factor. This is a known complex area.

**Current Guidelines (subject to refinement):**

- **iPad**: Full support for both portrait and landscape in **all views**.
- **Smaller iPhones**: Portrait-only in some views (to be defined).
- **Larger iPhones**: Landscape support may be enabled in selected views.

#### Key Challenges
- Inconsistent orientation rules across different view types and device sizes.
- Complexity of managing layout, navigation, and especially RealityKit scenes during orientation changes.
- Risk of subtle bugs around safe areas, split view, multitasking (iPad), and 3D scene state.
- Historical pain point — this area has proven difficult on previous projects.

#### Anticipated Components
The following managers/helpers are expected to be needed:

- `OrientationManager`
- `DeviceMotionManager`
- `ScreenSizeHelper` (possible)

This subsystem will likely require significant iteration and careful testing. It should be treated as a high-risk area during development.

#### Layout & Geometry Reading Strategy

- Strong preference to **avoid `GeometryReader`** wherever possible. It has historically been a major source of layout instability, performance issues, and unpredictable behavior during orientation changes.
- The primary tool for observing view size and geometry changes will be the `.onGeometryChange` modifier (introduced in iOS 18).
- Size and orientation data should ideally be centralized through `ScreenSizeHelper` and/or `OrientationManager` rather than read directly in individual views.

> **Note**: These rules and the supporting architecture are still early and will almost certainly evolve as the app grows.

## RealityKit Scene Structure (iOS Cosmology Explorer)

This section outlines the early vision and technical direction for the main immersive 3D experience — the Cosmology Explorer — built with RealityKit.

### Vision & Experience Goals
The main 3D scene should feel like a layered, zoomable, spiritually immersive representation of Gnostic cosmology. Users should have the sense of gently floating through sacred space rather than navigating a traditional 3D environment.

Key experiential goals:
- A sense of depth, mystery, and reverence
- Smooth, contemplative navigation between cosmic layers
- Visual harmony with the Liquid Glass design language used elsewhere in the app

### Conceptual Scene Hierarchy (Current Simplified Root — Phase 1)

The scene is organized as a vertical layered cosmos. For the initial implementation we have deliberately simplified the root to a stable, local hierarchy while allowing dynamic content from Sanity to attach beneath it.

**Current Root Entity (Monad) — Containment Rules**

```
CosmologyRoot (RealityKit root Entity)
├── Lighting Rig
│   └── Directional + ambient + subtle point lights (golden / violet sacred palette)
├── Background Layer
│   └── Starfield / subtle nebula (particle or mesh-based)
└── Hierarchy (from ExplorerNode data)
    └── Monad (LocalCosmologySeeds.monad)
        └── Pleroma (LocalCosmologySeeds.pleroma)          // 1:1 containment
            └── Aeons (LocalCosmologySeeds.aeons)           // 1:many containment
                └── Dynamic emanations (Barbelo, Sophia, the 24 Invisibles, etc.)
                    (sourced from Sanity via DivineCodex + explorer visuals)
```

**Key Simplifications (Phase 1)**
- **Monad → Pleroma → Aeons** is the stable local root. The Monad contains exactly one Pleroma. The Pleroma contains one or more Aeons. These three layers are always present from `LocalCosmologySeeds` and are intentionally kept local.
- Individual emanations (Barbelo, Sophia, the 24 Invisibles, etc.) are dynamic. They arrive from Sanity as `DivineCodex` documents, are converted to `ExplorerNode.emanation(...)`, and are merged into the view model. They conceptually live under the Aeons (or directly under the Pleroma during early development).
- Lower realms (Chaos and everything beneath the Aeons) are explicitly deferred.

This containment model (Monad contains Pleroma 1:1, Pleroma contains Aeons 1:many) is the current contract. The visual positions in `ExplorerVisuals` are currently authored in world space. In later phases we can move to true RealityKit parent-child relationships that mirror this containment.

This root is intentionally minimal so we can first get camera focus, node selection, and the expand/reveal interaction solid before adding more cosmological depth.

### Core Technical Components (Early Direction)
- **Main Scene Controller**: `CosmoScene.swift`
- **Camera System**: Smooth orbiting + zoom with gesture support (pan, pinch, double-tap to focus)
- **Entity Manager**: `CosmologyEntityManager` — responsible for showing/hiding layers, coordinating animations, and managing scene state
- **Interaction System**: Tap gestures on entities (especially Syzygies) to surface detail information

**Presentation Model**:
- Tapping the Explorer tab in the main menu navigates to an intermediate `ExplorerView`.
- `ExplorerView` acts as a transitional, mood-setting screen that introduces the experience and explains interaction.
- The actual RealityKit Cosmology Scene is launched from within `ExplorerView` using `.fullScreenCover(isPresented:)`.
- Once inside the full-screen RealityKit experience, there is no menu or persistent navigation.

### Interaction & Navigation
- Pinch to Zoom — Primary method for moving between cosmic layers
- Tap on Syzygy or Entity — Opens contextual detail view with information
- Long Press on Layer — Shows brief contextual tooltip
- Haptic Feedback on meaningful interactions
- VoiceOver Support for accessibility

Future considerations include focus transitions between layers and constrained camera movement that respects the sacred layered structure.

### Animation & Atmosphere
- Gentle pulsing on divine entities
- Flowing light trails for ascent/descent paths
- Particle systems for divine light, stars, and chaotic energy
- Subtle ambient movement to create a living, breathing cosmos

### Performance & Technical Considerations
- Use Level of Detail (LOD) for distant entities
- Occlusion culling where appropriate
- Lazy / progressive loading of high-detail content
- Separate lightweight rendering mode for older devices
- Careful management of particle systems and lighting complexity

### Content & Data Integration (Early Direction)
Since the Sanity schema is still being defined, content integration is intentionally kept high-level for now:

- Descriptive content (names, descriptions, imagery) will eventually be driven by Sanity CMS
- User-specific data (visited layers, favorites, progress) is expected to be stored via Supabase
- The scene should be designed to support data-driven configuration of entities (positioning, visual properties, relationships) once the content models are finalized

This area will require significant refinement after the Sanity Studio schema is established.

### Open Questions & Future Work
- How will entities be created and configured from CMS data?
- What is the final camera and navigation model?
- Will the experience use pure 3D or include AR capabilities?
- How should state be persisted and restored between sessions?
- What level of customization (if any) will users have over the visual experience?



## High-Level Architecture

### Current State (May 2026)
- Brand new project (default SwiftUI template only).
- Single `ContentView` placeholder.
- Git repository initialized and connected to GitHub: https://github.com/oneqimt/iOS-divine-codex.git
- No content, no navigation, no theme implementation yet.

### Target Architecture

```
Divine Codex iOS/
├── Divine Codex iOS/
│   ├── App/
│   │   └── Divine_Codex_iOSApp.swift          # @main entry, theme bootstrap
│   ├── Features/
│   │   ├── Home/                              # Hero + sacred entry experience
│   │   ├── CosmologyExplorer/                 # RealityKit 3D map of the Pleroma (Aeons, Syzygies, etc.)
│   │   ├── SophiaJourney/                     # Interactive retelling of the Fall & Redemption
│   │   ├── Invisibles/                        # 24 Invisibles browser + deep cards
│   │   ├── Codex/                             # Searchable library of gnostic texts & concepts (future sync with Sanity)
│   │   └── Profile/                           # Favorites, reading progress, personal notes (Supabase-backed)
│   ├── Components/
│   │   ├── SacredButton.swift
│   │   ├── AeonCard.swift
│   │   ├── StarfieldBackground.swift
│   │   └── ...
│   ├── Theme/
│   │   ├── Colors.swift                       # Violet Flame, Deep Void, Gold Light, Emerald
│   │   ├── Typography.swift                   # Elegant serif + clean sans
│   │   └── SacredSymbols.swift                # ✧ and other motifs
│   ├── Services/
│   │   ├── ContentService.swift               # Abstraction over local + remote (Sanity + Supabase)
│   │   ├── AuthService.swift                  # Supabase auth
│   │   └── PersistenceService.swift
│   └── Utilities/
│       └── ...
├── Divine Codex iOSTests/
└── Divine Codex iOSUITests/
```

## Key Design Decisions

1. **Component colocated by feature** (not a flat `Components/` folder) to keep related SwiftUI views, view models, and logic together.

2. **RealityKit-first for the Cosmology Explorer** — The heart of the app. Layered 3D representation of the Gnostic hierarchy (Monad → 13 Aeons → 24 Invisibles → lower realms). Users can rotate, zoom, tap to reveal teachings.

3. **Content Strategy**:
   - Primary source of truth: Sanity CMS (shared with web)
   - Local cache + offline support via SwiftData
   - User data (favorites, progress, personal codex notes): Supabase (shared backend with web)

4. **Theming**:
   - Single source of truth in `Theme/` (no hard-coded colors).
   - Matches the web experience exactly where possible (`#0a050f` background, violet accents, etc.).
   - Dark mode only (the cosmos is dark).

5. **Navigation**:
   - Main menu uses a custom Liquid Glass Tab Bar with four destinations: Home, Explorer, Search, Settings.
   - Tapping the Explorer tab navigates to an intermediate `ExplorerView` — a transitional, mood-setting screen with information about the experience.
   - The actual RealityKit Cosmology Scene is launched from within `ExplorerView` using `.fullScreenCover`.
   - The immersive Explorer experience contains no menu or persistent navigation.
   - Deep linking support planned for future "start a guided journey" from web or widgets.
   - Navigation patterns are still evolving and must respect the different orientation rules across device sizes.

6. **Authentication**:
   - Shared Supabase project with the web app.
   - Magic link / Apple Sign In preferred over passwords for the contemplative audience.

## Future / Planned Work (High Level)

- Full interactive Cosmology Explorer (RealityKit scenes for the 13 Aeons, the Fall of Sophia, the Treasury of Light, etc.)
- Offline-first reading experience with beautiful typography
- "Daily Spark" contemplative widgets and notifications
- Cross-device sync of personal Codex (highlights, notes, favorites)
- Optional AR mode for placing the Pleroma in the user's physical space

## Development Notes

- The git repository lives at the folder level containing the `.xcodeproj` (standard Xcode layout).
- Always run `git status` before committing — Xcode loves to touch project files.
- Remote: `origin` → https://github.com/oneqimt/iOS-divine-codex.git

### Git + Xcode Workflow (Important)

Because this project is developed with heavy use of terminal git + AI coding assistants (Grok + Claude working in concert), we have added tooling to reduce the classic Xcode + Git friction.

#### Supporting Files

| File                    | Purpose |
|-------------------------|---------|
| `.gitignore`            | Aggressive rules to ignore `xcuserdata/`, `DerivedData/`, workspace state, etc. |
| `.gitattributes`        | Uses `merge=union` on `*.pbxproj`, `*.xcworkspacedata`, and `*.xcscheme` to reduce painful merge conflicts during rebase / branch work. |
| `bin/reset-xcode.sh`    | Quick reset script for when Xcode shows “file modified by another application” after git operations. |

#### Recommended Ritual After Terminal Git Work

When you (or an AI) perform git operations in the terminal (rebase, pull --rebase, branch switching, etc.):

1. Run the reset script:
   ```bash
   ./bin/reset-xcode.sh
   ```
2. Reopen the project in Xcode.
3. If things still feel off, do **Product → Clean Build Folder** (⇧⌘K).

The script will ask whether you also want to clear workspace user data (open files, breakpoints, etc.). Most of the time you can say no first.

#### Why This Matters

Xcode constantly writes to `project.pbxproj` and files inside `*.xcworkspace/` even when you only open the project. Combined with terminal-based git work and AI agents making structural changes, this creates frequent “modified by another application” warnings. The files above + the reset script are the practical countermeasures while staying with a raw Xcode project.

**Tip:** You can run the reset script proactively whenever Xcode starts feeling sluggish or confused after a big set of AI-driven changes.

## Related Repositories

- Web experience: https://github.com/oneqimt/divine-codex (Next.js 16 + Tailwind + Sanity + Supabase)
- Architecture reference (web): `.claude/skills/architecture/Skill.md` in the web repo

---

**Last Updated**: May 28, 2026  
**Status**: Initial scaffolding complete. Ready for feature development.

✧ May the Divine Spark guide the code. ✧
