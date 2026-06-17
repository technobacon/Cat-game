extends Node
## Authoritative set of placed items + the derived room tag vector and Charm
## (DEVELOPMENT_PLAN.md §2.3 / §4.1). Recomputes and emits EventBus.room_changed
## on any placement edit.
##
## M0 = skeleton. Tag aggregation (with diminishing returns) and Charm land in
## M2 (DESIGN §3–4); placement editing lands in M1.

var _placements: Array = []  # later: Array[Placement]


func placement_count() -> int:
	return _placements.size()


func recompute() -> void:
	# TODO(M2): sum item tags with per-type diminishing returns + compute Charm
	# (DESIGN §3–4). For now, broadcast an empty room so listeners can wire up.
	EventBus.room_changed.emit({}, 0.0)
