extends Node
## Decoupled signal hub (DEVELOPMENT_PLAN.md §0.3). No state — only signal
## declarations. Systems emit here; UI and AI react. Nobody reaches across the
## tree for state.

## Room tag vector and/or Charm changed after a placement edit (DESIGN §3–4).
signal room_changed(tag_vector: Dictionary, charm: float)

## Full Room Report (Charm + sub-factors + tips) after a placement edit (DESIGN §4).
signal room_report(report: Dictionary)

## A pet need changed (DESIGN §8). value is 0..1.
signal need_changed(need_id: StringName, value: float)

## A pet's bond advanced a stage — Wary→…→Inseparable (DESIGN §8).
signal bond_stage_up(stage: int)

## A wild visitor arrived, drawn by the room (DESIGN §9).
signal visitor_arrived(species_id: StringName)

## Coins balance changed (DESIGN §10).
signal coins_changed(total: int)
