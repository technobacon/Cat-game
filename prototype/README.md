# Waystation — MVP Prototype (browser)

A **playable, browser-based prototype** of the MVP vertical slice described in
[`../DESIGN.md` §16](../DESIGN.md#16-mvp--the-vertical-slice). It proves the
**spine** — *curate the space → attract & sustain pets → pets enrich the space* —
end to end, with one pet and one room.

> **Scope note.** This is a **design-validation prototype**, deliberately built in
> plain HTML5/Canvas/JS so it runs instantly on a phone or desktop with **zero
> install**. The production game is still **Godot 4** as locked in `DESIGN.md` §15.
> Treat this as a throwaway "is the loop fun?" probe, not the codebase.

## How to run it

It's a single static page — no build step, no dependencies.

- **Easiest:** open `prototype/index.html` directly in any modern browser
  (Chrome, Safari, Firefox, mobile included).
- **If your browser blocks `file://` access to `game.js`** (some do), serve the
  folder over HTTP instead:
  ```bash
  cd prototype
  python3 -m http.server 8000
  # then visit http://localhost:8000  (or http://<your-ip>:8000 from your phone)
  ```

State autosaves to `localStorage`. To start over, clear site data, or run
`localStorage.removeItem('waystation_mvp_v1')` in the dev console.

## What to try (the 2-minute test)

1. **Open the door**, pick a cat or dog, name it, and **place the starter bed** —
   watch the pet walk over and use it. *(Decoration → behavior, the spine in
   miniature.)*
2. Tap **🛋️ Decorate** and place a **Sunny window** → the pet finds the
   **sunbeam** and naps in it. Add a **Cardboard box** → it hides; a **Cat tree**
   → it climbs; a **Feather toy** → it plays.
3. Watch the **Room Report** (top-left): adding **variety** and a coherent theme
   raises **Charm**; spamming one item type or cluttering tanks it.
4. Add **greenery** (fern / hanging ivy / a grown plant) and keep Charm up →
   a **sparrow visits** (attraction = tag match × Charm) and leaves a **tip**.
5. Tap **📷** to sell a photo to the Gazette (pays more for a good moment, a
   visitor in frame, and high Charm). Tap **🐾 Pet** to read tells and care for it.
6. Tap the **clock chip** (top-right) to fast-forward time (demo) and see the
   lighting and behaviors shift between day/dusk/night.

## What's implemented (maps to `DESIGN.md` §16)

| §16 in-scope item | Status in this prototype |
|---|---|
| 1 starter pet (cat) + temperament trait + readable tells | ✅ cat **or** dog; one of 3 traits (cozy/playful/shy); behavior-driven tells in Inspect |
| Inspection: read tells + 3 care actions (feed, water, play) | ✅ feed / water / play **(+ pet)**; tells panel |
| Needs as **invitations** (slow, forgiving, no fail) | ✅ 3 needs decay slowly, settle to a floor offline, never punish |
| Simple **bond** track unlocking trust behaviors | ✅ Wary→Curious→Friendly→Bonded→Inseparable; Bonded+ residents bring **Trinkets** |
| Utility-driven room behaviors responding to decor | ✅ sunbeam-nap, bed-rest, box-hide, tree-climb, toy-play, eat/drink, groom, wander |
| Place ~10 decor items + 1 plant; free pet movement | ✅ 11 buyable items (+3 starters) + a growable plant; free place/drag |
| Habitat **tag system** (warmth, greenery, softness, hiding) | ✅ with **diminishing returns** per tag (anti-monoculture) |
| Basic **Charm** (variety + clutter) feeding attraction | ✅ Charm from Variety/Composition/Coherence/Harmony, multiplies attraction |
| 1 plant grows on real-time timer → sellable harvest | ✅ catmint; greenery scales with growth; harvest pays Coins (cat boosts yield) |
| 1 **visiting** pet attracted past a tag threshold; leaves a tip | ✅ sparrow (diurnal); arrives via attraction = match × Charm; tips Coins |
| **Coins** from photos + daily stipend + visitor tips | ✅ all three sources |
| Photo button → gallery; photos pay Coins | ✅ Gazette payout scored on moment/visitor/Charm/bond; thumbnail gallery |
| Local save | ✅ `localStorage` + offline accrual on return |

Also honored from the design: **onboarding** (hook-before-teach first session,
§13), **time-of-day lighting** and the **warming-haven** glow (§11, §13), the
**Trinket** prestige currency from thriving residents (§10), and the appendix
principles (no fail states, cadence from the real clock, no pay-to-win).

## Deliberate deviations / simplifications

- **Engine:** HTML5 instead of Godot — for instant, install-free testing only.
- **Plant timer compressed** to ~3 minutes (real game: days) so growth is
  observable in one sitting. Flagged in the Garden UI.
- **Placeholder art:** emoji + simple canvas shapes stand in for the hi-fi pixel
  art (§15). The point here is the *systems*, not the visuals.
- **Demo clock control:** tapping the clock fast-forwards time — handy for testing
  day/night behavior without waiting. The real game runs 1:1 on the device clock.
- **Care/bond rates** are tuned faster than a shipping game so a tester feels the
  loop in minutes rather than weeks.

## Explicitly NOT in this prototype (per §16 non-goals)

Monetization/IAP, multiple species at once, inter-pet relationships, the full
Memory Book, fading-UI progression, weather/seasons, achievements, breeding,
cloud save, and social features.

## Where the code lives

- `index.html` — layout, styling (warm golden-hour palette), DOM UI overlay.
- `game.js` — everything else, organized into commented sections:
  ecosystem math (tags/Charm/match), the clock, the plant, the cat utility-AI,
  the visitor, the canvas renderer, input, UI wiring, photography, onboarding,
  and the main loop.

The functional heart is in `game.js`: `roomTags()` / `matchProfile()` /
`charmReport()` (the spine math) and `chooseAction()` (the utility-driven "alive"
behavior).
