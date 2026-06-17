class_name RoomModel
extends RefCounted
## Pure room state (DEVELOPMENT_PLAN.md §2.3 / §4.1): grid bounds, an inventory of
## owned items, and the placements in the room. No nodes, no rendering — fully
## unit-testable and serializable.
##
## Placing, moving, rotating, and storing are ALL free and unlimited (DESIGN §10):
## this class never touches currency. Out-of-bounds and same-layer overlaps are
## rejected; cross-layer overlap (a hanging vine above a rug) is allowed.

var grid_size: Vector2i = Vector2i(12, 18)

var _placements: Array[Placement] = []
var _inventory: Dictionary = {}  # item_id(String) -> count(int)
var _next_pid: int = 1


func placements() -> Array[Placement]:
	return _placements


func inventory_count(item_id: StringName) -> int:
	return int(_inventory.get(String(item_id), 0))


func add_to_inventory(item_id: StringName, amount: int = 1) -> void:
	var key := String(item_id)
	_inventory[key] = int(_inventory.get(key, 0)) + amount


func find(pid: int) -> Placement:
	for p in _placements:
		if p.pid == pid:
			return p
	return null


func _cells_for(footprint: Vector2i, cell: Vector2i, rotation_steps: int) -> Array[Vector2i]:
	var eff := footprint
	if rotation_steps % 2 == 1:
		eff = Vector2i(footprint.y, footprint.x)
	var cells: Array[Vector2i] = []
	for x in range(eff.x):
		for y in range(eff.y):
			cells.append(cell + Vector2i(x, y))
	return cells


func _in_bounds(cells: Array[Vector2i]) -> bool:
	for c in cells:
		if c.x < 0 or c.y < 0 or c.x >= grid_size.x or c.y >= grid_size.y:
			return false
	return true


func _overlaps(layer: int, cells: Array[Vector2i], ignore_pid: int = -1) -> bool:
	var want := {}
	for c in cells:
		want[c] = true
	for p in _placements:
		if p.layer != layer or p.pid == ignore_pid:
			continue
		for oc in p.occupied_cells():
			if want.has(oc):
				return true
	return false


func can_place(footprint: Vector2i, layer: int, cell: Vector2i, rotation_steps: int, ignore_pid: int = -1) -> bool:
	var cells := _cells_for(footprint, cell, rotation_steps)
	if not _in_bounds(cells):
		return false
	if _overlaps(layer, cells, ignore_pid):
		return false
	return true


func place(item: DecorItem, cell: Vector2i, rotation_steps: int = 0) -> Placement:
	if item == null:
		return null
	if inventory_count(item.id) <= 0:
		return null
	if not can_place(item.footprint, item.layer, cell, rotation_steps):
		return null
	var p := Placement.new()
	p.pid = _next_pid
	_next_pid += 1
	p.item_id = item.id
	p.cell = cell
	p.layer = item.layer
	p.rotation_steps = rotation_steps & 3
	p.footprint = item.footprint
	_placements.append(p)
	_inventory[String(item.id)] = inventory_count(item.id) - 1
	return p


func move(pid: int, new_cell: Vector2i) -> bool:
	var p := find(pid)
	if p == null:
		return false
	if not can_place(p.footprint, p.layer, new_cell, p.rotation_steps, pid):
		return false
	p.cell = new_cell
	return true


func rotate(pid: int) -> bool:
	var p := find(pid)
	if p == null:
		return false
	var next := (p.rotation_steps + 1) & 3
	if not can_place(p.footprint, p.layer, p.cell, next, pid):
		return false
	p.rotation_steps = next
	return true


func store(pid: int) -> bool:
	var p := find(pid)
	if p == null:
		return false
	_placements.erase(p)
	add_to_inventory(p.item_id, 1)
	return true


func to_dict() -> Dictionary:
	var pl := []
	for p in _placements:
		pl.append(p.to_dict())
	return {
		"grid_size": [grid_size.x, grid_size.y],
		"next_pid": _next_pid,
		"inventory": _inventory.duplicate(),
		"placements": pl,
	}


func from_dict(d: Dictionary) -> void:
	var g: Array = d.get("grid_size", [12, 18])
	grid_size = Vector2i(int(g[0]), int(g[1]))
	_next_pid = int(d.get("next_pid", 1))
	_inventory = (d.get("inventory", {}) as Dictionary).duplicate()
	_placements.clear()
	for pd in d.get("placements", []):
		_placements.append(Placement.from_dict(pd))
