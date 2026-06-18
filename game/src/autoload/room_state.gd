extends Node
## Authoritative placed-item set (DEVELOPMENT_PLAN.md §2.3). Wraps a pure
## RoomModel and broadcasts EventBus.room_changed on edits. Tag aggregation +
## Charm land in M2 (DESIGN §3–4); for now room_changed carries an empty vector.

var model := RoomModel.new()
var catalog: Dictionary = {}

## Latest derived room state (DESIGN §3–4), refreshed on every placement edit.
var last_tags: Dictionary = {}
var last_charm: float = 0.0
var last_report: Dictionary = {}


func _ready() -> void:
	catalog = ItemCatalog.build()
	_seed_inventory()


func _seed_inventory() -> void:
	# M1: a generous starter stash so the player can decorate freely (DESIGN §13).
	for id in catalog.keys():
		model.add_to_inventory(StringName(id), 5)
	_changed()


func item(item_id: StringName) -> DecorItem:
	return catalog.get(String(item_id)) as DecorItem


func placements() -> Array[Placement]:
	return model.placements()


func inventory_count(item_id: StringName) -> int:
	return model.inventory_count(item_id)


func placement_count() -> int:
	return model.placements().size()


func place(item_id: StringName, cell: Vector2i, rotation_steps: int = 0) -> Placement:
	var p := model.place(item(item_id), cell, rotation_steps)
	if p != null:
		_changed()
	return p


func move(pid: int, new_cell: Vector2i) -> bool:
	var ok := model.move(pid, new_cell)
	if ok:
		_changed()
	return ok


func rotate(pid: int) -> bool:
	var ok := model.rotate(pid)
	if ok:
		_changed()
	return ok


func store(pid: int) -> bool:
	var ok := model.store(pid)
	if ok:
		_changed()
	return ok


## Snapshot/restore the whole room (used by SaveManager in M11; exercised now to
## satisfy the M1 "placements survive a dump/restore" guarantee).
func dump() -> Dictionary:
	return model.to_dict()


func restore(d: Dictionary) -> void:
	model.from_dict(d)
	_changed()


func _changed() -> void:
	# Recompute the room's tag vector (with diminishing returns) and Charm, then
	# broadcast (DESIGN §3–4).
	last_report = Charm.evaluate(model.placements(), catalog, model.grid_size)
	last_tags = RoomAggregator.aggregate(model.placements(), catalog, Balance.DIMINISHING_DECAY)
	last_charm = float(last_report.get("charm", 0.0))
	EventBus.room_changed.emit(last_tags, last_charm)
	EventBus.room_report.emit(last_report)
