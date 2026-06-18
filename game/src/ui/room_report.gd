extends Control
## Live "Room Report" (DESIGN §4): shows the room's tag vector as bars plus the
## single Charm score and a gentle tip, updating on every placement edit. Sits in
## the HUD (top-right) and never eats input.

var _charm_label: Label
var _tip_label: Label
var _bars: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	EventBus.room_changed.connect(_on_room_changed)
	EventBus.room_report.connect(_on_report)
	# RoomState computed an initial report before this UI existed — pull it now.
	_on_room_changed(RoomState.last_tags, RoomState.last_charm)
	_on_report(RoomState.last_report)


func _build() -> void:
	var box := VBoxContainer.new()
	box.position = Vector2(470, 8)

	var title := Label.new()
	title.text = "Room Report"
	box.add_child(title)

	_charm_label = Label.new()
	box.add_child(_charm_label)

	for axis in Tags.AXES:
		var row := HBoxContainer.new()
		var name_label := Label.new()
		name_label.text = String(axis).capitalize()
		name_label.custom_minimum_size = Vector2(80, 0)
		row.add_child(name_label)
		var bar := ProgressBar.new()
		bar.min_value = 0.0
		bar.max_value = 6.0
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(120, 12)
		_bars[axis] = bar
		row.add_child(bar)
		box.add_child(row)

	_tip_label = Label.new()
	_tip_label.custom_minimum_size = Vector2(230, 0)
	_tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	box.add_child(_tip_label)

	add_child(box)
	_set_ignore_recursive(box)


func _on_room_changed(tags: Dictionary, charm: float) -> void:
	if _charm_label == null:
		return
	_charm_label.text = "Charm: %d / 100" % int(round(charm * 100.0))
	for axis in Tags.AXES:
		if _bars.has(axis):
			_bars[axis].value = float(tags.get(axis, 0.0))


func _on_report(report: Dictionary) -> void:
	if _tip_label == null:
		return
	var tips: Array = report.get("tips", [])
	_tip_label.text = "" if tips.is_empty() else String(tips[0])


func _set_ignore_recursive(node: Node) -> void:
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in node.get_children():
		_set_ignore_recursive(c)
