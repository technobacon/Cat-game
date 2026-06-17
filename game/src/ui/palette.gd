extends Control
## M1 decor palette (HUD, resolution-independent): one button per catalog item,
## plus Rotate and Store toggles. All actions are free (DESIGN §10). Lives in the
## HUD CanvasLayer, outside the world SubViewport.

var _controller: PlacementController
var _status: Label


func setup(controller: PlacementController) -> void:
	_controller = controller
	_build()


func _build() -> void:
	# The palette fills the screen but must NOT eat taps meant for the room —
	# only the buttons should capture input; everything else falls through.
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var panel := VBoxContainer.new()
	panel.position = Vector2(8, 8)
	panel.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(panel)

	var tools := HBoxContainer.new()
	var rotate_btn := Button.new()
	rotate_btn.text = "Rotate"
	rotate_btn.pressed.connect(func() -> void: _controller.rotate_action())
	tools.add_child(rotate_btn)

	var store_btn := Button.new()
	store_btn.text = "Store"
	store_btn.toggle_mode = true
	store_btn.toggled.connect(func(on: bool) -> void: _controller.set_store_mode(on))
	tools.add_child(store_btn)
	panel.add_child(tools)

	_status = Label.new()
	_status.text = "Pick a decor item, then tap the grid"
	panel.add_child(_status)
	_controller.status_changed.connect(func(t: String) -> void: _status.text = t)

	var grid := GridContainer.new()
	grid.columns = 2
	for id in RoomState.catalog.keys():
		var it: DecorItem = RoomState.item(StringName(id))
		var b := Button.new()
		b.text = it.display_name
		b.pressed.connect(func() -> void: _controller.begin_placing(it.id))
		grid.add_child(b)
	panel.add_child(grid)
