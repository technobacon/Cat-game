extends Node
## Root composition (DEVELOPMENT_PLAN.md §2.2, simplified for M1).
##
## M1 renders the room directly in the main viewport and relies on the project's
## canvas_items stretch (P§1) for consistent 720x1280 coordinates — this keeps
## click->cell mapping simple and correct. The pixel-perfect SubViewport split
## can be reintroduced later once there's art to justify it.

const ROOM_SCENE := preload("res://scenes/room.tscn")
const PALETTE_SCRIPT := preload("res://src/ui/palette.gd")


func _ready() -> void:
	_build_background()

	var room := ROOM_SCENE.instantiate()
	add_child(room)

	var controller := PlacementController.new()
	controller.room = room
	add_child(controller)

	_build_hud(controller)

	print("[boot] Cozy Pet Game — M1 room slice up")


func _build_background() -> void:
	# Dim "dark room" behind everything. In its own layer so it never eats input
	# (the haven warms during onboarding, M12; DESIGN §13/§15).
	var layer := CanvasLayer.new()
	layer.layer = -1
	add_child(layer)

	var bg := ColorRect.new()
	bg.name = "DarkRoom"
	bg.color = Color(0.10, 0.09, 0.12)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(bg)


func _build_hud(controller: PlacementController) -> void:
	var hud := CanvasLayer.new()
	hud.name = "HUD"
	add_child(hud)

	var palette := PALETTE_SCRIPT.new()
	palette.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.add_child(palette)
	palette.setup(controller)
