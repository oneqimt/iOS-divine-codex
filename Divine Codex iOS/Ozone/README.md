# Ozone — retired / reference code

Files here are **not compiled** into the app (excluded from the Xcode target).
Kept for reference until safe to delete.

## Active explorer stack (use these)

| File | Role |
|------|------|
| `Components/CosmoExplorerView.swift` | Explorer container + navigation |
| `Components/CosmoStage.swift` | Spatial drill-down (Monad → Pleroma → Aeons) |
| `Components/CosmoDetailView.swift` | Full-screen emanation detail |
| `Components/CosmoWayfindingLabel.swift` | Breadcrumb tap target + stage path |
| `Components/CosmoNodeOrb.swift` | Stage orb visuals |
| `ViewModel/ExplorerViewModel.swift` | Tree, stage depth, selection |

## In Ozone (superseded)

| File | Was |
|------|-----|
| `CosmoScene.swift` | RealityKit 3D scene (replaced by Cosmo Stage) |
| `CosmoPlatter.swift` | Horizontal carousel (replaced by Cosmo Stage) |
| `CosmoSidebar.swift` | Split-view detail pane (replaced by CosmoDetailView) |
| `ExplorerNodeButton.swift` | 3D scene node buttons |
| `NodeDetailView.swift` | Floating card detail for 3D scene |
| `NodeLabelView.swift` | Labels for ExplorerNodeButton |
| `RealityKitSupport.swift` | Device capability checks for CosmoScene |

Moved: June 2026.