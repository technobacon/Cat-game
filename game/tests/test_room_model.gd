extends "res://addons/gut/test.gd"
## RoomModel guarantees (DEVELOPMENT_PLAN.md M1 acceptance criteria): the pure
## placement logic — inventory, bounds, overlap, rotation, move, serialization.

var catalog: Dictionary


func before_each() -> void:
	catalog = ItemCatalog.build()


func _make_model() -> RoomModel:
	var m := RoomModel.new()
	for id in catalog.keys():
		m.add_to_inventory(StringName(id), 5)
	return m


func test_catalog_spans_all_four_layers() -> void:
	assert_gte(catalog.size(), 10, "at least 10 placeholder items")
	var layers := {}
	for id in catalog.keys():
		layers[catalog[id].layer] = true
	assert_eq(layers.size(), 4, "items span all four placement layers")


func test_place_consumes_inventory() -> void:
	var m := _make_model()
	var before := m.inventory_count(&"bed")
	var p := m.place(catalog["bed"], Vector2i(0, 0))
	assert_not_null(p, "placement created")
	assert_eq(m.inventory_count(&"bed"), before - 1, "inventory decremented")
	assert_eq(m.placements().size(), 1)


func test_store_returns_to_inventory() -> void:
	var m := _make_model()
	var p := m.place(catalog["bed"], Vector2i(0, 0))
	var before := m.inventory_count(&"bed")
	assert_true(m.store(p.pid), "store succeeds")
	assert_eq(m.inventory_count(&"bed"), before + 1, "returned to inventory")
	assert_eq(m.placements().size(), 0)


func test_same_layer_overlap_rejected() -> void:
	var m := _make_model()
	assert_not_null(m.place(catalog["bed"], Vector2i(0, 0)), "2x2 floor bed placed")
	assert_null(m.place(catalog["cushion"], Vector2i(1, 1)), "overlap on same layer rejected")


func test_cross_layer_overlap_allowed() -> void:
	var m := _make_model()
	assert_not_null(m.place(catalog["rug"], Vector2i(0, 0)), "floor rug placed")
	assert_not_null(m.place(catalog["lantern"], Vector2i(0, 0)), "hanging item may sit above floor")


func test_out_of_bounds_rejected() -> void:
	var m := _make_model()
	assert_null(m.place(catalog["cushion"], Vector2i(m.grid_size.x, 0)), "outside grid rejected")


func test_rotate_swaps_footprint_orientation() -> void:
	var m := _make_model()
	var p := m.place(catalog["table"], Vector2i(0, 0))  # 2x1
	assert_eq(p.effective_footprint(), Vector2i(2, 1))
	assert_true(m.rotate(p.pid), "rotate succeeds")
	assert_eq(p.effective_footprint(), Vector2i(1, 2), "rotation swaps footprint")


func test_move_updates_cell() -> void:
	var m := _make_model()
	var p := m.place(catalog["cushion"], Vector2i(0, 0))
	assert_true(m.move(p.pid, Vector2i(5, 5)), "move succeeds")
	assert_eq(p.cell, Vector2i(5, 5))


func test_serialization_round_trip() -> void:
	var m := _make_model()
	m.place(catalog["bed"], Vector2i(0, 0))
	var table := m.place(catalog["table"], Vector2i(4, 4), 1)
	var snapshot := m.to_dict()

	var restored := RoomModel.new()
	restored.from_dict(snapshot)

	assert_eq(restored.placements().size(), 2, "both placements restored")
	var t := restored.find(table.pid)
	assert_not_null(t, "table placement found by pid")
	assert_eq(t.cell, Vector2i(4, 4), "cell preserved")
	assert_eq(t.rotation_steps, 1, "rotation preserved")
	assert_eq(t.effective_footprint(), Vector2i(1, 2), "rotated footprint preserved")
	assert_eq(restored.inventory_count(&"bed"), m.inventory_count(&"bed"), "inventory preserved")
