extends "res://addons/gut/test.gd"
## Compile gate: every script under res://src compiles. Tests don't otherwise
## load the scene/UI scripts (RoomView, PlacementController, palette, Main), so
## this catches parse/type errors in them on CI without needing to render.


func test_all_src_scripts_compile() -> void:
	var failed: Array[String] = []
	_scan("res://src", failed)
	assert_eq(failed, [] as Array[String], "all scripts under src/ compile")


func _scan(path: String, failed: Array[String]) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		var full := path + "/" + name
		if dir.current_is_dir():
			if not name.begins_with("."):
				_scan(full, failed)
		elif name.ends_with(".gd"):
			if load(full) == null:
				failed.append(full)
		name = dir.get_next()
	dir.list_dir_end()
