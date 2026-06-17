# CLAUDE.md — project orientation

Guidance for AI coding sessions (Claude Code) working in this repository.

## What this project is

A cozy, mobile-first pet/habitat game. The complete design lives in
**[`DESIGN.md`](DESIGN.md)** — that is the **source of truth**. Read its contents
list and glossary first; **§3–4 are the mechanical heart** (the habitat *tag
system* and *Charm*) and should be understood before writing any gameplay code.

One-line premise: *you keep a waystation where wandering creatures rest; what you
place in a room determines who visits, who thrives, and how pets behave —
decoration is functional, and that is the spine the whole game hangs from.*

## Current state

- **Design: complete.** Pre-production. **No game code exists yet.**
- The repo currently holds only documentation (`DESIGN.md`, `README.md`, this
  file). The Godot project has not been scaffolded.
- **Next concrete task:** the **MVP vertical slice** — one pet, one room — exactly
  as scoped in [`DESIGN.md` §16](DESIGN.md#16-mvp--the-vertical-slice). Do not
  build beyond MVP scope without being asked; §16 lists explicit non-goals.

## Locked technical decisions (see §15)

- **Engine: Godot 4** (GDScript by default; C# only if a system clearly needs it).
- **Platform: mobile-first, portrait.** Desktop/web exports are for prototyping.
- **Camera: 3/4 angled diorama**, layered 2D with depth-sorted sprites.
- **Art: hi-fi "modern" pixel art** with dynamic 2D lighting; warm, golden-hour
  mood. Use placeholder art when building systems — don't block on final assets.

When scaffolding, fix the pipeline specifics still open in §18 (base virtual
resolution, pixels-per-unit, scaling mode) and record the choice back into
`DESIGN.md`.

## Non-negotiable design principles

Every change must pass the appendix checklist in `DESIGN.md`. In short:

- **No fail states.** Needs are *invitations*; neglect yields a quieter pet, never
  punishment. Bonds **never** decay.
- **Cadence from natural rhythms** (real-time clock/seasons), never energy timers
  or punishing streaks.
- **Money buys expression, never power.** Earned currencies buy everything
  functional; real money buys cosmetics only, which must be **Charm-neutral**.
- **Everything feeds the spine.** If a feature doesn't make a pet feel more
  *alive* or the space more *yours*, question it.
- **Reading the pet is the skill** — convey state through behavior/tells, not bare
  numbers.

## Working agreements

- **`DESIGN.md` is canonical.** If you change a design decision, update the doc
  (and its glossary/§18) in the same change so the two never drift.
- Keep cross-references in the `(§N)` style already used.
- Development branch for this work: `claude/cozy-pet-game-concept-hkrmmj`
  (per session instructions). Commit with clear messages; do not open a PR unless
  asked.
