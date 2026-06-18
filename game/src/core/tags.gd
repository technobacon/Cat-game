class_name Tags
extends RefCounted
## The MVP environmental tag axes (DESIGN §3–4, §16). A room or comfort-profile
## tag vector is a Dictionary[StringName, float] over these axes. The full ~8-axis
## set (DESIGN §4) is added later by extending AXES — a data-shaped change.

const AXES: Array[StringName] = [&"warmth", &"greenery", &"softness", &"hiding"]


static func zero() -> Dictionary:
	var v := {}
	for a in AXES:
		v[a] = 0.0
	return v


## Add `other * scale` into `acc` over the known axes (in place).
static func add_into(acc: Dictionary, other: Dictionary, scale: float = 1.0) -> void:
	for a in AXES:
		acc[a] = float(acc.get(a, 0.0)) + float(other.get(a, 0.0)) * scale
