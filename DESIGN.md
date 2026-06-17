# Cozy Pet Game — Design Document

> Working title: TBD. A cozy mobile game about raising pets and cultivating a
> living habitat in a cute, modern pixel-art style.

**Status:** Early concept / pre-production
**Platform:** Mobile (iOS + Android)
**Scope intent:** Solo dev — ship a small, polished MVP first, then expand.
**Business model:** Generous free-to-play; **cosmetic-only** monetization.

---

## 1. The core fantasy

> "This creature is alive, it has a personality, and the little world I built
> for it is *mine*."

Stat bars (hunger, thirst, mood) are scaffolding — not the game. The game is
**care, companionship, and creative expression**. The win condition is a
habitat that feels alive and is unmistakably the player's own.

**The trap we are avoiding:** a soup of disconnected systems (pets + plants +
decor + achievements + income) that each feel like a separate grind. One spine
ties them together instead.

---

## 2. The spine: a living ecosystem where decoration is *functional*

What the player places determines **who visits, who thrives, and how pets
behave.** Decoration, plants, collection, and pet behavior all feed each other:

```
curate the space  ->  attract & sustain pets  ->  pets enrich the space  ->  unlock more
        ^                                                                         |
        +-------------------------------------------------------------------------+
```

### The habitat tag system (technical heart)

Every **decor item** and **plant** carries environmental tags with values:

`warmth · humidity · light · greenery · verticality · hiding · water · softness`

- A **room** = the sum (vector) of all placed items' tags.
- Every **pet** (resident or visitor) has a **comfort profile** (a target tag
  vector) and a **thriving meter** that rises as the room matches its profile.

This single mechanic delivers the whole spine:

| System | How the tag mechanic powers it |
|---|---|
| Functional decoration | Items change the room's tag vector, not just looks |
| Collection / discovery | Visitors appear when the room crosses a species' tag threshold |
| Thriving (not survival) | Match a pet's profile → it flourishes, never punished |
| Plant/pet symbiosis | Pets boost plants they love; plants emit tags that draw pets |

**Design rule:** Thriving is a *flourishing gradient*, never a fail state.
Pets never die or suffer. The tension is "my frog isn't thriving *yet* — what
does it need?" — a puzzle, not a punishment.

---

## 3. The two states

### A. Inspection (intimacy & care)
Pet fills the frame. Read its mood, needs, and personality **tells**.
- **Reading the pet is the skill.** Subtle behavioral tells (ear flicks, idle
  choices, where it sits) teach the player to understand *this specific* pet.
  Rewards attentiveness and empathy, not tap speed.
- Care actions: feed, water, play, groom, pet — each tied to readable cues.

### B. Room (expression & emergence)
A 2D room the player decorates and where pets roam autonomously.
- **Emergent vignettes:** personality-driven behavior so pets interact with
  each other and the decor, creating little screenshot-worthy stories. This is
  the game's primary virality engine — cozy games spread through shared images.

---

## 4. Signature creative pillars

1. **Read your pet** — empathy as the core skill (see Inspection).
2. **Emergent stories** — autonomous, personality-driven behavior worth sharing.
3. **Photography as a verb** — a gentle Snap system feeds collections &
   achievements ("catch the moment your shy hedgehog uses the new burrow").
4. **Living world** — real-world time/weather/seasons change behavior and which
   visitors appear. This *is* the daily-return loop — diegetic, not a timer.
5. **Personality over skins** — pets have temperament traits affecting
   preferences and compatibility, so the collection has real depth.

---

## 5. Pets

- **Starter:** player picks **cat or dog**.
- **Progression:** unlock increasingly exotic species (e.g. hedgehog → tree
  frog → fennec fox → axolotl → exotic birds). Each new species demands a
  *habitat built for it* (a specific tag profile) — unlocking is easy; making
  it **thrive** is the real game.
- **Traits:** each pet rolls a temperament (e.g. shy, bold, lazy, playful,
  social) affecting tells, decor preferences, and compatibility with other pets.

---

## 6. Plants & economy

- Plants grow on **real-world time** (cozy cadence, no energy bars).
- Harvest → **soft currency** (plus caring for pets and taking photos also pays
  out a little).
- **Symbiosis:** a pet that loves a plant boosts its yield; plants emit tags
  that attract pets. Visible cause-and-effect, not a hidden buff number.

### Monetization line (hard rule)
- **Soft currency (earned)** buys *everything functional*: decor, plants,
  habitat expansions, new species. A non-paying player can collect every pet.
- **Real money** buys *only cosmetics*: recolors, patterns, pet accessories
  (hats/collars), photo frames & filters, decorative-only items, room themes.
- **Never** sell a species, a need-fix, or a thriving boost. Money buys flair,
  never advantage. The moment money buys an edge in a relationship, the fantasy
  dies.

---

## 7. Meta systems

- **Collection / "Field Guide":** discovered species, traits seen, photos taken.
- **Achievements:** behavior-driven and discovery-driven (e.g. "host 3 visitors
  at once", "photograph a pet sleeping in 5 different spots").
- **Daily ritual:** plant growth, visitor appearances, weather-gated events.

---

## 8. MVP — the vertical slice

Goal: prove the magic with the smallest possible build. **One pet, one room.**

**In scope:**
- 1 starter pet (cat) with a temperament trait and 4–5 readable tells.
- Inspection state: read tells + 3 care actions (feed, water, play).
- Room state: place ~10 decor items + 1 plant type, free movement of pet.
- Habitat tag system with ~4 tags (`warmth, greenery, softness, hiding`).
- 1 plant that grows on a real-time timer and harvests to soft currency.
- 1 **visiting** pet (e.g. sparrow) attracted when the room crosses a tag
  threshold — proves the ecosystem loop end to end.
- Photo button → saves to a simple gallery.
- Local save.

**Explicitly out of scope for MVP:** monetization/IAP, multiple species, weather/
seasons, achievements, breeding, cloud save, social features.

**The MVP succeeds if:** a player intuitively learns that *changing the room
changes who shows up and how the cat behaves* — and wants to keep tweaking it.

---

## 9. Phased roadmap

- **Phase 1 — Vertical slice (MVP above):** validate the core loop & feel.
- **Phase 2 — Depth:** 3–4 species, full tag set, weather/time, photo gallery,
  achievements, first cosmetic IAP.
- **Phase 3 — Living world:** seasons, more exotic pets, emergent multi-pet
  vignettes, collection/field guide, events.
- **Phase 4 — Reach & polish:** cloud save, sharing, content cadence, soft launch.

---

## 10. Open decisions

- **Engine:** recommendation is **Godot 4** for a solo 2D pixel-art mobile game
  (free, lightweight, great 2D & mobile export). Alternatives: Unity, or
  Flutter + Flame. *Decision pending.*
- Working title / art direction reference board.
- Exact starting tag set and pet comfort profiles (needs prototyping/tuning).
- Visitor cadence tuning (how often, how rare).

---

## Appendix: design principles checklist

- [ ] No fail states; tension comes from *flourishing*, never punishment.
- [ ] Cadence comes from natural rhythms, never punishing energy timers.
- [ ] Money buys expression, never power.
- [ ] Every system feeds the spine (the living habitat) — cut anything that doesn't.
- [ ] If a feature doesn't make a pet feel more *alive* or the space more
      *yours*, question it.
