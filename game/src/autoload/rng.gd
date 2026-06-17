extends Node
## Single seeded random stream (DEVELOPMENT_PLAN.md §0.5 / §6.5) for reproducible
## visitor rolls, AI surprise, and trait rolls. State can be saved/restored so a
## run continues deterministically across sessions.

var _rng := RandomNumberGenerator.new()
var _seed: int = 0


func _ready() -> void:
	reseed(_seed)


func reseed(seed_value: int) -> void:
	_seed = seed_value
	_rng.seed = seed_value


func get_seed() -> int:
	return _seed


func randf() -> float:
	return _rng.randf()


func randf_range(from: float, to: float) -> float:
	return _rng.randf_range(from, to)


func randi_range(from: int, to: int) -> int:
	return _rng.randi_range(from, to)


func get_state() -> int:
	return _rng.state


func set_state(state_value: int) -> void:
	_rng.state = state_value
