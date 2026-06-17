class_name DecorItem
extends Resource
## A placeable decor item (DEVELOPMENT_PLAN.md §3.2).
##
## M1 carries identity, placement geometry, and a placeholder color. The tag
## contribution and Charm attributes (DESIGN §3–4) are added in M2 — the `tags`
## field exists now so that becomes a pure data edit, never a code change (P§0.1).

@export var id: StringName
@export var display_name: String = ""
## RoomEnums.Layer as int (kept as int for robust cross-class export).
@export var layer: int = RoomEnums.Layer.FLOOR
## Footprint in grid cells (before rotation).
@export var footprint: Vector2i = Vector2i.ONE
## Placeholder block color until real art lands (DESIGN §15).
@export var placeholder_color: Color = Color.WHITE
## TODO(M2): TagVector contribution emitted into the room (DESIGN §3).
@export var tags: Dictionary = {}
