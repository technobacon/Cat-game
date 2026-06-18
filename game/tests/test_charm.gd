extends "res://addons/gut/test.gd"
## Charm guarantees (DESIGN §4): monoculture scores poorly, a varied/coherent
## room scores well, and free/earnable items can reach high Charm.

var catalog: Dictionary


func before_each() -> void:
	catalog = ItemCatalog.build()


func _stocked_model() -> RoomModel:
	var m := RoomModel.new()
	for id in catalog.keys():
		m.add_to_inventory(StringName(id), 6)
	return m


func test_empty_room_is_zero_with_a_tip() -> void:
	var r := Charm.evaluate([], catalog, Vector2i(12, 18))
	assert_eq(float(r["charm"]), 0.0, "empty room has no Charm")
	assert_false((r["tips"] as Array).is_empty(), "empty room offers a tip")


func test_monoculture_scores_low() -> void:
	var m := _stocked_model()
	for i in range(6):
		m.place(catalog["pot_plant"], Vector2i(i * 2, 0))
	var r := Charm.evaluate(m.placements(), catalog, m.grid_size)
	assert_lt(float(r["charm"]), 0.5, "a pile of one item scores poorly")


func test_varied_room_scores_high_with_free_items() -> void:
	var m := _stocked_model()
	var ids := ["rug", "cushion", "pot_plant", "shelf", "painting", "mug", "lantern", "vine"]
	var cells := [
		Vector2i(0, 0), Vector2i(4, 0), Vector2i(6, 0), Vector2i(0, 4),
		Vector2i(3, 4), Vector2i(0, 8), Vector2i(3, 8), Vector2i(5, 8),
	]
	for i in range(ids.size()):
		m.place(catalog[ids[i]], cells[i])
	var r := Charm.evaluate(m.placements(), catalog, m.grid_size)
	assert_gt(float(r["charm"]), 0.6, "a varied, coherent room of free items reaches high Charm")


func test_varied_beats_monoculture() -> void:
	var mono := _stocked_model()
	for i in range(6):
		mono.place(catalog["pot_plant"], Vector2i(i * 2, 0))
	var varied := _stocked_model()
	var ids := ["rug", "cushion", "pot_plant", "shelf", "painting", "lantern"]
	for i in range(ids.size()):
		varied.place(catalog[ids[i]], Vector2i((i % 3) * 3, (i / 3) * 4))
	var mono_charm := float(Charm.evaluate(mono.placements(), catalog, mono.grid_size)["charm"])
	var varied_charm := float(Charm.evaluate(varied.placements(), catalog, varied.grid_size)["charm"])
	assert_gt(varied_charm, mono_charm, "variety beats monoculture")
