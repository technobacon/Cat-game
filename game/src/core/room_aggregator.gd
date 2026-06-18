class_name RoomAggregator
extends RefCounted
## Sums placed items' tag contributions into the room's tag vector (DESIGN §3),
## applying per-item-type DIMINISHING RETURNS (DESIGN §4, anti-monoculture lever
## #1): the n-th copy of a type contributes base * decay^(n-1), so spamming one
## item can't dominate an axis. Pure and unit-tested.

static func aggregate(placements: Array, catalog: Dictionary, decay: float = 0.6) -> Dictionary:
	var result := Tags.zero()
	var seen := {}  # item_id(String) -> copies already counted
	for p in placements:
		var item: DecorItem = catalog.get(String(p.item_id))
		if item == null:
			continue
		var key := String(p.item_id)
		var n: int = int(seen.get(key, 0))
		Tags.add_into(result, item.tags, pow(decay, n))
		seen[key] = n + 1
	return result
