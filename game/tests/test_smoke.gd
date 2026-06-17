extends "res://addons/gut/test.gd"
## M0 smoke tests (DEVELOPMENT_PLAN.md §6): the scaffold boots and core seams
## respond. These encode the project skeleton's contract.


func test_autoloads_present() -> void:
	assert_not_null(EventBus, "EventBus autoload present")
	assert_not_null(GameClock, "GameClock autoload present")
	assert_not_null(RoomState, "RoomState autoload present")
	assert_not_null(SaveManager, "SaveManager autoload present")
	assert_not_null(EconomyManager, "EconomyManager autoload present")
	assert_not_null(RNG, "RNG autoload present")
	assert_not_null(Balance, "Balance autoload present")


func test_economy_add_coins() -> void:
	var before: int = EconomyManager.coins()
	EconomyManager.add_coins(5)
	assert_eq(EconomyManager.coins(), before + 5, "Coins increase by the added amount")


func test_economy_never_below_zero() -> void:
	# No fail states / no punishment in money paths (DESIGN §10): balance floors at 0.
	EconomyManager.add_coins(-1_000_000)
	assert_gte(EconomyManager.coins(), 0, "Coins never go negative")


func test_save_round_trip() -> void:
	var ok := SaveManager.save_state({"hello": "world"})
	assert_eq(ok, OK, "save_state returns OK")
	var loaded := SaveManager.load_state()
	assert_eq(loaded.get("save_version"), SaveManager.SAVE_VERSION, "save_version is written")
	var state: Dictionary = loaded.get("state", {})
	assert_eq(state.get("hello"), "world", "state round-trips losslessly")
