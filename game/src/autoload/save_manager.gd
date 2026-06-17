extends Node
## Versioned local save + offline catch-up entry point (DEVELOPMENT_PLAN.md
## §4.10; DESIGN §11/§16). M0 round-trips a minimal payload to user:// so the
## seam is real and testable; full state (placements, plant timestamps, pet,
## Coins, gallery, clock, RNG) is added incrementally per milestone.

const SAVE_VERSION := 1
const SAVE_PATH := "user://save.json"


func save_state(state: Dictionary) -> Error:
	var payload := {"save_version": SAVE_VERSION, "state": state}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_string(JSON.stringify(payload, "  "))
	f.close()
	return OK


func load_state() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return {}
	var text := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	# TODO(future): migrate older save_version payloads here before returning.
	return parsed
