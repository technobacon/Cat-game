class_name Charm
extends RefCounted
## Charm — the anti-monoculture + beauty layer (DESIGN §4). Pure scoring over the
## placed items into four readable sub-factors plus one 0..1 Charm score and a
## gentle tip:
##   Harmony     — palettes don't clash
##   Coherence   — items share a theme/style
##   Composition — uses layers, with breathing room (not sparse, not cluttered)
##   Variety     — directly penalizes monoculture
##
## Design guarantees, enforced by tests (DESIGN §4): a monoculture scores poorly;
## a varied/coherent room scores well; and free/earnable items can reach max
## Charm (paid cosmetics never score better).

# Weights — TODO(data): move to data/config (P§3.7). Variety is weighted highest
# as the primary anti-monoculture lever; a single-type room is trivially "in
# harmony", so harmony/coherence are weighted low to avoid rewarding spam.
const W_HARMONY := 0.15
const W_COHERENCE := 0.15
const W_COMPOSITION := 0.25
const W_VARIETY := 0.45

const OCC_LOW := 0.04   # occupancy below this reads as sparse
const OCC_HIGH := 0.5   # occupancy above this reads as cluttered


static func evaluate(placements: Array, catalog: Dictionary, grid_size: Vector2i) -> Dictionary:
	var total := placements.size()
	if total == 0:
		return {
			"charm": 0.0, "harmony": 0.0, "coherence": 0.0,
			"composition": 0.0, "variety": 0.0,
			"tips": ["Place some decor to bring the room to life."],
		}

	var type_counts := {}
	var palettes := {}
	var themes := {}
	var layers := {}
	var occupied := 0
	for p in placements:
		var item: DecorItem = catalog.get(String(p.item_id))
		if item == null:
			continue
		type_counts[String(p.item_id)] = int(type_counts.get(String(p.item_id), 0)) + 1
		palettes[item.palette_key] = int(palettes.get(item.palette_key, 0)) + 1
		themes[item.theme_key] = int(themes.get(item.theme_key, 0)) + 1
		layers[item.layer] = true
		occupied += p.occupied_cells().size()

	var distinct := type_counts.size()
	var dominant := 0
	for k in type_counts:
		dominant = max(dominant, int(type_counts[k]))
	var theme_max := 0
	for k in themes:
		theme_max = max(theme_max, int(themes[k]))

	var variety := clampf(float(distinct) / 5.0, 0.0, 1.0) * (1.0 - 0.5 * float(dominant) / float(total))
	var coherence := float(theme_max) / float(total)
	var harmony := clampf(1.0 - 0.2 * float(max(0, palettes.size() - 3)), 0.0, 1.0)

	var grid_cells := maxi(1, grid_size.x * grid_size.y)
	var occ := float(occupied) / float(grid_cells)
	var layer_score := clampf(float(layers.size()) / 3.0, 0.0, 1.0)
	var composition := 0.5 * layer_score + 0.5 * _band(occ, OCC_LOW, OCC_HIGH)

	var charm := W_HARMONY * harmony + W_COHERENCE * coherence \
		+ W_COMPOSITION * composition + W_VARIETY * variety

	return {
		"charm": charm, "harmony": harmony, "coherence": coherence,
		"composition": composition, "variety": variety,
		"tips": _tips(harmony, coherence, composition, variety, occ),
	}


## 1.0 inside [lo, hi], ramping down toward 0 outside the healthy band.
static func _band(x: float, lo: float, hi: float) -> float:
	if x < lo:
		return clampf(x / lo, 0.0, 1.0)
	if x > hi:
		return clampf(1.0 - (x - hi) / hi, 0.0, 1.0)
	return 1.0


static func _tips(harmony: float, coherence: float, composition: float, variety: float, occ: float) -> Array:
	# One gentle, useful nudge — Charm should feel like the game noticing effort,
	# not grading art (DESIGN §4).
	var lowest := minf(minf(harmony, coherence), minf(composition, variety))
	if lowest == variety:
		return ["Try a little more variety — lots of the same piece."]
	if lowest == composition:
		if occ > OCC_HIGH:
			return ["A bit cluttered — try removing a few things."]
		return ["A touch sparse — add a few pieces, and use shelves or hanging spots."]
	if lowest == coherence:
		return ["A few themes are mixing — leaning into one style reads cleaner."]
	return ["Some colours clash — try a more harmonious palette."]
