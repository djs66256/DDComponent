# DDComponent Example Redesign Spec

## Overview

Redesign the Example app to systematically demonstrate all DDComponent framework capabilities through 10 progressive, self-contained demos + 1 integration example.

**Date:** 2026-07-16
**Status:** Approved

---

## Goals

1. **Full capability coverage** — every DDComponent public API has at least one demo exercising it
2. **Self-contained demos** — each demo folder contains everything needed to understand and copy-paste it; zero cross-demo dependencies
3. **Progressive difficulty** — 🟢 basic → 🟡 intermediate → 🔴 advanced
4. **Dogfooding** — the Main navigation itself uses DDComponent (`UITablePageDefaultViewController`)
5. **Code as documentation** — each demo includes comments explaining which capability is being shown and why

---

## Design Decisions

| Decision | Choice | Rationale |
|---|---|---|
| File organization | `Demos/01-HelloDDComponent/`, `02-ServiceDI/`, ... | Self-contained, easy to navigate, each folder is a standalone recipe |
| Code sharing | None between demos | Copy-paste ready; no cross-demo imports |
| CyclePageView | Keep as "📦 Integration" at bottom of list | Not core DDComponent but shows integration pattern |
| Snippets/ directory | Delete | Each demo is its own template |
| Main page | `UITablePageDefaultViewController` | Dogfooding: the framework demo uses the framework |
| Deleted files | `FunctionViewController`, `Image.swift`, `Text.swift`, all old Page1/CyclePage/Collection/Table VC files, Snippets/ | Removes dead code and non-framework content |

---

## Main Page

`MainViewController` is rewritten to use `UITablePageDefaultViewController` (dogfooding). It renders the demo list as a UITableView where each row is a demo entry. Tapping a row pushes the corresponding demo ViewController.

Each row shows: emoji + number + title (e.g., "🟢 01  HelloDDComponent").

The data source is a static array of `(title: String, vc: () -> UIViewController)` tuples, feeding `UITableViewSectionPresenter` with `UITableViewItemPresenterHolder` instances.

The CyclePageView integration entry appears at the bottom of the list, separated by a visual divider.

---

## New File Structure

```
Example/DDComponent/
├── AppDelegate.swift                              (unchanged)
├── Info.plist                                     (unchanged)
├── MainViewController.swift                       (rewrite: UITablePageDefaultViewController)
│
├── Demos/
│   ├── 01-HelloDDComponent/
│   │   ├── HelloViewController.swift
│   │   ├── HelloViewPresenter.swift
│   │   └── HelloView.swift
│   │
│   ├── 02-ServiceDI/
│   │   ├── ServiceDIViewController.swift
│   │   ├── ServiceDIRootPresenter.swift
│   │   ├── ServiceDIView.swift
│   │   ├── DataLoaderService.swift
│   │   └── CounterService.swift
│   │
│   ├── 03-NotifySystem/
│   │   ├── NotifyViewController.swift
│   │   ├── NotifyRootPresenter.swift
│   │   ├── NotifyView.swift
│   │   ├── ParentPresenter.swift
│   │   ├── ChildPresenter.swift
│   │   └── NotifyLogger.swift
│   │
│   ├── 04-PTreeComposition/
│   │   ├── PTreeViewController.swift
│   │   ├── PTreeRootPresenter.swift
│   │   ├── PTreeView.swift
│   │   ├── HeaderPresenter.swift
│   │   ├── BodyPresenter.swift
│   │   └── FooterPresenter.swift
│   │
│   ├── 05-ListDiffUpdate/
│   │   ├── ListViewController.swift
│   │   ├── ListRootPresenter.swift
│   │   ├── ListView.swift
│   │   ├── CardCell.swift
│   │   ├── CardItemPresenter.swift
│   │   └── DataGenerator.swift
│   │
│   ├── 06-HeaderFooter/
│   │   ├── HeaderFooterViewController.swift
│   │   ├── HeaderFooterRootPresenter.swift
│   │   ├── HeaderFooterView.swift
│   │   ├── SectionHeaderView.swift
│   │   ├── SectionHeaderPresenter.swift
│   │   └── SectionFooterView.swift
│   │
│   ├── 07-AnimationContext/
│   │   ├── AnimationViewController.swift
│   │   ├── AnimationRootPresenter.swift
│   │   ├── AnimationView.swift
│   │   └── BounceAnimator.swift
│   │
│   ├── 08-IsolatedPresenter/
│   │   ├── IsolatedViewController.swift
│   │   ├── IsolatedRootPresenter.swift
│   │   ├── IsolatedView.swift
│   │   ├── StarButton.swift
│   │   └── StarButtonPresenter.swift
│   │
│   ├── 09-AutoBind/
│   │   ├── AutoBindViewController.swift
│   │   ├── AutoBindRootPresenter.swift
│   │   ├── AutoBindView.swift
│   │   └── ShadowPresenter.swift
│   │
│   └── 10-FeedExample/
│       ├── FeedViewController.swift
│       ├── FeedRootPresenter.swift
│       ├── FeedView.swift
│       ├── FeedCardCell.swift
│       ├── FeedCardPresenter.swift
│       ├── LikeService.swift
│       ├── LikeButton.swift
│       └── LikeButtonPresenter.swift
│
└── CyclePageExample/
    ├── CyclePageViewController.swift
    ├── CyclePageRootPresenter.swift
    └── CyclePageConfig.swift
```

---

## Demo Specifications

### 🟢 01 — HelloDDComponent (Basic)

**Capabilities demonstrated:**
- `ViewPresenter<View>` with `setState` and `onUpdate(view:context:)`
- Full lifecycle logging: `onAttach` → `onBindView` → `onUpdate` → `onUnbindView` → `onDetach`
- Minimal `PageViewController` subclass
- `@PageInstallerBuilder` with `PresenterInstaller`

**Files (3):**
- `HelloView.swift` — View protocol + UIView with UILabel (counter) + UIButton (+1)
- `HelloViewPresenter.swift` — `ViewPresenter<HelloViewable>`, state: `count: Int`
- `HelloViewController.swift` — `PageViewController<HelloView, HelloViewPresenter, HelloViewable>`

**User-visible behavior:**
- Counter label starts at 0
- Tap +1 button → label increments via setState → onUpdate
- Navigate away and back → console prints full lifecycle cycle

---

### 🟢 02 — Service & DI (Basic)

**Capabilities demonstrated:**
- `ServiceInstaller` (eager and lazy)
- `getService()` lookup
- Service downgrade / fallthrough to global
- `ManagedViewPresenter` as service registrar

**Files (5):**
- `DataLoaderService.swift` — `DataLoader` protocol + `MockDataLoader` (delayed callback)
- `CounterService.swift` — `CounterService` protocol + `MockCounterService` + global downgrade impl
- `ServiceDIView.swift` — Two label areas: "Loaded Data" and "Counter"
- `ServiceDIRootPresenter.swift` — Uses `getService()` to fetch data and counter; demonstrates lazy vs eager instantiation timing
- `ServiceDIViewController.swift` — Registers services via `@PageInstallerBuilder`

**User-visible behavior:**
- On load: "Loading..." for 1 second → data appears
- Counter starts at a value from service; tap to increment
- Console logs when lazy service is first accessed vs eager service created upfront

---

### 🟢 03 — Notify System (Basic)

**Capabilities demonstrated:**
- `.global` — broadcast from root to all
- `.children` — down the P-tree
- `.parents` — up the P-tree
- `.reusable` — nearest reusable parent
- `ServiceInstaller(listenTo:)` — auto-register service as listener

**Files (6):**
- `NotifyView.swift` — 4 colored zones, each with a "Send" button
- `ParentPresenter.swift` — Sends `notifyChildren`, receives `notifyParents`
- `ChildPresenter.swift` — Receives `notifyChildren`, responds by changing color
- `NotifyLogger.swift` — Implements listener protocols; logs and flashes on notification
- `NotifyRootPresenter.swift` — Manages child presenters with `typeBox`; demonstrates all 4 scopes
- `NotifyViewController.swift` — Standard PageViewController

**User-visible behavior:**
- 4 zones labeled "Global", "Children", "Parents", "Reusable"
- Tap a zone's button → that scope fires → receiving zones flash with color change
- Console prints: `[Notify] scope=.children from=<Presenter> to=<Presenter>`

---

### 🟡 04 — P-Tree Composition (Intermediate)

**Capabilities demonstrated:**
- `typeBox()` / `typeUnbox()` for child presenter management
- `ViewGroupPresenter` for key-based child access
- Data flow from root → children through P-tree
- Theming: one state change cascades to all children

**Files (6):**
- `HeaderPresenter.swift` — Shows title text
- `BodyPresenter.swift` — Shows content text
- `FooterPresenter.swift` — Shows action buttons
- `PTreeRootPresenter.swift` — `typeBox(HeaderPresenter())` etc; toggle theme
- `PTreeView.swift` — UIView with header/body/footer subviews
- `PTreeViewController.swift`

**User-visible behavior:**
- Page shows header + body + footer sections
- "Toggle Theme" button in nav bar → root sets theme state → all 3 child presenters update colors simultaneously

---

### 🟡 05 — List & Diff Update (Intermediate)

**Capabilities demonstrated:**
- `CollectionPresenter` → `CollectionSectionPresenter` → `CollectionItemPresenter` hierarchy
- Diff-based partial updates (insert, delete, move, shuffle)
- `calculateSizeAutomatically` for self-sizing cells
- `UICollectionItemFlowPresentable` for item-level layout
- `UICollectionViewFlowSectionPresentable` for section-level layout

**Files (6):**
- `CardCell.swift` — UICollectionViewCell with title, description, color bar
- `CardItemPresenter.swift` — `CollectionItemPresenter<CardCell>`, self-sizing
- `ListRootPresenter.swift` — Manages data array; exposes add/delete/move/shuffle operations
- `ListView.swift` — UICollectionView + 4 action buttons
- `DataGenerator.swift` — `CardData` struct + random generator
- `ListViewController.swift` — `UICollectionFlowPageViewController`

**User-visible behavior:**
- 10 cards displayed in a vertical flow layout
- Buttons: "Shuffle", "Add One", "Remove Random", "Reload All"
- Shuffle/Add/Remove trigger animated diff updates (not full reload)

---

### 🟡 06 — Header & Footer (Intermediate)

**Capabilities demonstrated:**
- `CollectionSectionPresenter.supplementaries` for headers/footers
- `UICollectionViewReusablePresenter` for supplementary views
- Collapsible sections (header tap toggles section visibility)
- `UICollectionViewFlowSectionPresentable.supplementaryLayoutInfo`

**Files (6):**
- `SectionHeaderView.swift` — Tappable header with title + collapse indicator
- `SectionHeaderPresenter.swift` — `UICollectionViewReusablePresenter<SectionHeaderView>`, manages collapsed state
- `SectionFooterView.swift` — Simple footer with "N items" label
- `HeaderFooterView.swift` — CollectionView container
- `HeaderFooterRootPresenter.swift` — 3 sections, each with header + footer + items
- `HeaderFooterViewController.swift`

**User-visible behavior:**
- 3 sections, each with colored header ("Section A/B/C ▼") and footer ("3 items")
- Tap a header → section collapses/expands with animation

---

### 🟡 07 — Animation & ViewUpdateContext (Intermediate)

**Capabilities demonstrated:**
- `ViewUpdateContext.animated` — UIView animation block
- `ViewUpdateContext.invalidateContentSize` — trigger layout recalculation
- `ViewUpdateContext.invalidateLayout` — trigger constraint refresh
- `ViewUpdateContext.forceDisableAnimation` — suppress animations
- Custom `ViewUpdateAnimator` — spring-based bounce animation

**Files (4):**
- `BounceAnimator.swift` — Implements `ViewUpdateAnimator` with `UIView.animate(damping:...)`
- `AnimationView.swift` — Colored square + control buttons
- `AnimationRootPresenter.swift` — Manages size/position/color state; 4 different context configurations
- `AnimationViewController.swift`

**User-visible behavior:**
- A colored square in center of screen
- 4 buttons:
  - "Move (animated)" → square slides with default animation
  - "Resize (bounce)" → square changes size with spring bounce
  - "Change Color (silent)" → color changes without animation
  - "Expand (layout)" → size change triggers `invalidateLayout` on parent

---

### 🔴 08 — IsolatedViewPresenter (Advanced)

**Capabilities demonstrated:**
- `IsolatedViewPresenter<UI, P, V>` — use presenter without PageViewController
- Using a presenter as a standalone embeddable component
- Integrating isolated presenters into a P-Tree via `add(child:)`

**Files (5):**
- `StarButton.swift` — UIView with star icon; implements `StarButtonViewable`
- `StarButtonPresenter.swift` — `ViewPresenter<StarButtonViewable>`, manages isStarred state
- `IsolatedView.swift` — Plain UIView with 3 StarButtons added programmatically
- `IsolatedRootPresenter.swift` — Wraps each StarButton in `IsolatedViewPresenter`, then `add(child:)` to P-tree
- `IsolatedViewController.swift` — Standard PageViewController

**User-visible behavior:**
- 3 independent star buttons displayed vertically
- Tapping any star toggles it on/off independently
- Each star has its own presenter, but all participate in the P-tree for lifecycle management

---

### 🔴 09 — AutoBind & Shadow Presenter (Advanced)

**Capabilities demonstrated:**
- `autoBindView = true` — automatic BFS view discovery
- `ViewAutoBindable.findView<T>()` — custom view lookup
- Shadow Presenter pattern — presenter without its own view, uses parent's view
- `bindWeakView(_:)` — weak view binding

**Files (4):**
- `AutoBindView.swift` — Complex UIView with named subviews; implements `ViewAutoBindable`
- `AutoBindRootPresenter.swift` — typeBox 3 child presenters, all `autoBindView = true`; root only binds the top-level view
- `ShadowPresenter.swift` — Child presenter that searches for and reuses parent's view; logs its view discovery path
- `AutoBindViewController.swift`

**User-visible behavior:**
- Root binds one view
- 3 child presenters auto-discover their subviews via BFS
- Shadow presenter shares parent's view, logs: "[Shadow] Found view via BFS: <UIView:0x...>"

---

### 🔴 10 — Feed Example (Advanced)

**Capabilities demonstrated (comprehensive):**
- All previous: Service, Notify, Diff, Nested Presenters, Holder Pattern
- `ReusableViewPresenter` with `UICollectionViewFlowItemPresenterHolder`
- `notifyReusable` — notification scoped to reusable parent
- Diff-based insert/update on data refresh
- Complex nested presenter composition (card → image + text + like button)

**Files (8):**
- `LikeService.swift` — `LikeService` protocol + `MockLikeService` (simulated API)
- `LikeButton.swift` — Like button UIView
- `LikeButtonPresenter.swift` — Manages like state; calls `getService(LikeService)` then `notifyReusable` on completion
- `FeedCardCell.swift` — UICollectionViewCell: avatar, name, content, image, like button
- `FeedCardPresenter.swift` — `ReusableViewPresenter<FeedCardViewable>`; child presenters for avatar, text, like
- `FeedView.swift` — CollectionView container + refresh button
- `FeedRootPresenter.swift` — Manages feed data array; handles `LikeListener` to update model; triggers diff updates
- `FeedViewController.swift`

**User-visible behavior:**
- Feed of 5 posts with avatar, content, image, like count
- Tap like → animated heart fill + count update (Service call → notifyReusable → diff update)
- "New Post" button → mock new data inserted at top with diff animation
- "Refresh" button → shuffle + diff update

---

### 📦 CyclePageView Integration (Legacy)

**Capabilities demonstrated:**
- Integrating a custom scroll container (`CyclePageView`) with `RootViewPresenter`
- `ReusableViewPresenter` lifecycle with page reuse
- Child presenter nesting per page

**Files (3 + 1 moved):**
- `CyclePageView.swift` — **moved** from root (unchanged, 568 lines)
- `CyclePageConfig.swift` — Refactored from existing `PageVM`; CyclePageItemable implementation
- `CyclePageRootPresenter.swift` — Refactored from `TestCyclePageRootPresenter`
- `CyclePageViewController.swift` — Refactored from `TestPresenterCyclePageViewController`

---

## Capability Coverage Matrix

| # | Capability | Demo |
|---|---|---|
| 1 | `ViewPresenter<View>` + generic constraint | 01, all |
| 2 | `setState { }` + `onUpdate(view:context:)` | 01, all |
| 3 | Lifecycle: `onAttach`, `onBindView`, `onUnbindView`, `onDetach` | 01 |
| 4 | `PageViewController<F, P, V>` | 01, all |
| 5 | `@PageInstallerBuilder` result builder | 01, 02, 03 |
| 6 | `PresenterInstaller` (eager/lazy, keyed) | 01, 04 |
| 7 | `ServiceInstaller` (eager/lazy) | 02 |
| 8 | `getService()` lookup chain | 02, 10 |
| 9 | Service downgrade / fallthrough | 02 |
| 10 | `ManagedViewPresenter` as service registrar | 02 |
| 11 | `notifyGlobal(listener:)` | 03 |
| 12 | `notifyChildren(listener:)` | 03, 04 |
| 13 | `notifyParents(listener:)` | 03 |
| 14 | `notifyReusable(listener:)` | 03, 10 |
| 15 | `ServiceInstaller(listenTo:)` auto-listener | 03 |
| 16 | `typeBox()` / `typeUnbox()` child management | 04, 10 |
| 17 | `ViewGroupPresenter` key-based access | 04 |
| 18 | `CollectionPresenter` / `CollectionSectionPresenter` | 05, 06 |
| 19 | `CollectionItemPresenter<Cell>` | 05, 10 |
| 20 | Diff-based partial updates | 05, 10 |
| 21 | `calculateSizeAutomatically` | 05 |
| 22 | `UICollectionItemFlowPresentable` | 05 |
| 23 | `UICollectionViewFlowSectionPresentable` | 05, 06 |
| 24 | `UICollectionViewReusablePresenter` (supplementary) | 06 |
| 25 | `UICollectionViewFlowSectionPresentable.supplementaryLayoutInfo` | 06 |
| 26 | `ViewUpdateContext.animated` | 07 |
| 27 | `ViewUpdateContext.invalidateContentSize` | 07 |
| 28 | `ViewUpdateContext.invalidateLayout` | 07 |
| 29 | `ViewUpdateContext.forceDisableAnimation` | 07 |
| 30 | Custom `ViewUpdateAnimator` | 07 |
| 31 | `IsolatedViewPresenter<UI, P, V>` | 08 |
| 32 | Standalone presenter (no PageViewController) | 08 |
| 33 | `autoBindView = true` | 09 |
| 34 | `ViewAutoBindable.findView<T>()` | 09 |
| 35 | Shadow Presenter pattern | 09 |
| 36 | `bindWeakView(_:)` | 09 |
| 37 | `ReusableViewPresenter<View>` | 10 |
| 38 | `UICollectionViewFlowItemPresenterHolder` (Holder pattern) | 10 |
| 39 | Nested child presenters in reusable cells | 10 |
| 40 | `prepareForReuse()` lifecycle | 10 |
| 41 | `UITablePageDefaultViewController` | Main |

---

## Deleted Files

Files removed entirely:

```
Example/DDComponent/FunctionViewController.swift
Example/DDComponent/Image.swift
Example/DDComponent/Text.swift
Example/DDComponent/CollectionStaticViewController.swift
Example/DDComponent/DefaultTableViewController.swift
Example/DDComponent/Page1ViewController.swift
Example/DDComponent/Page1Model.swift
Example/DDComponent/Page1RootView.swift
Example/DDComponent/Page1RootPresenter.swift
Example/DDComponent/Page1LikeService.swift
Example/DDComponent/RouterService.swift
Example/DDComponent/View1.swift
Example/DDComponent/View1Presenter.swift
Example/DDComponent/LikePresenter.swift
Example/DDComponent/ImageViewPresenter.swift
Example/DDComponent/TextViewPresenter.swift
Example/DDComponent/TableCellModel.swift
Example/DDComponent/TableViewDefaultCell.swift
Example/DDComponent/UIView+Handy.swift
Example/DDComponent/InfiniteScrollView.swift           (unused, 85 lines)
Example/DDComponent/TestCyclePageViewController.swift
Example/DDComponent/TestPresenterCyclePageViewController.swift
Example/DDComponent/Snippets/                          (entire directory, 6 files)
```

## Moved Files

Files moved to new locations:

```
Example/DDComponent/CyclePageView.swift  →  Example/DDComponent/CyclePageExample/CyclePageView.swift
```

## Preserved & Refactored

```
Example/DDComponent/AppDelegate.swift               → unchanged
Example/DDComponent/Info.plist                      → unchanged
Example/DDComponent/Base.lproj/LaunchScreen.xib     → unchanged
Example/DDComponent/Base.lproj/Main.storyboard      → remove unused VC scene
Example/Tests/Tests.swift                           → unchanged (placeholder)
```

---

## Non-Goals

- No new DDComponent framework features — Example redesign only
- No UI tests or snapshot tests in this pass
- No localization
- No dark mode adaptation
- No iPad layout adaptation

---

## Constraints

- All demos must compile against the existing DDComponent pod
- iOS deployment target: consistent with current Example project settings
- Third-party dependencies: SnapKit and Then (already in Example Podfile)
- Xcode project changes: add new files only; remove listed deleted files; no scheme/target changes
