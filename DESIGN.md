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

## 2. Setting & narrative frame

**A waystation on the migration paths.** You keep a cozy little haven at a
crossroads where wandering creatures stop to rest. Some pass through; a lucky
few, made comfortable enough, decide to stay. You've *inherited* the haven from
a previous keeper and it had fallen quiet — so reviving it is a gentle long arc
that completes, but the game continues endlessly after.

This frame isn't plot — it's the *why* behind every system:

| Mechanic | Diegetic reason the frame provides |
|---|---|
| Visitor → resident courtship | Creatures are travelers; comforting one into staying *is* the premise |
| Seasons + returning visitors | **Migration** — creatures pass through with the seasons (anti-FOMO becomes natural rhythm) |
| Coin income | Travelers leave tokens of thanks; you mail **postcards** of guests out into the world (photography → Gazette) |
| Trinkets | Wanderers leave keepsakes from far-off places when happy |
| Multiple rooms/biomes | Blank wings you revive & tune into the habitats *you* want — no preset biomes (§14) |
| Restoration arc | Reviving the quiet haven is the progression spine; resolves in a grand reopening, then an endless living haven (§14) |

- **Emotional note:** hospitality, and the bittersweet warmth of things that come
  and go — some friends pass through (back next season), some stay forever.
  Cozy, never heavy: no villain, no urgency, no fail.
- **Pets — real, with a sprinkle of magic:** mostly grounded real animals (cat,
  dog, hedgehog, fennec, axolotl…); a small tier of **fantastical creatures**
  unlocks deep in progression as a "wow" payoff — the crossroads can touch
  stranger places the further you revive it.
- **Light delivery:** a couple of recurring NPCs (a traveling merchant, an old
  keeper who mentors you), pets carrying micro-stories of where they wandered
  from (feeding Field Guide hints and the Memory Book), seasonal migration
  festivals. All ambient and skippable.

---

## 3. The spine: a living ecosystem where decoration is *functional*

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

## 4. Habitat stats & Charm

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

## 5. The two states

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

## 6. Signature creative pillars

1. **Read your pet** — empathy as the core skill (see Inspection).
2. **Emergent stories** — autonomous, personality-driven behavior worth sharing.
3. **Photography as a verb** — a gentle Snap system feeds collections &
   achievements ("catch the moment your shy hedgehog uses the new burrow").
4. **Living world** — real-world time/weather/seasons change behavior and which
   visitors appear. This *is* the daily-return loop — diegetic, not a timer.
5. **Personality over skins** — pets have temperament traits affecting
   preferences and compatibility, so the collection has real depth.

---

## 7. Pets

- **Starter:** player picks **cat or dog**.
- **Progression:** unlock increasingly exotic species (e.g. hedgehog → tree
  frog → fennec fox → axolotl → exotic birds). Each new species demands a
  *habitat built for it* (a specific tag profile) — unlocking is easy; making
  it **thrive** is the real game.
- **Traits:** each pet rolls a temperament (e.g. shy, bold, lazy, playful,
  social) affecting tells, decor preferences, and compatibility with other pets.

---

## 8. The pet's inner life: care, reading, bonding & behavior

This is the soul of the game — everything else is the frame around it.

### Core reframe (makes it cozy, not Tamagotchi)
> **Needs are invitations, not obligations. Care unlocks *upside*; neglect just
> means a quieter, dimmer pet — never punishment.**

A hungry pet is *asking you for something* (a moment of connection), not failing.
Ignore it and you don't get a dead pet — you get a less expressive one: it won't
thrive, gift Trinkets, show rich behaviors, or pose for great photos. You lose
the good stuff; you never trigger bad stuff.

### Care loop
- **Three lean needs** (`Food, Water, Enrichment`) that decay *slowly and
  forgivingly*. Offline they settle to a "content but missing you" floor — never
  to zero. Return after a week and the pet is *happy to see you*.
- **Care actions are bonding interactions, not chores.** Depth = how *this*
  pet responds (favorite foods, preferred play, a spot it likes to be groomed).
- **Low floor, high ceiling.** Minimum effort keeps the pet fine; richness
  (favorites, play, time together) is optional. Never a mandatory tap-fest.

### Reading the pet (the signature skill — empathy as mastery)
- State is shown through **behavior, not numbers**: sits by the empty bowl
  (hungry), paces at the window (visitor near), curls on your cushion (content),
  ears flat / hiding (overwhelmed).
- **Each pet's "language" is partly individual** — traits modulate tells, so you
  learn *this* animal; a second of a species is a fresh relationship.
- **Needs UI = hybrid that fades with bond:** start with gentle indicators/hints,
  then fade them as the bond grows so you rely on reading behavior. The game
  *rewards* relying on reading ("you two really know each other now") — turning
  the UI-vs-immersion tension into a relationship milestone.
- **Mastery is felt through the relationship**, not a score; misreading is never
  punished, just a gentle miss you learn from.

### Bond progression (the emotional payoff)
- Bond is the long arc; needs are the daily surface. Warm-named stages:
  **Wary → Curious → Friendly → Bonded → Inseparable.** Each unlocks:
  - more behaviors & little tricks (visibly more alive);
  - **trust moments** — greets you at the door, sleeps on your lap, accepts a
    hat, and **brings you Trinkets** (bond literally funds the beautiful home);
  - **the Memory Book** *(core feature)* — a per-pet relationship journal of
    milestones ("the first night she slept on your lap"). The *emotional*
    collection (vs the Field Guide's *discovery* collection) and the game's most
    shareable artifact.
- **Slow burn, not grindable** — bond grows through interaction *quality* with a
  soft daily ceiling; friendship is earned over real weeks.

### Room behavior & the "alive" simulation
- **Utility-driven AI** (solo-dev-friendly): each behavior scores by need + mood
  + trait + nearby decor; highest wins, with randomness for surprise. Emergent
  life, cheaply.
- **Decor-driven behaviors are the payoff loop** — cat tree climbed, box hidden
  in, sunbeam napped in. More varied/beautiful decor = more behaviors = richer
  life and better photos. This is *why* Charm and variety matter, made visible.
- **Trait & time flavor** — lazy pets nap, bold explore, shy hide from visitors;
  midday naps, dusk friskiness, watching the rain.
- **Inter-pet relationships** *(in scope)* — pets befriend/cuddle/groom or
  squabble over the best cushion. Unscripted vignettes are the screenshot gold
  and deepen the reason to keep multiple pets.
- **Decoration becomes directorial** — players arrange the room to *engineer*
  moments and photos ("catch her napping in the new hammock"). Setting a stage
  for life fuses decoration + behavior + photography.

### How it interlocks
read the pet → care well → bond deepens → pet thrives, behaves richly & gifts
Trinkets → a more beautiful, behavior-rich home → better photos & more thriving.
The animal is the engine, not a stat block.

---

## 9. Pet acquisition & bonding

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

## 10. Economy: currencies, decoration & income

### Two earned currencies (+ cosmetic cash)

- **Coins — the volume/utility currency (earned).** The workhorse. Buys the
  *bulk* of decor and plants — everyday building blocks. (Sources below.)
- **Trinkets — the prestige/beauty currency (earned only, never cash).** Come
  primarily from **thriving residents bringing you little found treasures** (the
  cat drops a shiny button, the magpie a glass bead), plus Charm milestones and
  visitor gifts. Trinkets buy the *rare, gorgeous, high-Charm* pieces — so you
  **cannot brute-force a beautiful room by grinding Coins**; the most beautiful
  items are gated behind the game's actual values (care + aesthetics). Pets
  literally help furnish their own beautiful home.

### Where Coins come from

**Principle:** Coins come from your home being a *beloved, beautiful place* —
never from a separate chore loop. Income is a readout of the spine, like
acquisition. Sources are spread fairly evenly so no single loop is mandatory,
but **photography is the "meta"** — the highest skill ceiling and best returns
for mastery, never *required*.

- **Photography → the "Critter Gazette" (the meta, active).** An in-world outlet
  pays Coins for photos, scored on subject rarity, the captured *moment*
  (behavior), and composition + backdrop Charm. Pays you for doing the thing the
  game is about; rewards beauty and the bond. Highest ceiling, optional to chase.
- **Visitor "thank-you" tips (passive, scales with the spine).** Hosted visitors
  leave a small token; the more inviting/charming the home, the more visitors and
  tips. Same lever as attraction — no new system to tend.
- **Plant produce (light trickle).** A thriving plant occasionally yields
  something sellable; a pet that loves it boosts the yield. Reframes the original
  farming idea as a *bonus from a well-kept garden*, never a treadmill.
- **Daily stipend / "mail" (cadence, not grind).** A small reliable daily
  delivery gives a baseline and a reason to check in, so income never *depends*
  on any one source.

Coins (volume) flow from **hosting** (photos, tips, produce, mail); Trinkets
(prestige) flow from **deep care** (thriving residents). Neither is a chore.

### Decoration acquisition & placement

- **Never tax creativity.** Buying costs; **placing, moving, rotating, and
  storing are always free and unlimited.** Friction on rearranging punishes the
  exact behavior the game is built on.
- **Multi-source acquisition** (keeps discovery alive):
  - **Shop** — rotating + permanent stock; Coins for staples, Trinkets for the
    aspirational tier.
  - **Pet & visitor gifts** — thriving residents/happy visitors leave decor,
    seeds, materials. Ties decor back to care.
  - **Achievement / field-guide unlocks** — themed items you can't buy; badges
    you *display*.
  - **Seasonal/weather items** — return each year (anti-FOMO).
  - **Crafting (Phase 2+)** — gather materials (harvest byproducts, shed fur →
    yarn) into items. Defer past MVP.
- **Placement UX:** snap-to-grid with layers (floor / wall / surfaces / hanging
  — layering powers the *Composition* Charm factor); free drag, rotate/flip,
  free storage & retrieval; a few free starter items for onboarding.

### Monetization line (hard rule)
- **Coins & Trinkets (earned)** buy *everything functional*: decor, plants,
  habitat expansions, new species. A non-paying player can collect every pet.
- **Real money** buys *only cosmetics*: recolors, patterns, pet accessories
  (hats/collars), photo frames & filters, decorative-only items, room themes.
- Paid cosmetics must be **Charm-neutral** — a different look, never an
  easier-to-harmonize one. Free items must be able to hit max Charm, or color
  scoring becomes a stealth paywall on attraction.
- **Never** sell a species, a need-fix, a thriving boost, or Trinkets. Money
  buys flair, never advantage.

### Plants & symbiosis
- Plants are **habitat pieces first** (tags + Charm + symbiosis), not an income
  treadmill. They grow on real-world time (no energy bars).
- **Symbiosis:** a pet that loves a plant boosts its yield; plants emit tags
  that attract pets. Visible cause-and-effect, not a hidden buff number.
- Farming is explicitly **not** the income engine — see "Where Coins come from".

---

## 11. Time, seasons & retention

**Throughline:** time makes the world feel present and alive; being away is
always rewarded with *discovery*, never punished with loss.

### The clock — 1:1 real-time
- The world runs on the phone's real clock; the pet **shares your real day**
  (morning grog, midday sunbeam naps, dusk friskiness, sleeping at night). That
  presence is the core "alive & shares my life" feeling.
- **Nocturnal vs diurnal** creatures turn the "I only play at night" problem into
  a feature: whenever you play you get a *full but different* experience; nobody
  is locked out of progress, only out of some visitors at some hours.

### Seasons — layered
- **Ambient season follows the real calendar** (real winter looks wintry, real
  holidays feel festive) — grounded, warm, zero maintenance.
- **Migration waves rotate every ~1–2 weeks** on their own cycle — a fresh band
  of travelers regularly passes through, independent of real season. Real
  seasons for *atmosphere*; migration waves for *content cadence*.

### Offline — the world lives, nothing is punished
- Plants grow; tips and the daily "mail" stipend accrue; **visitor signs
  accumulate** → you return to a pile of *discoveries*, not missed appointments.
- Needs settle to a "content but missing you" floor — never zero, never guilt.
- **Bond never decays.** Growth may pause; it never regresses. Non-negotiable.
- **Idle layer = light touch:** accrual while away is modest; active play
  (photos, courting, decorating) is where the real value is. A pet game, not an
  idle clicker.
- No pay-to-skip timers exist, so clock-changing ("time travel") hurts nobody —
  don't fight it.

### Session shapes — both respected
- **Quick check-in (1–3 min), the retention backbone:** collect accrual, greet
  the pet (a bond beat), see who's visiting, snap one photo. Must feel *complete
  on its own* — never "you only did half your chores."
- **Deep session (10–20+ min), always available, never demanded:** redecorate,
  court a species by tuning the habitat, shoot for the Gazette, browse the
  Memory Book, reorganize rooms.
- Two gentle daily pulls (morning accrual + an evening visiting hour), optional.

### Notifications & retention ethics
- **Gentle invitations only**, event-driven, capped, player-controlled
  ("A traveler is resting at your door 🐾").
- **Never** guilt or loss-aversion ("Your pet misses you!", "You'll lose your
  streak!"). No punishing streaks, no energy systems.
- Reward presence only by *adding* warmth (a happy welcome back); absence never
  subtracts. Retention comes from curiosity and fondness, not coercion.

---

## 12. Meta systems

- **Collection / "Field Guide":** discovered species, traits seen, photos taken.
- **Achievements:** behavior-driven and discovery-driven (e.g. "host 3 visitors
  at once", "photograph a pet sleeping in 5 different spots").
- **Daily ritual:** plant growth, visitor appearances, weather-gated events.

---

## 13. Onboarding & the first session

**Governing rule:** *Hook before teach.* Land the feeling first; reveal
mechanics one at a time, motivated by the fiction — never a tutorial wall.

### First 5 minutes (the emotional arc)
1. **Arrival (~30s):** you reach the inherited haven — quiet, dim, half-asleep.
   The old keeper (mentor) gives *one* warm line. Mood, not lecture.
2. **The first knock — the hook (~90s):** a sound at the door; you open it. A
   cat *or* dog (player chooses who's there), cold and shy, looking to rest.
   "Will you let them in?" You do. The signature ritual is done on turn one —
   **risk-free, because this first knock is guaranteed.**
3. **First care, taught by doing (~60s):** one guided action (food / a warm
   spot); the pet responds visibly (first tell → response → reward loop, no
   text). Auto-creates the **first Memory Book entry** ("the day they arrived").
4. **Name them** — right after the first positive moment, so you name a friend.
5. **Make a cozy spot (~60s):** handed a soft bed (+ maybe a plant); place it
   freely; the pet walks over and *uses it* — decoration → behavior, shown
   instantly. The seed of the spine.
6. **Close on a high:** the pet curls up content; the haven visibly **warms — a
   lamp lights, color returns** (the restoration arc, felt immediately).
   "Capture this?" → first photo → first Memory Book image. Complete and warm
   even if they never return.

*Deferred entirely in session 1:* Charm, shop/currency, plants-as-economy,
courtship mechanics, seasons.

### Progressive disclosure (one new idea per session, paced by the revival)
- **S2:** Coins + shop — a first tip/mail arrives; buy one decor item.
- **S3:** Plants — a gift of seeds; grow your first (real-time growth + garden).
- **S4 — the spine clicks:** the first *wild visitor* arrives; ritual pays off as
  a visitor (vs resident); **Field Guide** opens with its first silhouette +
  hint; lesson lands — *a nicer home brings more travelers.* That hint becomes
  the player's first self-set goal; onboarding graduates into the real game.
- **Later, as earned:** Charm/Room Report, the signs/courtship loop, Trinkets,
  migration waves, a second room.

The **spine is taught in two stages**: micro in S1 (a bed gets used → decoration
shapes behavior), macro in S4 (a lovely room draws visitors → decoration shapes
*who shows up*).

### Guidance principles
- **Mentor = recurring, then fades:** a warm keeper introduces each new system as
  the haven revives, then settles into an occasional friendly presence.
- **Teach diegetically** — mentor nudges + the pet's own cues; never modal walls;
  all text skippable.
- **No fail, no rush, no gate** — guidance invites, never blocks.
- **End S1 on a curiosity seed, not a chore** ("more travelers are on the road").

---

## 14. Progression & pacing

**Governing rule:** *one finite, heartfelt arc — then an endless living haven.*
The restoration arc is a real campaign that resolves; the waystation life
continues forever after. Best of both: a sense of accomplishment *and* a
forever-cozy sandbox.

### The macro spine — restoration = rooms = the species gate
The haven starts as **one small, dim room** and you revive it outward into
multiple rooms. Crucially, **every restored room starts blank — it has no preset
biome.** A room *is* the sum of the items you place (§3 tag vector), so the
player sculpts each room's environmental profile through decoration and decides
what it becomes — a warm sunroom, a humid grotto, a shaded burrow-garden —
**to match the species they personally want to attract.** Building the biome
*is* the puzzle, not picking a prefab one.

So the gate on which creatures can come is **how many rooms you've revived and
how you've tuned each one.** Expanding the haven literally widens the road:
more rooms → more distinct habitats you can run at once → more travelers reach
you. (This extends the anti-monoculture rule of §4: one room can't please a
desert fox *and* a rainforest frog, so revival is what lets habitats diverge.)

### Parallel tracks (a goal for every kind of player)
There is never just one thing to chase — players self-select, and every track
feeds the others:
1. **Restoration** (macro) — revive & tune rooms; the backbone that unlocks all.
2. **Collection** — discover → court → befriend species (Field Guide).
3. **Bond** — deepen each relationship (Memory Book, trust behaviors); slow burn.
4. **Aesthetic / Charm** — raise Charm, unlock themes, earn Trinkets, master
   beautiful rooms; the decorator's track.
5. **Achievements** — behavior- & discovery-driven feats.

### Scale — intimate by design
The haven stays **intimate: a modest number of deeply-bonded residents** you
truly cherish (capacity scales gently as rooms are revived — "more room for a
few more friends"). The *variety and churn* come from *visitors*, not from
hoarding residents — protecting the rule that **bonds are never broken** (§5).
Choosing who earns a permanent spot is part of the game.

### Pacing curve — front-loaded warmth, then a long slow burn
- **Week 1:** starter pet → first room → first plants → first wild visitor →
  first courted resident. Fast, generous, learn the loop.
- **Weeks 2–4:** revive & tune the 2nd room; 3–5 species; first migration wave;
  Charm/Room Report mastered; first Trinket buys. The game opens up.
- **Months 2–3:** several player-built biomes; courting Charm-gated rarities;
  first **Inseparable** bonds; seasonal events; the restoration arc nears its end.
- **The climax — a grand reopening:** the fully-revived haven hosts a migration
  **festival** where many creatures you've befriended return at once; the old
  keeper formally **passes you the torch.** A warm, earned ending.
- **Endless tail (post-arc):** rotating migration waves bring fresh species,
  seasonal events, room re-designs, completing the Field Guide & Memory Book,
  and the aspirational **fantastical-creature tier** — as the crossroads now
  "touches stranger places" (§2), rare magical migrants appear, gated behind
  mastering both Charm and exotic self-built biomes, often only during rare
  celestial/seasonal moments. No new grind — just the perpetual gentle rhythm.

### Gating levers — complexity & milestones, never timers
- **Coins** gate volume (decor, plants, a room's base restoration cost).
- **Milestones** gate access (revive the next room after N happy residents; a
  Field Guide hint points at the habitat axis a wanted species needs).
- **Charm** hard-gates rare species (§7); **Trinkets** gate the finest decor.
- **Tools unlock verbs gradually** (camera → Gazette lenses → garden → grooming).
- **No dead ends, no energy timers:** there's always one affordable next step,
  and the Field Guide hint always makes "I want *that* pet" *actionable*.

### Multiple-room specifics
Rooms are discrete navigable spaces (swipe/door between them). A resident lives
in the room whose profile suits it, so **who rooms where** is a placement puzzle
that reinforces distinct, curated biomes; inter-pet relationships (§6) play out
among roommates. *MVP stays one room;* multi-room is a Phase 2+ expansion.

---

## 15. Tech & art direction

The production foundation — the gate before code. Locked decisions below.

### Engine — **Godot 4**
- Free and open-source; **no licensing risk** and no per-install fees.
- Best-in-class **2D** workflow with a **built-in 2D lighting system** — directly
  serves the warming-haven arc (a lamp lights, color returns; §13) and
  golden-hour mood.
- One export target → **iOS, Android, desktop, and web**. The **web export** lets
  us put a playable prototype behind a link for instant feedback.
- GDScript for fast iteration; C# available if a system needs it later.
- Trade-off accepted: Unity's mature mobile live-ops/ads SDKs and larger asset
  store are a weaker draw here because monetization is deliberately gentle (§9).

### Platform & orientation
- **Mobile-first, portrait.** One-handed play fits the notification-driven,
  short-session check-in loop (§11); the room **scrolls vertically** and UI sits
  comfortably under the thumb.
- Desktop/web builds come "for free" from Godot for prototyping and sharing;
  full PC/console polish is a later consideration, not a launch target.

### Camera & perspective — **3/4 angled diorama**
- A cozy terrarium/dollhouse view: shows **floor space for decoration** *and*
  **verticality** (shelves, hanging plants, climbing perches).
- Reads both the placed decor and the **roaming, expressive pets** clearly — the
  habitat-as-spine (§3) and the pet "tells" (§5) need to be legible at a glance.
- Implies a layered 2D scene (background / mid / foreground) with depth-sorted
  sprites so pets pass in front of and behind decor convincingly.

### Art style — **hi-fi "modern" pixel art**
- Higher-resolution pixels, **rich warm palette**, soft shadows, particles, and
  **smooth multi-frame animation** — not chunky 8/16-bit retro.
- **Dynamic lighting is a feature, not polish:** the haven visibly warms as it
  revives, and time-of-day / weather (§11) shift the mood.
- **Animation is the heart of "alive":** budget the most art effort into
  expressive pet idles, reaction tells, and the emergent vignettes (§5–6); these
  carry the emotional payload and the photography loop (§8).
- Mood: warm, muted, golden-hour; cozy over crisp/clinical.

### Pipeline notes (to firm up alongside the first art)
- Pick a base virtual resolution and a consistent **pixels-per-unit** so all
  assets share one pixel grid; decide integer-scale vs smooth-scale on mobile.
- Aseprite as the likely sprite/animation tool; keep an organized tag/atlas
  convention so the **tag-driven decor system (§3)** maps cleanly to art assets.

---

## 16. MVP — the vertical slice

Goal: prove the magic with the smallest possible build. **One pet, one room.**

**In scope:**
- 1 starter pet (cat) with a temperament trait and 4–5 readable tells.
- Inspection state: read tells + 3 care actions (feed, water, play).
- Needs as **invitations** (slow, forgiving decay; no fail state), shown via
  gentle indicators + behavior.
- A simple **bond** track (a few stages) that unlocks a couple of trust
  behaviors — proves care deepens the relationship.
- Utility-driven room behaviors that respond to decor (nap in sunbeam, use a
  placed item) — proves the "alive" feel.
- Room state: place ~10 decor items + 1 plant type, free movement of pet.
- Habitat tag system with ~4 tags (`warmth, greenery, softness, hiding`).
- A basic **Charm** read (variety + clutter) feeding attraction, so the player
  feels beauty matters.
- 1 plant that grows on a real-time timer and yields a sellable harvest.
- 1 **visiting** pet (e.g. sparrow) attracted when the room crosses a tag
  threshold — proves the ecosystem loop end to end; leaves a small tip.
- **Coins** from: photo payouts (the meta) + a daily stipend + visitor tips.
- Photo button → saves to a simple gallery; photos pay Coins.
- Local save.

**Explicitly out of scope for MVP:** monetization/IAP, multiple species,
inter-pet relationships, the full Memory Book, fading-UI progression, weather/
seasons, achievements, breeding, cloud save, social features.

**The MVP succeeds if:** a player intuitively learns that *changing the room
changes who shows up and how the cat behaves* — and wants to keep tweaking it.

---

## 17. Phased roadmap

- **Phase 1 — Vertical slice (MVP above):** validate the core loop & feel.
- **Phase 2 — Depth:** 3–4 species, full tag set, weather/time, photo gallery,
  achievements, first cosmetic IAP.
- **Phase 3 — Living world:** seasons, more exotic pets, emergent multi-pet
  vignettes, collection/field guide, events.
- **Phase 4 — Reach & polish:** cloud save, sharing, content cadence, soft launch.

---

## 18. Open decisions

- **Engine:** recommendation is **Godot 4** for a solo 2D pixel-art mobile game
  (free, lightweight, great 2D & mobile export). Alternatives: Unity, or
  Flutter + Flame. *Decision pending.*
- Working title / art direction reference board.
- Exact starting tag set and pet comfort profiles (needs prototyping/tuning).
- Visitor cadence tuning (how often, how rare).
- ~~Limited-time / seasonal event pets~~ **Resolved:** migration frame means
  seasonal visitors return each year; nothing permanently missable.

### Still to design (next sessions)
- **Pipeline specifics:** base virtual resolution, pixels-per-unit, scaling
  mode, and the Aseprite → Godot atlas/tag convention (§15) — to firm up
  alongside the first real art and the MVP build.

---

## Appendix: design principles checklist

- [ ] No fail states; tension comes from *flourishing*, never punishment.
- [ ] Cadence comes from natural rhythms, never punishing energy timers.
- [ ] Money buys expression, never power.
- [ ] Every system feeds the spine (the living habitat) — cut anything that doesn't.
- [ ] If a feature doesn't make a pet feel more *alive* or the space more
      *yours*, question it.
