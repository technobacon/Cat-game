extends Node
## Root composition (DEVELOPMENT_PLAN.md §2.2): a pixel-perfect World SubViewport
## (the diorama) plus a resolution-independent HUD CanvasLayer. M1 boots into the
## decorating slice — grid room + placement controller + decor palette.

const BASE_RESOLUTION := Vector2i(720, 1280)
const ROOM_SCENE := preload("res://scenes/room.tscn")
const PALETTE_SCRIPT := preload("res://src/ui/palette.gd")


func _ready() -> void:
	var viewport := _build_world()

	var room := ROOM_SCENE.instantiate()
	viewport.add_child(room)

	# Controller lives inside the SubViewport so input is already in room-space.
	var controller := PlacementController.new()
	controller.room = room
	room.add_child(controller)

	_build_hud(controller)

	print("[boot] Cozy Pet Game — M1 room slice up (%dx%d portrait)" % [
		BASE_RESOLUTION.x, BASE_RESOLUTION.y,
	])


func _build_world() -> SubViewport:
	var container := SubViewportContainer.new()
	container.name = "World"
	container.stretch = true
	container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(container)

	var viewport := SubViewport.new()
	viewport.name = "WorldViewport"
	viewport.size = BASE_RESOLUTION
	viewport.snap_2d_transforms_to_pixel = true
	viewport.snap_2d_vertices_to_pixel = true
	container.add_child(viewport)

	# Placeholder "dark room" — the haven starts dim and warms during onboarding
	# (M12; DESIGN §13/§15).
	var bg := ColorRect.new()
	bg.name = "DarkRoom"
	bg.color = Color(0.10, 0.09, 0.12)
	bg.size = BASE_RESOLUTION
	viewport.add_child(bg)

	return viewport


func _build_hud(controller: PlacementController) -> void:
	var hud := CanvasLayer.new()
	hud.name = "HUD"
	add_child(hud)

	var palette := PALETTE_SCRIPT.new()
	palette.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.add_child(palette)
	palette.setup(controller)
