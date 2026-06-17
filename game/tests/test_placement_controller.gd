extends "res://addons/gut/test.gd"
## PlacementController interaction logic (DEVELOPMENT_PLAN.md M1): drives the
## controller's tap handling directly (bypassing input) so store/move/pick-up are
## verified independently of the click-routing layer.

var controller: PlacementController


func before_each() -> void:
	RoomState.model = RoomModel.new()
	RoomState._seed_inventory()
	controller = autofree(PlacementController.new())


func test_pid_at_finds_placed_item() -> void:
	var p := RoomState.place(&"cushion", Vector2i(4, 4))
	assert_eq(controller._pid_at(Vector2i(4, 4)), p.pid, "finds the item under the cell")
	assert_eq(controller._pid_at(Vector2i(0, 0)), -1, "empty cell returns -1")


func test_store_mode_removes_tapped_item() -> void:
	RoomState.place(&"cushion", Vector2i(3, 3))
	assert_eq(RoomState.placement_count(), 1)
	controller.set_store_mode(true)
	controller._handle_tap(Vector2i(3, 3))
	assert_eq(RoomState.placement_count(), 0, "store removes the tapped item")


func test_tap_empty_in_store_mode_does_nothing() -> void:
	RoomState.place(&"cushion", Vector2i(3, 3))
	controller.set_store_mode(true)
	controller._handle_tap(Vector2i(9, 9))
	assert_eq(RoomState.placement_count(), 1, "storing an empty cell is a no-op")


func test_pick_up_and_move() -> void:
	var p := RoomState.place(&"cushion", Vector2i(1, 1))
	controller._handle_tap(Vector2i(1, 1))   # IDLE: pick up
	controller._handle_tap(Vector2i(6, 6))   # MOVING: drop
	assert_eq(p.cell, Vector2i(6, 6), "item moved to the tapped cell")


func test_placing_mode_drops_items() -> void:
	controller.begin_placing(&"bed")
	controller._handle_tap(Vector2i(2, 2))
	assert_eq(RoomState.placement_count(), 1, "placing drops an item on tap")
