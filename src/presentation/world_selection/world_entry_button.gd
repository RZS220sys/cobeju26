class_name WorldEntryButton
extends Button

var _traveler_name: String = ""
var _journey_status: String = ""


func configure(summary: LumenfallWorldSummary, formatted_time: String) -> void:
	_traveler_name = summary.display_name.to_upper()
	_journey_status = "CHAPTER %d  ·  %s" % [summary.quest_stage + 1, formatted_time.to_upper()]
	queue_redraw()


@override
func _ready() -> void:
	custom_minimum_size.y = 76.0
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_PASS
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	flat = true
	for style_name: StringName in [&"normal", &"hover", &"pressed", &"focus", &"disabled"]:
		add_theme_stylebox_override(style_name, StyleBoxEmpty.new())
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)


@override
func _draw() -> void:
	var active := is_hovered() or has_focus() or is_pressed()
	var line_color := Color(0.84, 0.88, 0.92, 0.86) if active else Color(0.75, 0.8, 0.85, 0.58)
	var text_color := Color.WHITE if active else Color(0.9, 0.92, 0.95, 0.88)
	var accent := Color(0.69, 0.52, 1.0, 0.95) if active else Color(0.55, 0.39, 0.82, 0.78)
	if active:
		draw_rect(Rect2(45.0, 7.0, maxf(0.0, size.x - 49.0), size.y - 14.0), Color(0.025, 0.035, 0.055, 0.38))
	draw_line(Vector2(42.0, 7.0), Vector2(size.x - 4.0, 7.0), line_color, 1.0, true)
	draw_line(Vector2(42.0, size.y - 7.0), Vector2(size.x - 4.0, size.y - 7.0), line_color, 1.0, true)
	_draw_memory_mark(Vector2(29.0, size.y * 0.5), line_color, accent)
	var font := ThemeDB.fallback_font
	var name_size := 17
	var detail_size := 13
	var name_baseline := (size.y + font.get_ascent(name_size) - font.get_descent(name_size)) * 0.5
	var detail_baseline := (size.y + font.get_ascent(detail_size) - font.get_descent(detail_size)) * 0.5
	draw_string(font, Vector2(67.0, name_baseline), _traveler_name, HORIZONTAL_ALIGNMENT_LEFT, size.x * 0.43, name_size, text_color)
	draw_string(font, Vector2(size.x * 0.52, detail_baseline), _journey_status, HORIZONTAL_ALIGNMENT_RIGHT, size.x * 0.43, detail_size, Color(text_color, text_color.a * 0.86))


@private
func _draw_memory_mark(center: Vector2, line_color: Color, accent: Color) -> void:
	var outer := PackedVector2Array([
		center + Vector2(0.0, -25.0),
		center + Vector2(25.0, 0.0),
		center + Vector2(0.0, 25.0),
		center + Vector2(-25.0, 0.0),
		center + Vector2(0.0, -25.0),
	])
	var middle := PackedVector2Array([
		center + Vector2(0.0, -16.0),
		center + Vector2(16.0, 0.0),
		center + Vector2(0.0, 16.0),
		center + Vector2(-16.0, 0.0),
	])
	var core := PackedVector2Array([
		center + Vector2(0.0, -6.0),
		center + Vector2(6.0, 0.0),
		center + Vector2(0.0, 6.0),
		center + Vector2(-6.0, 0.0),
	])
	draw_polyline(outer, line_color, 1.2, true)
	draw_colored_polygon(middle, Color(accent, 0.16))
	draw_polyline(PackedVector2Array([middle[0], middle[1], middle[2], middle[3], middle[0]]), accent, 1.4, true)
	draw_colored_polygon(core, accent)
	draw_line(center + Vector2(-32.0, 0.0), center + Vector2(-25.0, -7.0), line_color, 1.0, true)
	draw_line(center + Vector2(-32.0, 0.0), center + Vector2(-25.0, 7.0), line_color, 1.0, true)
	draw_line(center + Vector2(32.0, 0.0), center + Vector2(25.0, -7.0), line_color, 1.0, true)
	draw_line(center + Vector2(32.0, 0.0), center + Vector2(25.0, 7.0), line_color, 1.0, true)
