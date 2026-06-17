# Development Plan — Cozy Pet Game

Engineering execution plan that turns **[`DESIGN.md`](DESIGN.md)** (the canonical
source of truth) into buildable, sequenced work. This document is *how we build*;
`DESIGN.md` is *what we build and why*. Where the two ever disagree, `DESIGN.md`
wins — and we fix this plan in the same change.

> **Read order.** §0 sets the rules of engagement. §1 locks the remaining
> pipeline decisions. §2–3 define architecture and the data model. §4 specifies
> each core system. §5 is the MVP milestone plan (the build target — the bulk of
> this doc). §6 covers testing/CI, §7 the art pipeline, §8 risks, §9 the
> post-MVP phases, §10 conventions & Definition of Done.

Cross-references to the design use the existing `(§N)` style and point at
`DESIGN.md`. References inside this plan use `(P§N)`.

---

## Contents

0. [Engineering principles & rules of engagement](#0-engineering-principles--rules-of-engagement)
1. [Pipeline decisions to ratify at scaffold (closes DESIGN §18)](#1-pipeline-decisions-to-ratify-at-scaffold-closes-design-18)
2. [Project architecture](#2-project-architecture)
3. [Data model — the resource-driven spine](#3-data-model--the-resource-driven-spine)
4. [Core systems specification](#4-core-systems-specification)
5. [MVP milestone plan (the build target)](#5-mvp-milestone-plan-the-build-target)
6. [Testing, CI & quality gates](#6-testing-ci--quality-gates)
7. [Art & asset pipeline](#7-art--asset-pipeline)
8. [Risk register](#8-risk-register)
9. [Post-MVP phases](#9-post-mvp-phases)
10. [Conventions & Definition of Done](#10-conventions--definition-of-done)

---

## 0. Engineering principles & rules of engagement

These are the engineering counterparts to the design's non-negotiables
(DESIGN appendix). They keep the codebase serving the spine (DESIGN §3).

1. **Data-driven over hard-coded.** Pets, decor, plants, tags, and comfort
   profiles are **Godot `Resource` (`.tres`) files**, not code. Tuning the game
   (DESIGN §18 open items: tag set, comfort profiles, visitor cadence) must be a
   data edit, never a code change. This is the single most important structural
   bet — the whole design is "numbers on items and creatures," so the numbers
   live in data.
2. **Pure core, thin nodes.** All load-bearing math (tag summation, diminishing
   returns, Charm, attraction, need decay, offline accrual, photo scoring) lives
   in **plain `RefCounted` classes under `src/core/` with zero scene-tree
   dependencies**, so it is unit-testable headlessly and deterministic. Nodes
   orchestrate; they don't compute.
3. **Signals over polling; one event bus.** Systems communicate through a small
   `EventBus` autoload (e.g. `room_changed`, `need_changed`, `bond_stage_up`,
   `visitor_arrived`). UI and AI *react*; they don't reach into each other.
4. **No fail states in code paths.** There is deliberately **no death, no zeroed
   need, no decay of bond**. Any clamp that could express "punishment" is a bug
   against DESIGN §3/§8/§11. Floors are first-class (the "content but missing
   you" floor is a real constant, not an accident of math).
5. **Deterministic & seedable randomness.** All RNG goes through a single seeded
   stream so visitor rolls, AI surprise, and trait rolls are reproducible in
   tests and bug reports.
6. **Mobile budget from day one.** Target 60 fps on a mid-range phone with the
   room populated. Depth-sorting, lighting, and the AI tick are the watch items
   (P§8). Profile on-device by end of MVP, not after.
7. **Build vertically, not horizontally.** Each milestone (P§5) ends in
   something *playable and demonstrable*, not a half-finished layer. The MVP
   succeeds on *feel*, so we must be able to feel it early and often.
8. **Scope discipline.** DESIGN §16 lists explicit MVP non-goals. Anything not
   in §16 is out until the slice proves the magic. When tempted, re-read the MVP
   success criterion (DESIGN §16) and stop.

---

## 1. Pipeline decisions to ratify at scaffold (closes DESIGN §18)

DESIGN §18 leaves four pipeline specifics open "to firm up alongside the first
art and the MVP build." This plan **proposes concrete values**; they become
binding at the M0 scaffold (P§5), at which point we record them into DESIGN §15
+ tick them off §18 in the same commit (per the working agreement).

| Open item (DESIGN §18) | Proposed value | Rationale |
|---|---|---|
| **Base virtual resolution** | **720×1280** (portrait, 9:16) | Clean integer relationship to common phone panels; small enough that hi-fi pixel art stays crisp, large enough for a readable diorama + thumb UI. |
| **Pixels-per-unit (PPU)** | **1 art-pixel = 1 world unit at base zoom**, sprites authored at a **16 px tile** module for floor grid | One shared pixel grid (DESIGN §15); decor footprints expressed in 16-px tiles map cleanly to snap-to-grid (DESIGN §10). |
| **Scaling mode** | **`canvas_items` stretch, aspect `keep`**, with **integer snap on the world subviewport** | Keeps pixel art on its grid while letting UI breathe across aspect ratios; world rendered into a `SubViewport` so we can integer-scale art independently of fluid UI. |
| **Window/stretch + camera** | `Camera2D` on the world `SubViewport`; vertical scroll for the room (DESIGN §15) | Separates "the diorama" (pixel-perfect, scrollable) from "the HUD" (resolution-independent). |
| **Aseprite → Godot convention** | Aseprite files in `art_src/`, exported to `assets/sprites/` as **sprite-sheet PNG + JSON**; **animation tags = Godot `SpriteFrames` animation names**; layer naming `floor/ wall/ surface/ hanging` mirrors the placement layers (DESIGN §10) | Makes the tag-driven decor system map 1:1 from art to data (DESIGN §15 pipeline note). |
| **Godot version** | **Godot 4.x stable, GDScript**, C# only if a system clearly needs it (DESIGN §15) | Locked by design. |
| **Target frame budget** | 60 fps; AI tick decoupled to ~5–10 Hz (P§4.6) | Mobile budget (P§0.6). |

> These are *proposals in this plan only* until M0 ratifies and writes them into
> DESIGN.md. Until then DESIGN §18 stays the authority on their "open" status.

---

## 2. Project architecture

### 2.1 Repository / project layout

```
/                         (repo root — docs live here today)
  DESIGN.md               canonical design (source of truth)
  DEVELOPMENT_PLAN.md     this file
  README.md
  game/                   ← the Godot project (created at M0)
    project.godot
    addons/
      gut/                unit-test framework (GUT)
    art_src/              Aseprite source files (not exported assets)
    assets/
      sprites/            exported sheets + .json
      fonts/
      shaders/            lighting / palette shaders
      audio/
    data/                 ALL tunable content as .tres
      tags/               TagSet definition (the ~4 MVP axes)
      items/              DecorItem resources
      plants/             PlantSpecies resources
      pets/               PetSpecies + temperament resources
      config/             balance constants (decay rates, floors, payouts)
    src/
      autoload/           singletons (EventBus, GameClock, SaveManager, ...)
      core/               PURE logic, no nodes (tags, charm, attraction, ...)
      room/               Room scene, grid, placement, depth-sort
      pets/               Pet scene, needs, bond, AI, tells
      plants/             Plant scene + growth
      economy/            coins, photo scoring, shop
      ui/                 HUD, Room Report, indicators, gallery
      camera/             camera rig + scroll
    scenes/               composed scenes (main, room, boot)
    tests/                GUT tests mirroring src/core + integration
```

Rationale: keeping the engine project under `game/` leaves the docs at repo root
(where tools and the working agreement expect them) and keeps a clean boundary
for a future monorepo (tools, art, server-if-ever).

### 2.2 Runtime composition (scene tree)

```
Main (Node)
├─ World (SubViewport + Camera2D)        ← pixel-perfect, scrollable diorama
│  └─ Room
│     ├─ Floor / grid + lighting (CanvasModulate, PointLight2D for the lamp)
│     ├─ DecorLayer (floor / surface / hanging — depth-sorted via Y-sort)
│     ├─ WallLayer
│     ├─ Plants
│     └─ Pets (cat; later visitors)
└─ HUD (CanvasLayer)                      ← resolution-independent UI
   ├─ NeedIndicators (gentle, fade-with-bond later)
   ├─ RoomReport (Charm + radar)
   ├─ PlacementUI (palette, move/rotate/store)
   ├─ PhotoButton / Gallery
   └─ Coins / shop
```

### 2.3 Autoload singletons (the only globals)

| Autoload | Responsibility | Notes |
|---|---|---|
| `EventBus` | Decoupled signal hub | No state, just `signal` declarations. |
| `GameClock` | Real-time clock, day phase (dawn/day/dusk/night), offline delta | 1:1 real time (DESIGN §11); drives behavior + accrual. |
| `RoomState` | Authoritative set of placed items + current tag vector + Charm | Recomputes & emits `room_changed` on any placement edit. |
| `SaveManager` | Serialize/restore full game state; offline catch-up entry point | Local only for MVP (DESIGN §16). |
| `EconomyManager` | Coins balance, payout application, stipend | Trinkets stubbed/deferred (see P§5 notes). |
| `RNG` | Single seeded random stream | Determinism (P§0.5). |
| `Balance` | Loads `data/config/*` into typed constants | One place to tune. |

Everything else is a scene-local node, not a global.

---

## 3. Data model — the resource-driven spine

This is the technical heart (DESIGN §3–4). Get these resource shapes right and
most systems become thin readers of data.

### 3.1 Tags / TagVector

- **MVP tag set (DESIGN §16): `warmth`, `greenery`, `softness`, `hiding`.**
  Designed to grow to the full ~8 (DESIGN §4) without code change.
- Represented as a fixed-key float structure (`TagVector` helper in
  `src/core/tag_vector.gd`) with `+`, scalar mul, dot/match operations.
- A `TagSet` resource (`data/tags/`) declares the active axes + display metadata
  (icon, label, radar order). Adding the Phase-2 axes = editing this resource.

### 3.2 `DecorItem` (Resource)

```
id: StringName
display_name: String
art: SpriteFrames / Texture          # placeholder at first
layer: enum { FLOOR, WALL, SURFACE, HANGING }   # drives Composition (DESIGN §4)
footprint: Vector2i                  # grid cells occupied
tag_contribution: TagVector          # what it emits into the room (DESIGN §3)
# Charm attributes (DESIGN §4):
palette_key: StringName              # for Harmony (clash detection)
theme_key: StringName                # for Coherence
quality: int                         # "quality over quantity" weighting
cost_coins: int
behavior_affordances: Array[StringName]  # e.g. "sunbeam", "nap_spot", "perch"
```

`behavior_affordances` is the bridge between decoration and the utility AI
(DESIGN §8) — a bed offers `nap_spot`, a window offers `sunbeam`. This is *why*
decor drives behavior, expressed as data.

### 3.3 `PlantSpecies` (Resource) — extends the decor idea

```
id, display_name, art
growth_stages: Array[StageDef]       # sprite + duration (real-time, DESIGN §10)
tag_contribution_by_stage: Array[TagVector]
harvest_yield: { item/coins, base_amount }
loved_by: Array[StringName]          # pet species that boost yield (symbiosis)
```

Growth is wall-clock based (DESIGN §10/§11), checkpointed in save so offline
growth "just works" via `GameClock` delta.

### 3.4 `PetSpecies` (Resource)

```
id, display_name, art (idle + animation set)
comfort_profile: TagVector           # target vector (DESIGN §3)
charm_gate: float                    # min Charm to attract (0 for common)
need_decay: { food, water, enrichment } # per-hour, slow & forgiving (DESIGN §8)
need_floor: { ... }                  # the "content but missing you" floor
temperaments: Array[Temperament]     # rollable traits (DESIGN §7)
tells: Array[TellDef]                # state → behavioral cue mapping (DESIGN §5/§8)
behaviors: Array[BehaviorDef]        # utility-AI options (DESIGN §8)
is_visitor_only: bool                # sparrow=true for MVP
```

### 3.5 `Temperament` & `TellDef`

- `Temperament`: id (shy/bold/lazy/playful/social…), modifiers on behavior
  scoring weights and on which tells fire (DESIGN §7/§8).
- `TellDef`: `condition` (e.g. `food < threshold`) → `animation/anchor` (e.g.
  "sit by empty bowl"). Tells are how state reaches the player *without numbers*
  (DESIGN §5).

### 3.6 `PetInstance` (runtime save state, not a resource asset)

```
species_id, given_name
trait: StringName                    # rolled once
needs: { food, water, enrichment }   # live values
bond_points: float, bond_stage: enum # Wary→…→Inseparable (DESIGN §8)
thriving: float                      # derived from tag match × Charm
daily_bond_gained: float             # soft daily ceiling (DESIGN §8)
last_seen_timestamp                  # for offline settle
```

### 3.7 Balance config (`data/config/`)

All magic numbers live here: decay rates, need floors, diminishing-returns
curve, Charm sub-factor weights, attraction thresholds, visitor cadence window,
photo payout table, daily stipend. Loaded by `Balance` autoload. **No tunable
number is allowed to live in a script** (P§0.1).

---

## 4. Core systems specification

Each system below names: its pure-logic home (testable), its node/orchestration
home, the signals it emits, and the DESIGN section it serves.

### 4.1 Room tag aggregation — `core/room_aggregator.gd`

- Input: list of placed items (+ plant current stages). Output: room `TagVector`
  and the per-item-type counts used for diminishing returns.
- **Diminishing returns per item type** (DESIGN §4 mechanism #1): the *n*-th
  copy of a type contributes `base * f(n)` where `f` is a configurable decaying
  curve (e.g. `1, 0.6, 0.35, 0.2, …`). Pure function, fully unit-tested.
- Emits `EventBus.room_changed(tag_vector, charm)` via `RoomState`.

### 4.2 Charm — `core/charm.gd`

Pure function: `Array[DecorItem placements] -> CharmReport`.
- **Harmony**: penalize clashing `palette_key` combinations.
- **Coherence**: reward shared `theme_key`; penalize a scatter of one-offs.
- **Composition**: reward use of multiple `layer`s and "breathing room"
  (occupied-cell ratio in a healthy band — not sparse, not cluttered).
- **Variety**: penalize monoculture (few distinct types / footprint).
- Output: 4 sub-scores + a single `charm` value + human tips ("a bit cluttered —
  try removing a few things") for the Room Report (DESIGN §4).
- **Generosity rule (DESIGN §4):** many themes score equally; only obvious
  degeneracy is punished; free items can reach max. Encoded as test cases
  (P§6) so we don't silently regress into "grading art."

### 4.3 Attraction & thriving — `core/attraction.gd`

- `tag_match(profile, room_vector) -> 0..1` (cosine-ish / weighted distance,
  multi-axis so you can't single-axis your way in — DESIGN §4 mechanism #2).
- `attraction = tag_match × charm` (DESIGN §4). Feeds:
  - **Visitor spawn probability** per visiting-hour roll (DESIGN §9).
  - **Thriving** for the resident (gradient, never fail — DESIGN §3).
- `charm_gate` check for rare/exotic pets (DESIGN §4/§7) — N/A for the MVP
  sparrow but the code path exists.

### 4.4 Needs & care — `core/needs.gd` + `pets/needs_component.gd`

- Decay is **slow, forgiving, and floored** (DESIGN §8/§11): `value` drifts
  toward `need_floor`, never to 0; offline settles to floor, never below.
- Care actions (feed/water/play — DESIGN §16) raise the need and emit a bonding
  beat. Actions are interactions, not chores; depth = pet-specific response
  (favorite food etc., minimal in MVP).
- Emits `need_changed`; consumed by indicators (gentle, fade-with-bond is
  Phase 2 — DESIGN §16 non-goal) and by the AI scorer.

### 4.5 Bond — `core/bond.gd`

- Stages **Wary → Curious → Friendly → Bonded → Inseparable** (DESIGN §8).
- Grows from interaction *quality* with a **soft daily ceiling** (DESIGN §8);
  **never decays** (DESIGN §11 — enforced by a test that bond is monotonic).
- Stage-ups unlock trust behaviors (a couple in MVP — DESIGN §16) and emit
  `bond_stage_up` (used later for Memory Book — deferred, DESIGN §16).

### 4.6 Utility AI & behavior — `pets/pet_ai.gd`

- **Utility scoring** (DESIGN §8): each candidate `BehaviorDef` scores by
  `need + mood + trait_weight + nearby_affordance`; highest wins, with a small
  RNG jitter for surprise (via `RNG`, seedable).
- **Decor-driven behaviors** read `behavior_affordances` from nearby placed
  items (P§3.2): nap in a `sunbeam`, use a `nap_spot`, use a placed item — the
  visible payoff that makes Charm/variety matter (DESIGN §8).
- **Tick decoupling:** behaviors re-evaluated at ~5–10 Hz, not per frame
  (P§0.6); movement/anim interpolate between decisions.
- **Tells** (DESIGN §5) are selected by `TellDef` conditions and play as
  idle/anchored animations — state without numbers.
- Pathing for MVP: simple steering / `NavigationAgent2D` on the floor plane is
  optional; a lightweight point-to-point mover is enough for one room.

### 4.7 Time — `GameClock` autoload

- 1:1 real clock; exposes `time_of_day`, `day_phase`, and `consume_offline_delta()`
  used at load to advance plant growth, accrue stipend/tips, settle needs to
  floor, and accumulate visitor signs (signs deferred past MVP; growth + accrual
  + settle are in) (DESIGN §11). No pay-to-skip timers exist, so clock changes
  hurt nothing (DESIGN §11) — we don't fight time travel.

### 4.8 Economy — `economy/` + `EconomyManager`

- **Coins** only for MVP (DESIGN §16): photo payouts (the meta), daily stipend,
  visitor tips. **Trinkets are deferred** (DESIGN §16 keeps the MVP lean; the
  currency exists in the design §10 but the slice doesn't need it). We leave a
  clean seam (`CurrencyType` enum) so Trinkets drop in for Phase 2 without
  rework.
- A **minimal shop**: spend Coins on the ~10 decor items + plant (DESIGN §16).
  Placing/moving/rotating/storing is **always free** (DESIGN §10) — enforced:
  no code path charges for rearrange.

### 4.9 Photography — `economy/photo.gd`

- Capture the world `SubViewport` region to an image; save to a simple gallery
  (DESIGN §16).
- **Scoring** (DESIGN §10): subject presence/rarity + captured *behavior/moment*
  + composition/backdrop Charm → Coin payout. MVP scoring is intentionally
  simple (is a subject in frame? is it mid-behavior? local Charm) but uses the
  real Charm value so "beautiful rooms pay better" is true from day one.

### 4.10 Save/load — `SaveManager`

- Serialize: placed items (id + transform + layer), plant stages + timestamps,
  `PetInstance`, Coins, gallery index, clock checkpoint, RNG seed/state.
- Format: a versioned dictionary → JSON (human-diffable for debugging) under
  `user://`. **`save_version` field from day one** so migrations are possible.
- Load runs `consume_offline_delta()` (P§4.7) before handing control to the
  player so they return to *discoveries*, not chores (DESIGN §11).

---

## 5. MVP milestone plan (the build target)

Scope is exactly **DESIGN §16 (one pet, one room)** — nothing beyond, per the
§16 non-goals and P§0.8. Milestones are vertical and demoable. Each lists
**deliverable**, **key tasks**, **acceptance criteria (AC)**, and **deps**.

Rough solo-dev sizing in the right margin (S ≈ a few days, M ≈ ~1 week, L ≈ ~2
weeks). Treat as relative, not contractual.

### Critical path (dependency order)

```
M0 ─ M1 ─ M2 ─┬─ M3 ─ M4 ─ M5 ─ M6 ─ M7
              └─ M8                 │
M2,M6,M7 ───────────────── M9 ─ M10 ─ M11 ─ M12 ─ M13
```

---

### M0 — Scaffold, pipeline lock & harness  *(M)*

**Deliverable:** an empty-but-running Godot project that boots to a black room
on device/web, with tests and CI green.

**Tasks**
- Create `game/` Godot 4 project; set portrait, virtual resolution, stretch &
  PPU per P§1; create the `World SubViewport` + HUD `CanvasLayer` split (P§2.2).
- Add autoload skeletons: `EventBus`, `GameClock`, `RoomState`, `SaveManager`,
  `EconomyManager`, `RNG`, `Balance` (P§2.3) — empty but wired.
- Install **GUT**; one trivial passing test; headless test run command.
- **Ratify P§1 values into DESIGN §15 and tick DESIGN §18** in this same change
  (working agreement: doc + decision never drift).
- CI: GitHub Actions running GUT headless on push (P§6.4).
- Placeholder art conventions + one placeholder sprite to prove the Aseprite
  export path (P§7).

**AC:** project launches portrait at the chosen resolution on desktop + web
export; `gut` runs headless and passes in CI; DESIGN §15/§18 updated.

---

### M1 — Room, grid & placement  *(L)*

**Deliverable:** decorate an empty room — place, move, rotate, store items on a
snap grid with depth-correct rendering. (DESIGN §10 placement UX.)

**Tasks**
- Snap-to-grid floor with the 4 placement layers (floor/wall/surface/hanging),
  Y-sort depth so the cat will pass in front of/behind decor (DESIGN §15).
- Placement UI: pick from a palette, drag to place, rotate/flip, pick up, and
  **free unlimited store/retrieve** (DESIGN §10 — never tax rearranging, P§4.8).
- `RoomState` tracks placements (no tags yet); emits `room_changed`.
- Touch + mouse input parity (mobile-first, P§0.6).

**AC:** can place ≥10 distinct placeholder items across all 4 layers, move/
rotate/store any of them freely with zero currency cost, depth-sorting reads
correctly; placements survive a manual `RoomState` dump/restore.

**Deps:** M0.

---

### M2 — Tag system & Charm (the spine math)  *(L)*

**Deliverable:** the room *means something* — a live tag vector + a Charm "Room
Report" that updates as you decorate. (DESIGN §3–4; the mechanical heart.)

**Tasks**
- Author the `TagSet` (4 MVP axes) + ~10 `DecorItem` `.tres` + 1 `PlantSpecies`
  `.tres` with tag contributions and Charm attributes (P§3.1–3.3).
- Implement `core/tag_vector`, `core/room_aggregator` with **diminishing
  returns** (DESIGN §4 #1), `core/charm` with all 4 sub-factors + tips
  (P§4.1–4.2).
- Room Report UI: radar chart of the 4 tags + single Charm score + friendly tips
  (DESIGN §4).
- Wire `RoomState` to recompute tags+Charm on every placement edit.

**AC:** placing/removing items visibly moves the radar and Charm; a fern-pile
(monoculture) scores high greenery but **low Charm** (DESIGN §4 worked example);
a varied, coherent, well-spaced room scores high Charm; **a room of only
free/earnable items can reach max Charm** (DESIGN §4 — guarded by a test).
Core math fully unit-tested (P§6).

**Deps:** M1.

---

### M3 — The cat: presence & roaming  *(M)*

**Deliverable:** a cat exists in the room, idles expressively, and wanders.

**Tasks**
- `PetSpecies` cat `.tres` (placeholder art, idle + walk anim); `PetInstance`
  spawn; one rolled temperament (DESIGN §7).
- Lightweight floor mover + idle animation cycling; respects room bounds and
  avoids decor footprints (simple steering, P§4.6).

**AC:** cat spawns, idles with personality, wanders believably around placed
decor at 60 fps.

**Deps:** M1 (needs a room to walk in); can start in parallel with M2.

---

### M4 — Needs as invitations  *(M)*

**Deliverable:** three lean needs that decay slowly/forgivingly and 3 care
actions, with gentle indicators. (DESIGN §8/§16.)

**Tasks**
- `core/needs` decay-toward-floor (DESIGN §8/§11); `needs_component` on the cat.
- Care actions feed/water/play (DESIGN §16); each plays a response + small
  bonding beat.
- Gentle indicator UI (simple for MVP; **fade-with-bond is a Phase-2 non-goal**,
  DESIGN §16).

**AC:** needs decay slowly and **never reach zero** (settle to floor); offline
for a simulated week settles to floor, not below (test); care actions raise the
right need and feel like a moment, not a chore.

**Deps:** M3.

---

### M5 — Reading the pet (tells)  *(M)*

**Deliverable:** the cat's state is legible through **behavior, not numbers**
(DESIGN §5/§8 — the signature skill).

**Tasks**
- `TellDef` set for the cat (4–5 tells, DESIGN §16): sits by empty bowl
  (hungry), curls on cushion (content), etc.
- Tell selection driven by need/mood + trait modulation (DESIGN §8).
- Tune indicators so behavior leads and numbers merely confirm.

**AC:** a player can correctly infer "the cat is hungry / content / wants play"
from behavior alone (informal playtest), without reading the indicators; ≥4
distinct tells fire under the right conditions.

**Deps:** M4.

---

### M6 — Utility AI & decor-driven behaviors  *(L)*

**Deliverable:** the room feels **alive** — the cat uses what you place. (DESIGN
§8 — the payoff loop and the reason Charm/variety matter.)

**Tasks**
- `pet_ai` utility scorer (need+mood+trait+affordance, seeded jitter — P§4.6).
- `behavior_affordances` consumption: nap in a `sunbeam`, use a `nap_spot`
  (bed), interact with ≥1 other placed item (DESIGN §16).
- Time-of-day flavor via `GameClock` (midday naps, dusk friskiness — DESIGN §8),
  minimal.

**AC:** placing a bed/sunbeam visibly changes what the cat does (it goes and
uses it); removing it changes behavior back; richer rooms produce more distinct
behaviors than a bare room — *demonstrating the MVP thesis* (DESIGN §16).

**Deps:** M2 (affordances + room), M5.

---

### M7 — Bond  *(M)*

**Deliverable:** care visibly deepens the relationship. (DESIGN §8.)

**Tasks**
- `core/bond` stages + soft daily ceiling + **monotonic (never decays)** guard
  (P§4.5).
- Unlock a couple of trust behaviors on stage-up (DESIGN §16) (e.g. greets you,
  sleeps nearby).
- `bond_stage_up` signal (Memory Book consumer deferred — DESIGN §16).

**AC:** sustained care advances stages at a believable pace with a daily cap;
bond **never decreases** under any sequence (test); stage-up unlocks a visible
new trust behavior.

**Deps:** M4.

---

### M8 — Plant growth & harvest  *(S–M)*

**Deliverable:** one plant grows on the real clock and yields a sellable
harvest. (DESIGN §10/§16.)

**Tasks**
- `PlantSpecies` growth stages on wall-clock; stage advance via `GameClock`
  delta incl. **offline growth** (P§4.7).
- Tag contribution changes by stage (feeds M2's room vector).
- Harvest → Coins/sellable (economy seam, completed in M10).

**AC:** plant advances stages over real time and across an offline gap; a grown
plant changes the room's tags; harvest produces a sellable yield.

**Deps:** M2 (tags), GameClock from M0.

---

### M9 — Visitor ecosystem (the loop closes)  *(M)*

**Deliverable:** tune the room past a threshold → a sparrow visits and leaves a
tip. End-to-end proof of the spine. (DESIGN §9/§16.)

**Tasks**
- Sparrow `PetSpecies` (`is_visitor_only`) with a comfort profile (DESIGN §16).
- `core/attraction` threshold roll on the visiting-hour cadence (DESIGN §9);
  spawn/despawn a visitor that roams + can be watched.
- Visitor leaves a **Coin tip** on a good visit (DESIGN §10).

**AC:** with a room *below* the sparrow's tag threshold, no sparrow; tune the
room *above* it and a sparrow visits within the cadence window and leaves a tip
— making "changing the room changes who shows up" literally true (DESIGN §16
success criterion).

**Deps:** M2 (attraction needs tags+Charm), M6 (roaming behaviors reused).

---

### M10 — Photography & economy  *(M)*

**Deliverable:** snap photos that pay Coins; spend Coins in a minimal shop.
(DESIGN §10/§16.)

**Tasks**
- Photo capture of the world subviewport → gallery (DESIGN §16).
- `economy/photo` scoring (subject + behavior + local Charm → payout, P§4.9).
- `EconomyManager`: Coins from photos + **daily stipend** + visitor tips
  (DESIGN §16); minimal shop to buy the decor/plant with Coins (placing stays
  free, P§4.8).

**AC:** photographing the cat mid-behavior in a charming spot pays more than a
bare snap; daily stipend arrives once per real day; tips + photos accumulate
Coins; Coins buy items in the shop; rearranging never costs anything.

**Deps:** M6/M9 (subjects + behaviors to shoot), M2 (Charm in scoring).

---

### M11 — Save/load & offline accrual  *(M)*

**Deliverable:** the world persists and rewards return with discovery, not
chores. (DESIGN §11/§16 local save.)

**Tasks**
- `SaveManager` full round-trip (placements, plant timestamps, `PetInstance`,
  Coins, gallery, clock, RNG) with `save_version` (P§4.10).
- On load, `consume_offline_delta()`: grow plants, accrue stipend/tips, settle
  needs to floor, **bond unchanged** (DESIGN §11).
- Autosave on meaningful change + on background/quit.

**AC:** quit and relaunch restores the exact room and pet; an offline gap grows
plants and accrues Coins, settles needs to floor, and leaves bond untouched;
save round-trip is loss-less (test).

**Deps:** everything stateful (M4–M10).

---

### M12 — Onboarding slice, lighting & juice  *(L)*

**Deliverable:** the first-session emotional arc and the warming-haven feel.
(DESIGN §13 first-5-minutes; DESIGN §15 dynamic lighting.)

**Tasks**
- Scripted but skippable opening: dim haven → the guaranteed first knock → let
  the cat in → first care (taught by doing) → name it → place a bed it *uses* →
  **the haven warms (a lamp lights, color returns)** → first photo (DESIGN §13).
  *(Memory Book is a §16 non-goal — the first-entry beat is represented lightly
  without the full feature.)*
- 2D lighting: `CanvasModulate` day tint + a `PointLight2D` lamp that turns on
  at the warming beat (DESIGN §15).
- Audio pass (ambient + soft SFX) and animation/particle "juice" on care +
  placement + photo.

**AC:** a first-time player goes arrival → first knock → care → name → place →
warm → photo with no modal walls and all text skippable (DESIGN §13); the haven
visibly warms; the session feels complete even if nothing else is touched.

**Deps:** M3–M10.

---

### M13 — Vertical-slice hardening & tuning  *(M)*

**Deliverable:** a shippable, playtested slice that proves the magic.

**Tasks**
- On-device performance pass (60 fps target, AI tick, lighting, depth sort —
  P§0.6); fix the worst offenders.
- **Balance tuning against real play** (DESIGN §18 open items): tag values,
  comfort profile, visitor cadence, decay/floors, payout table, Charm weights —
  all via `data/config` + resources (no code churn, P§0.1).
- Playtest the success criterion; iterate copy/feedback so players *intuit* that
  the room shapes who shows up and how the cat behaves (DESIGN §16).
- Bug-bash; verify the appendix principles checklist (DESIGN appendix) passes.

**AC (and the MVP exit criterion):** a fresh player, unprompted, discovers that
*changing the room changes who visits and how the cat behaves* — and wants to
keep tweaking (DESIGN §16). 60 fps on a mid-range device. Principles checklist
all ✓.

**Deps:** all.

---

### MVP definition of done

All M0–M13 AC met; DESIGN §15/§18 updated for ratified pipeline values; CI
green; a tagged build exported to web (for the shareable-link feedback loop,
DESIGN §15) and at least one mobile target.

---

## 6. Testing, CI & quality gates

1. **Unit tests (the priority): all of `src/core/`** via GUT, headless,
   deterministic. Mandatory coverage for: tag aggregation + diminishing returns,
   Charm sub-factors + the "free items reach max Charm" and "monoculture is
   punished, varied is rewarded" guarantees, attraction/tag-match, need
   decay-to-floor (never zero), bond monotonicity (never decays) + daily cap,
   offline accrual, photo scoring ordering, save round-trip + version field.
   These encode the design's *promises* as executable checks.
2. **Integration/scene tests:** placement edits emit `room_changed`; visitor
   threshold spawns/despawns; load restores state. GUT scene tests, kept lean.
3. **Manual playtest checklist** per milestone AC + the DESIGN appendix
   principles checklist as a release gate (no fail states, no punishing timers,
   money≠power, everything feeds the spine).
4. **CI (GitHub Actions):** headless Godot runs GUT on every push to the dev
   branch; web export artifact on green. Block merge on red.
5. **Determinism check:** a seeded run of N visitor rolls + AI ticks reproduces
   identically — protects against accidental nondeterminism (P§0.5).

---

## 7. Art & asset pipeline

- **Placeholder-first (P§0.7 / DESIGN §15):** build every system on flat-color /
  blocky placeholders; never block code on final art.
- **Aseprite → Godot** per P§1: sources in `art_src/`, export sheet+JSON to
  `assets/sprites/`; **animation tags become `SpriteFrames` animation names**;
  layer naming mirrors placement layers (DESIGN §15 pipeline note) so a decor
  item's art maps 1:1 to its `DecorItem.layer`.
- **One pixel grid** at the chosen PPU (P§1); integer-scale the world subviewport
  so pixels stay clean while UI scales fluidly.
- **Animation gets the budget (DESIGN §15):** expressive cat idles + reaction
  tells + decor-use behaviors carry the emotional payload and the photo loop;
  these are the assets that matter most for the slice.
- **Lighting is a feature, not polish (DESIGN §15):** author art to read under a
  warm day tint + the lamp light; the warming-haven beat (M12) depends on it.

---

## 8. Risk register

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| **AI/behavior doesn't *feel* alive** (the whole slice rides on M6 feel) | High | Med | Prototype the utility AI + decor affordances early (M3→M6 on the critical path); informal playtests each milestone; budget animation (P§7). |
| **Charm tuning feels like "grading art"** (DESIGN §4 warns against this) | High | Med | Encode generosity guarantees as tests (P§6); many themes score equal; gentle tips not penalties; tune in M13 against real rooms. |
| **Scope creep past §16** | High | High | P§0.8 discipline; §16 non-goals are a checklist; Trinkets/Memory Book/seasons explicitly stubbed with clean seams, not built. |
| **Mobile performance** (depth sort + lighting + AI) | Med | Med | AI tick decoupled (P§4.6); profile on-device in M13 not after; integer-scaled subviewport. |
| **Save migrations break players later** | Med | Low | `save_version` from day one (P§4.10); JSON is diffable; round-trip test. |
| **Solo-dev art bottleneck** | Med | Med | Placeholder-first; final art only for the slice's hero animations; defer everything cosmetic. |
| **Determinism bugs in visitor/AI RNG** | Low | Med | Single seeded stream + determinism test (P§6.5). |
| **Pipeline values wrong** (resolution/PPU) | Med | Low | Ratify early at M0 on real devices; cheap to change before content piles up. |

---

## 9. Post-MVP phases

Lower-detail; mirrors DESIGN §17. We only plan these in depth once the MVP slice
validates the feel (DESIGN §16). The MVP's clean seams (CurrencyType for
Trinkets, `bond_stage_up` for Memory Book, the growable `TagSet`, `charm_gate`,
`is_visitor_only`) are what make these cheap to add.

- **Phase 2 — Depth (DESIGN §17):** full ~8 tag set (edit `TagSet`); 3–4 species
  + comfort profiles; weather/time-of-day behavior; the **signs/courtship**
  resident loop (DESIGN §9); **Trinkets** currency turned on; fading-with-bond
  needs UI (DESIGN §8); the **Memory Book** (DESIGN §8); achievements; first
  **Charm-neutral cosmetic IAP** (DESIGN §10 monetization line) + the hard rules
  enforced in store code.
- **Phase 3 — Living world (DESIGN §17):** seasons + migration waves (DESIGN
  §11); the **multi-room / blank-biome** model (DESIGN §14) — the placement
  puzzle of who rooms where; inter-pet relationships & emergent multi-pet
  vignettes (DESIGN §8); Field Guide as detective loop (DESIGN §9); seasonal
  events; the restoration-arc climax (grand reopening festival, DESIGN §14).
- **Phase 4 — Reach & polish (DESIGN §17):** cloud save, sharing of photos/
  Memory Book, content cadence, the **fantastical-creature tier** (DESIGN §2/§14),
  crafting (DESIGN §10), soft launch & live-ops.

Each phase must still pass the DESIGN appendix checklist; anything that doesn't
feed the spine gets cut (P§0.8).

---

## 10. Conventions & Definition of Done

**Code conventions**
- GDScript with **static typing everywhere**; `class_name` for reusable types;
  `snake_case` methods/vars, `PascalCase` types, `SCREAMING_SNAKE` consts.
- Cross-system comms via `EventBus` signals only (P§0.3); no node reaching across
  the tree for state.
- No tunable number in a script — it lives in `data/` (P§0.1).
- Pure logic in `src/core/` stays node-free and tested (P§0.2).

**Commit / branch**
- Develop on the session's designated branch; clear, scoped commit messages
  (one milestone-slice per commit where practical); **no PR unless asked**.
- If a commit changes a design decision (e.g. ratifying P§1), it **updates
  DESIGN.md in the same commit** (working agreement — docs never drift).

**Definition of Done (per task/milestone)**
1. Meets its AC (P§5).
2. Pure logic covered by GUT tests; CI green (P§6).
3. No new tunable constants hard-coded in scripts.
4. Passes the DESIGN appendix principles checklist (no fail state, natural
   cadence, money≠power, feeds the spine, makes the pet feel alive / the space
   yours).
5. Runs at the frame budget on the target (verified on device by M13).
6. Docs updated if a design decision changed.

---

> **This plan in one line:** lock the pipeline (P§1) → build a resource-driven,
> pure-core, signal-wired skeleton (P§2–4) → grow it vertically through M0–M13
> (P§5) until a first-time player *feels* that the room they build decides who
> visits and how the cat lives (DESIGN §16) — then, and only then, open up the
> post-MVP phases (P§9).
