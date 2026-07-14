class_name WorldEntryButton
extends Button

var _traveler_name: String = ""
var _journey_status: String = ""


func configure(summary: GameWorldSummary, last_played_text: String) -> void:
	_traveler_name = summary.display_name.to_upper()
	_journey_status = last_played_text.to_upper()
	queue_redraw()


@override
func _ready() -> void:
	custom_minimum_size.y = get_viewport_rect().size.y * 0.075
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
	var width := size.x
	var height := size.y
	var line_start := height * 0.56
	var line_end := width * 0.993
	var line_inset_y := height * 0.09
	var mark_center := Vector2(height * 0.38, height * 0.5)
	var active := is_hovered() or has_focus() or is_pressed()
	var line_color := Color(0.84, 0.88, 0.92, 0.86) if active else Color(0.75, 0.8, 0.85, 0.58)
	var text_color := Color.WHITE if active else Color(0.9, 0.92, 0.95, 0.88)
	var accent := Color(0.69, 0.52, 1.0, 0.95) if active else Color(0.55, 0.39, 0.82, 0.78)
	if active:
		draw_rect(Rect2(line_start, line_inset_y, maxf(0.0, line_end - line_start), height - line_inset_y * 2.0), Color(0.025, 0.035, 0.055, 0.38))
	draw_line(Vector2(line_start, line_inset_y), Vector2(line_end, line_inset_y), line_color, maxf(1.0, height * 0.013), true)
	draw_line(Vector2(line_start, height - line_inset_y), Vector2(line_end, height - line_inset_y), line_color, maxf(1.0, height * 0.013), true)
	_draw_memory_mark(mark_center, height, line_color, accent)
	var font := ThemeDB.fallback_font
	var name_size := maxi(12, roundi(height * 0.224))
	var detail_size := maxi(10, roundi(height * 0.171))
	var name_baseline := (height + font.get_ascent(name_size) - font.get_descent(name_size)) * 0.5
	var detail_baseline := (height + font.get_ascent(detail_size) - font.get_descent(detail_size)) * 0.5
	draw_string(font, Vector2(height * 0.88, name_baseline), _traveler_name, HORIZONTAL_ALIGNMENT_LEFT, width * 0.4, name_size, text_color)
	draw_string(font, Vector2(width * 0.52, detail_baseline), _journey_status, HORIZONTAL_ALIGNMENT_RIGHT, width * 0.43, detail_size, Color(text_color, text_color.a * 0.86))


@private
func _draw_memory_mark(center: Vector2, row_height: float, line_color: Color, accent: Color) -> void:
	var outer_radius := row_height * 0.33
	var middle_radius := row_height * 0.21
	var core_radius := row_height * 0.08
	var chevron_outer := row_height * 0.42
	var chevron_inner := row_height * 0.33
	var chevron_half_height := row_height * 0.09
	var outer := PackedVector2Array([
		center + Vector2(0.0, -outer_radius),
		center + Vector2(outer_radius, 0.0),
		center + Vector2(0.0, outer_radius),
		center + Vector2(-outer_radius, 0.0),
		center + Vector2(0.0, -outer_radius),
	])
	var middle := PackedVector2Array([
		center + Vector2(0.0, -middle_radius),
		center + Vector2(middle_radius, 0.0),
		center + Vector2(0.0, middle_radius),
		center + Vector2(-middle_radius, 0.0),
	])
	var core := PackedVector2Array([
		center + Vector2(0.0, -core_radius),
		center + Vector2(core_radius, 0.0),
		center + Vector2(0.0, core_radius),
		center + Vector2(-core_radius, 0.0),
	])
	draw_polyline(outer, line_color, maxf(1.0, row_height * 0.016), true)
	draw_colored_polygon(middle, Color(accent, 0.16))
	draw_polyline(PackedVector2Array([middle[0], middle[1], middle[2], middle[3], middle[0]]), accent, maxf(1.0, row_height * 0.018), true)
	draw_colored_polygon(core, accent)
	draw_line(center + Vector2(-chevron_outer, 0.0), center + Vector2(-chevron_inner, -chevron_half_height), line_color, maxf(1.0, row_height * 0.013), true)
	draw_line(center + Vector2(-chevron_outer, 0.0), center + Vector2(-chevron_inner, chevron_half_height), line_color, maxf(1.0, row_height * 0.013), true)
	draw_line(center + Vector2(chevron_outer, 0.0), center + Vector2(chevron_inner, -chevron_half_height), line_color, maxf(1.0, row_height * 0.013), true)
	draw_line(center + Vector2(chevron_outer, 0.0), center + Vector2(chevron_inner, chevron_half_height), line_color, maxf(1.0, row_height * 0.013), true)
