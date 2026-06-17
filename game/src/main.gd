extends Node
## Root composition (DEVELOPMENT_PLAN.md §2.2): a pixel-perfect World SubViewport
## (the scrollable diorama) plus a resolution-independent HUD CanvasLayer. Built
## in code for M0 so the scene file stays trivial; later milestones flesh these
## out (room, decor, pet, UI).

const BASE_RESOLUTION := Vector2i(720, 1280)  # ratified: DESIGN §15 / plan §1


func _ready() -> void:
	_build_world()
	_build_hud()
	print("[boot] Cozy Pet Game scaffold up — %dx%d portrait" % [
		BASE_RESOLUTION.x, BASE_RESOLUTION.y,
	])


func _build_world() -> void:
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
	bg.color = Color(0.06, 0.06, 0.09)
	bg.size = BASE_RESOLUTION
	viewport.add_child(bg)

	var cam := Camera2D.new()
	cam.name = "RoomCamera"
	cam.position = Vector2(BASE_RESOLUTION) * 0.5
	viewport.add_child(cam)


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "HUD"
	add_child(hud)
