class_name WorldSelectionTheme
extends RefCounted


static func create() -> Theme:
	var theme := Theme.new()
	theme.set_font_size(&"font_size", &"Label", 16)
	theme.set_color(&"font_color", &"Label", Color("e8edf2"))
	theme.set_font_size(&"font_size", &"Button", 16)
	theme.set_color(&"font_color", &"Button", Color("e8edf2"))
	theme.set_color(&"font_hover_color", &"Button", Color.WHITE)
	theme.set_color(&"font_pressed_color", &"Button", Color.WHITE)
	theme.set_color(&"font_focus_color", &"Button", Color.WHITE)
	theme.set_color(&"font_disabled_color", &"Button", Color(0.69, 0.73, 0.78, 0.38))
	theme.set_stylebox(&"normal", &"Button", action_button(Color(0.0, 0.0, 0.0, 0.0), Color(0.88, 0.92, 0.96, 0.32)))
	theme.set_stylebox(&"hover", &"Button", action_button(Color(0.06, 0.08, 0.11, 0.62), Color(0.91, 0.87, 1.0, 0.82)))
	theme.set_stylebox(&"pressed", &"Button", action_button(Color(0.12, 0.1, 0.18, 0.72), Color(0.78, 0.68, 1.0, 0.95)))
	theme.set_stylebox(&"focus", &"Button", focus_outline())
	theme.set_stylebox(&"disabled", &"Button", action_button(Color(0.0, 0.0, 0.0, 0.18), Color(0.68, 0.72, 0.78, 0.16)))
	theme.set_font_size(&"font_size", &"LineEdit", 19)
	theme.set_color(&"font_color", &"LineEdit", Color.WHITE)
	theme.set_color(&"font_placeholder_color", &"LineEdit", Color(0.78, 0.82, 0.87, 0.48))
	theme.set_stylebox(&"normal", &"LineEdit", field(false))
	theme.set_stylebox(&"focus", &"LineEdit", field(true))
	return theme


static func glass_panel() -> StyleBoxFlat:
	return _box(Color(0.012, 0.02, 0.03, 0.76), Color(0.89, 0.93, 0.97, 0.42), 1, 2, 22.0, 18.0)


static func traveler_row(selected: bool = false) -> StyleBoxFlat:
	var background := Color(0.025, 0.04, 0.055, 0.7) if selected else Color(0.012, 0.022, 0.032, 0.52)
	var border := Color(0.76, 0.66, 1.0, 0.92) if selected else Color(0.88, 0.92, 0.96, 0.34)
	return _box(background, border, 1, 1, 18.0, 12.0)


static func action_button(background: Color, border: Color) -> StyleBoxFlat:
	return _box(background, border, 1, 1, 18.0, 13.0)


static func quiet_button() -> StyleBoxFlat:
	return _box(Color(0.0, 0.0, 0.0, 0.0), Color(0.88, 0.92, 0.96, 0.22), 1, 0, 9.0, 8.0)


static func focus_outline() -> StyleBoxFlat:
	return _box(Color(0.08, 0.07, 0.13, 0.28), Color(0.79, 0.69, 1.0, 0.92), 1, 1, 18.0, 13.0)


static func field(focused: bool) -> StyleBoxFlat:
	var border := Color(0.79, 0.69, 1.0, 0.92) if focused else Color(0.89, 0.93, 0.97, 0.4)
	return _box(Color(0.01, 0.018, 0.028, 0.88), border, 1, 1, 18.0, 14.0)


@private
static func _box(background: Color, border: Color, width: int, radius: int, horizontal_margin: float, vertical_margin: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = horizontal_margin
	style.content_margin_right = horizontal_margin
	style.content_margin_top = vertical_margin
	style.content_margin_bottom = vertical_margin
	return style
