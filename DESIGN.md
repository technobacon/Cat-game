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

## 3. Habitat stats & Charm

The stat system's real job is not to *measure* the room — it is to make
**variety and beauty mechanically necessary**, so rooms stay unique and pretty
instead of collapsing into a min-maxed monoculture (a "room full of ferns").

### Three layers (kept readable on purpose)

**Layer 1 — Environmental tags (the attraction substrate): ~8.**
`warmth · humidity · light · greenery · verticality · hiding · water · softness`
Properties the room *emits*; few enough to show on one radar chart. (MVP: 4.)

**Layer 2 — Charm (the anti-degeneracy + beauty layer): 1 visible score** built
from ~4 sub-factors shown in a friendly "Room Report":
- **Harmony** — color palettes don't clash
- **Coherence** — items share a theme/style
- **Composition** — breathing room (not sparse, not cluttered); uses layers
  (floor / wall / surfaces / hanging)
- **Variety** — directly penalizes monoculture

**Layer 3 — Per-pet stats (kept LEAN — cozy, not Tamagotchi chore):**
3 needs (`Food, Water, Enrichment`) + derived `Mood`, `Bond`, `Thriving`, plus
discrete **traits** (temperament + a style preference). Resist adding needs —
every need is a chore tax.

### How attraction is computed

```
Attraction (and sign-accrual / thriving) = tag match × Charm
```

- **Charm is a punishing multiplier for *everyone*.** You *can* still build an
  ugly room and attract common pets — it just works far worse. A fern-pile has
  high greenery but trash Charm (no variety, cluttered, no composition).
- **Charm is also a hard gate for rare/exotic pets.** Lore-justified: "the
  axolotl only appears in serene, well-kept spaces." Aesthetic mastery is the
  endgame; the fanciest collection entries require a genuinely beautiful home.

### The five mechanisms that kill min-maxing (stack all)

1. **Diminishing returns per item type** — the 5th fern gives almost nothing, so
   spam can't reach high values; variety is forced.
2. **Multi-axis comfort profiles** — a frog needs greenery *and* humidity *and*
   hiding *and* water; you can't fern your way to four axes.
3. **Charm as a multiplier (+ gate)** — beauty becomes mechanically mandatory.
4. **Quality over quantity items** — one "ancient fern in a ceramic pot" beats
   five generic ferns on tags *and* Charm, and costs less clutter.
5. **Behavioral payoff** — rich, varied rooms give pets things to *do* (more
   vignettes, better photos); ugly rooms are dull to watch.

### Pets have aesthetic taste (the uniqueness engine)

Each pet rewards a *style*, not just an environment: a zen axolotl loves
minimalist/serene, a magpie loves eclectic/shiny, a fennec loves warm desert
tones. There is **no single optimal beautiful room** — the player builds
*different* beautiful rooms for different pets, so habitats diverge instead of
converging. (One room can't satisfy a desert fox *and* a rainforest frog → the
long-term answer is **multiple rooms/biomes**; cohabitation becomes a puzzle.
MVP stays one room.)

### Keep Charm legible & generous
Reward *intentionality* (coherence, harmony, breathing room); only punish
obvious degeneracy (monoculture, clutter, clashing). Never impose one "correct"
style — many themes score equally. The Room Report gives gentle tips ("a bit
cluttered — try removing a few things"). Charm should feel like the game
*noticing* effort, not grading art. **Free/earnable items must be able to reach
max Charm** — paid cosmetics offer different looks, never *better* Charm.

---

## 4. The two states

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

## 5. Signature creative pillars

1. **Read your pet** — empathy as the core skill (see Inspection).
2. **Emergent stories** — autonomous, personality-driven behavior worth sharing.
3. **Photography as a verb** — a gentle Snap system feeds collections &
   achievements ("catch the moment your shy hedgehog uses the new burrow").
4. **Living world** — real-world time/weather/seasons change behavior and which
   visitors appear. This *is* the daily-return loop — diegetic, not a timer.
5. **Personality over skins** — pets have temperament traits affecting
   preferences and compatibility, so the collection has real depth.

---

## 6. Pets

- **Starter:** player picks **cat or dog**.
- **Progression:** unlock increasingly exotic species (e.g. hedgehog → tree
  frog → fennec fox → axolotl → exotic birds). Each new species demands a
  *habitat built for it* (a specific tag profile) — unlocking is easy; making
  it **thrive** is the real game.
- **Traits:** each pet rolls a temperament (e.g. shy, bold, lazy, playful,
  social) affecting tells, decor preferences, and compatibility with other pets.

---

## 7. Pet acquisition & bonding

**Thesis:** *You don't collect pets. You earn their trust by building a home
they can't resist.* Acquisition is not a separate system — it is the **readout
of the habitat spine**. You never "roll for a pet"; you make a home, and who
shows up reflects how well you made it.

### Two tiers

- **Visitors (frequent, free, low-stakes):** wild pets drawn by the room's tag
  profile drop by to *audition* — they roam, can be watched/photographed, and
  fed a treat. Happens often. This is the daily novelty without breaking any
  bond, because a visitor isn't yours yet.
- **Residents (rare, earned, meaningful):** a visitor whose preferences are
  well met keeps returning and eventually **asks to stay** — *that* is the knock
  at the door. Scarce and emotional: the payoff of a courtship, not a dice roll.

### The courtship / "signs" loop (replaces a binary daily roll)
A miss must advance *anticipation*, never zero out. Each courted species has a
visible **signs meter**:
- Door beat: "Something was at the door — gone now, but there are muddy paw
  prints." → a sign is logged.
- Overnight traces: a half-nibbled plant, fur on a cushion, a shape at the window.
- Signs accumulate visibly toward "willing to move in."
- **Tag match raises both visit frequency and the rate signs accrue.** Higher
  preference satisfaction = more likely to appear and to stay.

### Protecting the bond
- **No fungible pets.** One resident per species to start; later you may take in
  a 2nd/3rd, but **each is a distinct individual** (coat, trait, name, quirk) —
  a new relationship, never a clone.
- **A reason for a 2nd:** `social`-trait pets actually *thrive* with a
  same-species companion — so a second cat serves the ecosystem, not hoarding.
- **Capacity is diegetic:** total residents gated by home size / "how many
  friends you can truly care for," not arbitrary slot purchases.
- **No abandonment heartbreak:** at capacity, pets "retire to the garden /
  sanctuary" (a rotatable roster), always welcome back — never deleted.

### Field guide as a treasure map
An unidentified sign shows a silhouette + hints ("likes high places and warmth,
active at dusk"). Collection becomes a detective loop: read the hint → build the
habitat → court the pet. Discovery is active, driven by the same tag system.

### Cadence & cozy ethics
- A daily **visiting hour** (dawn/dusk ritual) **plus** player-triggered visits
  (leave a matching treat/toy → a visit arrives within a window). Ritual + agency.
- **Anti-FOMO:** miss a day and signs/visits wait or accumulate. No permanently
  missable core pets.
- **Pacing without timers:** early game is generous; rarer species need more
  specialized habitats, so the *complexity of the home itself* is the gate.

---

## 8. Plants & economy

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

## 9. Meta systems

- **Collection / "Field Guide":** discovered species, traits seen, photos taken.
- **Achievements:** behavior-driven and discovery-driven (e.g. "host 3 visitors
  at once", "photograph a pet sleeping in 5 different spots").
- **Daily ritual:** plant growth, visitor appearances, weather-gated events.

---

## 10. MVP — the vertical slice

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

## 11. Phased roadmap

- **Phase 1 — Vertical slice (MVP above):** validate the core loop & feel.
- **Phase 2 — Depth:** 3–4 species, full tag set, weather/time, photo gallery,
  achievements, first cosmetic IAP.
- **Phase 3 — Living world:** seasons, more exotic pets, emergent multi-pet
  vignettes, collection/field guide, events.
- **Phase 4 — Reach & polish:** cloud save, sharing, content cadence, soft launch.

---

## 12. Open decisions

- **Engine:** recommendation is **Godot 4** for a solo 2D pixel-art mobile game
  (free, lightweight, great 2D & mobile export). Alternatives: Unity, or
  Flutter + Flame. *Decision pending.*
- Working title / art direction reference board.
- Exact starting tag set and pet comfort profiles (needs prototyping/tuning).
- Visitor cadence tuning (how often, how rare).
- **Limited-time / seasonal event pets:** do any *missable* pets exist, or does
  that violate the cozy promise? *Leaning: seasonal visitors return each year,
  nothing permanently missable.*

---

## Appendix: design principles checklist

- [ ] No fail states; tension comes from *flourishing*, never punishment.
- [ ] Cadence comes from natural rhythms, never punishing energy timers.
- [ ] Money buys expression, never power.
- [ ] Every system feeds the spine (the living habitat) — cut anything that doesn't.
- [ ] If a feature doesn't make a pet feel more *alive* or the space more
      *yours*, question it.
