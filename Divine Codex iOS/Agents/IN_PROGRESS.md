# Divine Codex iOS — IN PROGRESS

> **Status**: Early Development  
> **Last Updated**: May 28, 2026  
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
- Sanity content schema for the Cosmology Explorer
- How content from Sanity will drive the RealityKit scene

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

- Set up basic folder structure (`Model/`, `View/`, `Components/`, `Util/`, etc.)
- Created initial `DivineCodex.swift` model (generic starting point)
- Added `secret.swift` (should remain untracked)
- Improved git hygiene (`.gitignore`, `.gitattributes`, `bin/reset-xcode.sh`)
- Began documenting in `ARCHITECTURE.md`
- Created `ExplorerView.swift` as the transitional screen before launching the full-screen Cosmology Scene via `.fullScreenCover`
- Built initial HomeView skeleton (with logo + temporary tab bar placeholder)
- Removed default ContentView boilerplate
- Updated `Divine_Codex_iOSApp.swift` to use `HomeView` as the root view (no SplashView for now)

## Secrets / Environment Status

**DO NOT COMMIT ACTUAL SECRETS**

- `secret.swift` (and any similar files) must stay out of git.
- Current Sanity token is being rotated (was used across projects).
- Proper secret management approach still needs to be decided (e.g. `Secrets.xcconfig`, build settings, etc.).

## Next Session Priorities

- Continue refining device/orientation strategy
- Begin defining Sanity schema (or at least initial entities needed for the Cosmology Explorer)
- Flesh out more of the RealityKit architecture
- Decide on secret management solution for Sanity + other APIs


