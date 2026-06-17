extends Node2D
## Renders the room grid and its placements as depth-sorted placeholder blocks
## (DEVELOPMENT_PLAN.md M1; DESIGN §15 layered, depth-sorted 2D). Rebuilds when
## EventBus.room_changed fires. Visuals are placeholders until art (M2+).

const TILE_PX := 16
const GRID_COLOR := Color(1.0, 1.0, 1.0, 0.06)
const BASE_RESOLUTION := Vector2i(720, 1280)

@onready var _items_root: Node2D = $Items

var origin: Vector2 = Vector2.ZERO


func _ready() -> void:
	y_sort_enabled = true
	_items_root.y_sort_enabled = true
	_center_grid()
	EventBus.room_changed.connect(_on_room_changed)
	queue_redraw()
	_rebuild()


func _center_grid() -> void:
	var gs := RoomState.model.grid_size
	var px := Vector2(gs.x, gs.y) * TILE_PX
	origin = (Vector2(BASE_RESOLUTION) - px) * 0.5


func cell_to_world(cell: Vector2i) -> Vector2:
	return origin + Vector2(cell) * TILE_PX


func world_to_cell(world: Vector2) -> Vector2i:
	var local := (world - origin) / float(TILE_PX)
	return Vector2i(floori(local.x), floori(local.y))


func _draw() -> void:
	var gs := RoomState.model.grid_size
	var w := gs.x * TILE_PX
	var h := gs.y * TILE_PX
	for x in range(gs.x + 1):
		draw_line(origin + Vector2(x * TILE_PX, 0), origin + Vector2(x * TILE_PX, h), GRID_COLOR)
	for y in range(gs.y + 1):
		draw_line(origin + Vector2(0, y * TILE_PX), origin + Vector2(w, y * TILE_PX), GRID_COLOR)


func _on_room_changed(_tags: Dictionary, _charm: float) -> void:
	_rebuild()


func _rebuild() -> void:
	for c in _items_root.get_children():
		c.queue_free()
	for p in RoomState.placements():
		var it := RoomState.item(p.item_id)
		if it == null:
			continue
		_items_root.add_child(_make_visual(p, it))


func _make_visual(p: Placement, it: DecorItem) -> Node2D:
	var holder := Node2D.new()
	var eff := p.effective_footprint()
	var rect := ColorRect.new()
	rect.color = it.placeholder_color
	rect.size = Vector2(eff.x, eff.y) * TILE_PX - Vector2(2, 2)
	rect.position = Vector2(1, 1)
	holder.add_child(rect)
	holder.position = cell_to_world(p.cell)
	# Lower layers behind higher ones; within a layer, Y-sort by screen position.
	holder.z_index = p.layer
	holder.set_meta("pid", p.pid)
	return holder
