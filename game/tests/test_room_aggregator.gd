extends "res://addons/gut/test.gd"
## Tag aggregation guarantees (DESIGN §3–4): item tags sum into the room vector,
## with per-type diminishing returns so spam can't dominate an axis.

var catalog: Dictionary


func before_each() -> void:
	catalog = ItemCatalog.build()


func _model_with(id: StringName, n: int) -> RoomModel:
	var m := RoomModel.new()
	m.add_to_inventory(id, n)
	for i in range(n):
		m.place(catalog[String(id)], Vector2i(i * 2, 0))
	return m


func test_single_item_contributes_its_tags() -> void:
	var v := RoomAggregator.aggregate(_model_with(&"pot_plant", 1).placements(), catalog, 0.6)
	assert_almost_eq(float(v[&"greenery"]), 2.0, 0.001, "one plant = its greenery")


func test_diminishing_returns() -> void:
	var one := RoomAggregator.aggregate(_model_with(&"pot_plant", 1).placements(), catalog, 0.6)
	var five := RoomAggregator.aggregate(_model_with(&"pot_plant", 5).placements(), catalog, 0.6)
	assert_gt(float(five[&"greenery"]), float(one[&"greenery"]), "more plants = more greenery")
	assert_lt(float(five[&"greenery"]), float(one[&"greenery"]) * 5.0, "but with diminishing returns")


func test_fifth_copy_adds_little() -> void:
	var base := float(RoomAggregator.aggregate(_model_with(&"pot_plant", 1).placements(), catalog, 0.6)[&"greenery"])
	var four := float(RoomAggregator.aggregate(_model_with(&"pot_plant", 4).placements(), catalog, 0.6)[&"greenery"])
	var five := float(RoomAggregator.aggregate(_model_with(&"pot_plant", 5).placements(), catalog, 0.6)[&"greenery"])
	assert_lt(five - four, base * 0.2, "the 5th copy adds far less than the first")


func test_distinct_types_sum_independently() -> void:
	var m := RoomModel.new()
	m.add_to_inventory(&"pot_plant", 1)
	m.add_to_inventory(&"cushion", 1)
	m.place(catalog["pot_plant"], Vector2i(0, 0))
	m.place(catalog["cushion"], Vector2i(4, 0))
	var v := RoomAggregator.aggregate(m.placements(), catalog, 0.6)
	assert_almost_eq(float(v[&"greenery"]), 2.0, 0.001, "plant greenery")
	assert_almost_eq(float(v[&"softness"]), 1.5, 0.001, "cushion softness")
