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
- **Liquid Class** – foundational design system / component layer used throughout the app for consistent fluid, glass-like, and mystical UI language
- **RealityKit** + **ARKit** (planned for the interactive 3D/immersive Cosmology Explorer)
- **Swift Concurrency** (async/await, actors)
- **SwiftData** or **Core Data** (future local persistence for favorites, progress, notes)
- **Keychain** / **CryptoKit** for secure token storage
- **WidgetKit** (future: contemplative daily reflection widgets)
- **App Intents** / Siri (future: voice-guided journeys)

## Platform & Design System

- **Deployment Target**: iOS 26.5
- **Liquid Class**: The core visual and interaction foundation used consistently across all screens and components. This provides the fluid, liquid-like behavior, glassmorphism, and sacred aesthetic that defines the app’s experience.
- All major UI elements (buttons, cards, backgrounds, transitions, navigation) are built on or styled through Liquid Class rather than using raw SwiftUI modifiers directly. This ensures visual and spiritual coherence.

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
   - SwiftUI `NavigationStack` + `TabView` (Home | Explore | Codex | Profile) for the main experience.
   - Deep linking support for future "start a guided journey" from web or widgets.

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
