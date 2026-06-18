class_name ItemCatalog
extends RefCounted
## M1/M2 placeholder decor set: ≥10 distinct items across all four placement
## layers, each carrying a tag contribution (DESIGN §3) and Charm attributes
## (palette/theme, DESIGN §4). Becomes data/items/*.tres later; this in-code
## catalog keeps the slice self-contained.


static func build() -> Dictionary:
	# id, name, layer, footprint, color, palette, theme, tags
	var defs := [
		["rug", "Woven Rug", RoomEnums.Layer.FLOOR, Vector2i(3, 2), "c98a5e", &"amber", &"cozy", {&"softness": 2.0, &"warmth": 0.5}],
		["cushion", "Soft Cushion", RoomEnums.Layer.FLOOR, Vector2i(1, 1), "d98a8a", &"amber", &"cozy", {&"softness": 1.5, &"warmth": 0.3}],
		["bed", "Cat Bed", RoomEnums.Layer.FLOOR, Vector2i(2, 2), "8a9bd9", &"amber", &"cozy", {&"softness": 2.0, &"warmth": 1.0, &"hiding": 0.5}],
		["pot_plant", "Potted Plant", RoomEnums.Layer.FLOOR, Vector2i(1, 1), "5ea36b", &"green", &"garden", {&"greenery": 2.0}],
		["table", "Low Table", RoomEnums.Layer.FLOOR, Vector2i(2, 1), "a07a4f", &"amber", &"cozy", {&"warmth": 0.2}],
		["shelf", "Wall Shelf", RoomEnums.Layer.WALL, Vector2i(2, 1), "b08f5f", &"amber", &"cozy", {&"hiding": 0.5}],
		["painting", "Framed Painting", RoomEnums.Layer.WALL, Vector2i(1, 1), "c2b280", &"slate", &"art", {&"warmth": 0.3}],
		["window", "Sunny Window", RoomEnums.Layer.WALL, Vector2i(2, 2), "f2d98a", &"slate", &"art", {&"warmth": 1.5}],
		["mug", "Ceramic Mug", RoomEnums.Layer.SURFACE, Vector2i(1, 1), "cf6f4f", &"amber", &"cozy", {&"warmth": 0.5}],
		["books", "Stack of Books", RoomEnums.Layer.SURFACE, Vector2i(1, 1), "6f8fcf", &"amber", &"cozy", {&"hiding": 0.2}],
		["lantern", "Hanging Lantern", RoomEnums.Layer.HANGING, Vector2i(1, 1), "f2c14e", &"amber", &"cozy", {&"warmth": 1.0}],
		["vine", "Hanging Vine", RoomEnums.Layer.HANGING, Vector2i(1, 2), "4f9f5f", &"green", &"garden", {&"greenery": 1.5, &"hiding": 0.5}],
	]
	var items := {}
	for d in defs:
		var it := DecorItem.new()
		it.id = StringName(d[0])
		it.display_name = d[1]
		it.layer = d[2]
		it.footprint = d[3]
		it.placeholder_color = Color(d[4])
		it.palette_key = d[5]
		it.theme_key = d[6]
		it.tags = d[7]
		items[String(it.id)] = it
	return items
