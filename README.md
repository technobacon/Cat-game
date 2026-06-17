# Cozy Pet Game

> Working title TBD. A cozy, mobile-first game about raising pets and
> cultivating a living habitat, in a warm modern pixel-art style.

You keep a **waystation on the migration paths** — a little haven at a crossroads
where wandering creatures stop to rest. Comfort one enough and it may decide to
stay. What you **place** in a room (decor, plants) determines **who visits, who
thrives, and how pets behave**: decoration is functional, and that single idea is
the spine the whole game hangs from.

- **No fail states.** Needs are invitations, not obligations; neglect just means
  a quieter pet, never punishment.
- **Reading your pet is the skill** — empathy over tap-speed.
- **Money buys flair, never advantage** — cosmetic-only monetization.

## Status

Concept **design is complete**. A **playable prototype of the MVP vertical slice**
(one pet, one room) now exists in [`prototype/`](prototype/) — a zero-install
browser build that proves the spine end to end. See
[`prototype/README.md`](prototype/README.md) for what's implemented and how to run
it. The canonical production build is still **Godot 4** (§15); the prototype is a
throwaway design-validation probe.

▶ **Try it:** open [`prototype/index.html`](prototype/index.html) in any browser
(desktop or mobile). The MVP scope it implements is [`DESIGN.md` §16](DESIGN.md#16-mvp--the-vertical-slice).

**Locked decisions:** Engine **Godot 4**; mobile-first **portrait**; **3/4 angled
diorama** camera; **hi-fi modern pixel art** with dynamic lighting.

## Documentation

- **[`DESIGN.md`](DESIGN.md)** — the full design document. Start with the
  contents and glossary at the top; §3–4 are the mechanical heart.
- **[`CLAUDE.md`](CLAUDE.md)** — orientation for AI coding sessions (state,
  locked decisions, non-negotiable principles, what to build next).

## Repository

| Path | What it is |
|---|---|
| `DESIGN.md` | Complete game design document (source of truth). |
| `CLAUDE.md` | Project orientation for Claude Code / AI sessions. |
| `prototype/` | Playable browser MVP prototype (HTML5/Canvas) + its README. |
| `README.md` | This file. |

The Godot 4 production project has not been scaffolded yet — the `prototype/`
build is a separate, instant-to-run validation probe (see its README), not the
production codebase.
