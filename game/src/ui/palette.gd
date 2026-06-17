extends Control
## M1 decor palette (HUD, resolution-independent): one button per catalog item,
## plus Rotate and Store toggles. All actions are free (DESIGN §10). Lives in the
## HUD CanvasLayer, outside the world SubViewport.

var _controller: PlacementController


func setup(controller: PlacementController) -> void:
	_controller = controller
	_build()


func _build() -> void:
	var panel := VBoxContainer.new()
	panel.position = Vector2(8, 8)
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

	var grid := GridContainer.new()
	grid.columns = 2
	for id in RoomState.catalog.keys():
		var it := RoomState.item(StringName(id))
		var b := Button.new()
		b.text = it.display_name
		b.pressed.connect(func() -> void: _controller.begin_placing(it.id))
		grid.add_child(b)
	panel.add_child(grid)
