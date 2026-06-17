class_name PlacementController
extends Node
## Placement input (DEVELOPMENT_PLAN.md M1): place / move / rotate / store with
## mouse + touch parity. Thin orchestration over RoomState — every operation is
## free (DESIGN §10). Lives inside the world SubViewport so event positions are
## already in room-space.
##
## Modes:
##   IDLE     — tap a placed item to pick it up (→ MOVING).
##   PLACING  — tap a cell to drop the active item; Rotate spins the ghost.
##   MOVING   — tap a cell to set the picked-up item down.
## Store mode (a toggle): tap a placed item to send it back to inventory.

enum Mode { IDLE, PLACING, MOVING }

var room: Node2D  # the RoomView; set by Main before _ready

var _mode: int = Mode.IDLE
var _active_item: StringName = &""
var _ghost_rotation: int = 0
var _moving_pid: int = -1
var _store_mode: bool = false


func begin_placing(item_id: StringName) -> void:
	_store_mode = false
	_active_item = item_id
	_ghost_rotation = 0
	_mode = Mode.PLACING


func set_store_mode(on: bool) -> void:
	_store_mode = on
	_mode = Mode.IDLE


func rotate_action() -> void:
	if _mode == Mode.PLACING:
		_ghost_rotation = (_ghost_rotation + 1) & 3
	elif _mode == Mode.MOVING and _moving_pid >= 0:
		RoomState.rotate(_moving_pid)


func _unhandled_input(event: InputEvent) -> void:
	if room == null or not _is_primary_press(event):
		return
	var cell: Vector2i = room.world_to_cell(_event_pos(event))
	_handle_tap(cell)


func _is_primary_press(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		return event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	if event is InputEventScreenTouch:
		return event.pressed
	return false


func _event_pos(event: InputEvent) -> Vector2:
	if event is InputEventMouseButton:
		return (event as InputEventMouseButton).position
	return (event as InputEventScreenTouch).position


func _handle_tap(cell: Vector2i) -> void:
	if _store_mode:
		var spid := _pid_at(cell)
		if spid >= 0:
			RoomState.store(spid)
		return
	match _mode:
		Mode.PLACING:
			RoomState.place(_active_item, cell, _ghost_rotation)  # stays in PLACING
		Mode.MOVING:
			if RoomState.move(_moving_pid, cell):
				_mode = Mode.IDLE
				_moving_pid = -1
		Mode.IDLE:
			var pid := _pid_at(cell)
			if pid >= 0:
				_moving_pid = pid
				_mode = Mode.MOVING


## Topmost (highest-layer) placement occupying a cell, or -1.
func _pid_at(cell: Vector2i) -> int:
	var best := -1
	var best_layer := -1
	for p in RoomState.placements():
		if p.layer < best_layer:
			continue
		for oc in p.occupied_cells():
			if oc == cell:
				best_layer = p.layer
				best = p.pid
				break
	return best
