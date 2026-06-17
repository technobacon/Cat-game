class_name Placement
extends RefCounted
## One placed item instance in the room (DEVELOPMENT_PLAN.md §3). Carries its own
## geometry (footprint/layer) so the room can be serialized and restored without
## needing the item catalog.

var pid: int = 0
var item_id: StringName
var cell: Vector2i = Vector2i.ZERO
var layer: int = RoomEnums.Layer.FLOOR
var rotation_steps: int = 0  # quarter-turns, 0..3
var footprint: Vector2i = Vector2i.ONE


func effective_footprint() -> Vector2i:
	if rotation_steps % 2 == 1:
		return Vector2i(footprint.y, footprint.x)
	return footprint


func occupied_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var f := effective_footprint()
	for x in range(f.x):
		for y in range(f.y):
			cells.append(cell + Vector2i(x, y))
	return cells


func to_dict() -> Dictionary:
	return {
		"pid": pid,
		"item_id": String(item_id),
		"cell": [cell.x, cell.y],
		"layer": layer,
		"rotation_steps": rotation_steps,
		"footprint": [footprint.x, footprint.y],
	}


static func from_dict(d: Dictionary) -> Placement:
	var p := Placement.new()
	p.pid = int(d.get("pid", 0))
	p.item_id = StringName(d.get("item_id", ""))
	var c: Array = d.get("cell", [0, 0])
	p.cell = Vector2i(int(c[0]), int(c[1]))
	p.layer = int(d.get("layer", 0))
	p.rotation_steps = int(d.get("rotation_steps", 0))
	var f: Array = d.get("footprint", [1, 1])
	p.footprint = Vector2i(int(f[0]), int(f[1]))
	return p
