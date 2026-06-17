extends "res://addons/gut/test.gd"
## Determinism guarantee (DEVELOPMENT_PLAN.md §0.5 / §6.5): the single seeded RNG
## stream is reproducible, and its state can be saved/restored to continue a run.


func test_same_seed_reproduces_sequence() -> void:
	RNG.reseed(42)
	var a: Array[float] = []
	for i in range(5):
		a.append(RNG.randf())
	RNG.reseed(42)
	var b: Array[float] = []
	for i in range(5):
		b.append(RNG.randf())
	assert_eq(a, b, "Same seed must reproduce the same sequence")


func test_state_save_restore_continues_stream() -> void:
	RNG.reseed(7)
	RNG.randf()
	var saved_state: int = RNG.get_state()
	var expected: float = RNG.randf()
	RNG.set_state(saved_state)
	var got: float = RNG.randf()
	assert_eq(got, expected, "Restoring RNG state continues the same stream")
