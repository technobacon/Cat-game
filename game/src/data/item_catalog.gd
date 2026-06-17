class_name ItemCatalog
extends RefCounted
## M1 placeholder decor set (DEVELOPMENT_PLAN.md §3.2): ≥10 distinct items across
## all four placement layers, so the room can be decorated end to end before any
## art exists. These become data/items/*.tres in M2; this in-code catalog keeps
## M1 self-contained.

# id, display name, layer, footprint, placeholder color
const _DEFS := [
	["rug", "Woven Rug", RoomEnums.Layer.FLOOR, Vector2i(3, 2), "c98a5e"],
	["cushion", "Soft Cushion", RoomEnums.Layer.FLOOR, Vector2i(1, 1), "d98a8a"],
	["bed", "Cat Bed", RoomEnums.Layer.FLOOR, Vector2i(2, 2), "8a9bd9"],
	["pot_plant", "Potted Plant", RoomEnums.Layer.FLOOR, Vector2i(1, 1), "5ea36b"],
	["table", "Low Table", RoomEnums.Layer.FLOOR, Vector2i(2, 1), "a07a4f"],
	["shelf", "Wall Shelf", RoomEnums.Layer.WALL, Vector2i(2, 1), "b08f5f"],
	["painting", "Framed Painting", RoomEnums.Layer.WALL, Vector2i(1, 1), "c2b280"],
	["window", "Sunny Window", RoomEnums.Layer.WALL, Vector2i(2, 2), "f2d98a"],
	["mug", "Ceramic Mug", RoomEnums.Layer.SURFACE, Vector2i(1, 1), "cf6f4f"],
	["books", "Stack of Books", RoomEnums.Layer.SURFACE, Vector2i(1, 1), "6f8fcf"],
	["lantern", "Hanging Lantern", RoomEnums.Layer.HANGING, Vector2i(1, 1), "f2c14e"],
	["vine", "Hanging Vine", RoomEnums.Layer.HANGING, Vector2i(1, 2), "4f9f5f"],
]


static func build() -> Dictionary:
	var items := {}
	for d in _DEFS:
		var it := DecorItem.new()
		it.id = StringName(d[0])
		it.display_name = d[1]
		it.layer = d[2]
		it.footprint = d[3]
		it.placeholder_color = Color(d[4])
		items[String(it.id)] = it
	return items
