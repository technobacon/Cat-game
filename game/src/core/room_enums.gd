class_name RoomEnums
extends RefCounted
## Shared room-domain enums (DEVELOPMENT_PLAN.md §3.2). The four placement layers
## power the Composition Charm factor (DESIGN §4) and map 1:1 to the Aseprite
## layer naming convention (DESIGN §15).

enum Layer { FLOOR, WALL, SURFACE, HANGING }

const LAYER_NAMES := {
	Layer.FLOOR: "floor",
	Layer.WALL: "wall",
	Layer.SURFACE: "surface",
	Layer.HANGING: "hanging",
}


static func layer_name(layer: int) -> String:
	return LAYER_NAMES.get(layer, "unknown")
