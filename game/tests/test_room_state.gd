extends "res://addons/gut/test.gd"
## RoomState integration (DEVELOPMENT_PLAN.md M1): edits broadcast room_changed,
## placement is free, and a dump/restore round-trips through the autoload.


func before_each() -> void:
	# Fresh room per test; keep the catalog the autoload built at startup.
	RoomState.model = RoomModel.new()
	RoomState._seed_inventory()


func test_place_emits_room_changed() -> void:
	watch_signals(EventBus)
	var before := RoomState.placement_count()
	RoomState.place(&"bed", Vector2i(0, 0))
	assert_eq(RoomState.placement_count(), before + 1, "placement added")
	assert_signal_emitted(EventBus, "room_changed")


func test_placing_and_storing_is_free() -> void:
	var coins_before := EconomyManager.coins()
	RoomState.place(&"rug", Vector2i(0, 0))
	var pid := RoomState.placements()[0].pid
	RoomState.store(pid)
	assert_eq(EconomyManager.coins(), coins_before, "rearranging never costs currency (DESIGN §10)")


func test_dump_restore_round_trip() -> void:
	RoomState.place(&"bed", Vector2i(0, 0))
	RoomState.place(&"table", Vector2i(5, 5))
	var snapshot := RoomState.dump()

	RoomState.store(RoomState.placements()[0].pid)
	assert_lt(RoomState.placement_count(), 2, "a placement was removed")

	RoomState.restore(snapshot)
	assert_eq(RoomState.placement_count(), 2, "restore brings placements back")
