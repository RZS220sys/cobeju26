class_name LumenfallUiTheme
extends RefCounted


static func create() -> Theme:
	var theme := Theme.new()
	theme.set_font_size(&"font_size", &"Label", 19)
	theme.set_color(&"font_color", &"Label", Color("f8eccb"))
	theme.set_font_size(&"font_size", &"Button", 18)
	theme.set_color(&"font_color", &"Button", Color("fff2ca"))
	theme.set_color(&"font_hover_color", &"Button", Color("25170c"))
	theme.set_color(&"font_pressed_color", &"Button", Color("25170c"))
	theme.set_stylebox(&"normal", &"Button", _box(Color("173529"), Color("c8953e"), 10, 2))
	theme.set_stylebox(&"hover", &"Button", _box(Color("e5b65b"), Color("fff0b0"), 10, 3))
	theme.set_stylebox(&"pressed", &"Button", _box(Color("bf7d2b"), Color("fff0b0"), 10, 3))
	theme.set_stylebox(&"focus", &"Button", _box(Color(0, 0, 0, 0), Color("fff0a5"), 10, 3))
	theme.set_font_size(&"font_size", &"LineEdit", 20)
	theme.set_color(&"font_color", &"LineEdit", Color("fff2d0"))
	theme.set_stylebox(&"normal", &"LineEdit", _box(Color("10261f"), Color("9b7436"), 8, 2))
	theme.set_stylebox(&"focus", &"LineEdit", _box(Color("173529"), Color("edc56e"), 8, 3))
	return theme


static func panel() -> StyleBoxFlat:
	return _box(Color(0.035, 0.09, 0.07, 0.96), Color("ba8739"), 16, 3)


static func card() -> StyleBoxFlat:
	return _box(Color(0.055, 0.16, 0.12, 0.96), Color("5c9b79"), 12, 2)


static func meter_background() -> StyleBoxFlat:
	return _box(Color("101b18"), Color("415e50"), 5, 1)


static func meter_fill() -> StyleBoxFlat:
	return _box(Color("c94b4b"), Color("f39a68"), 5, 1)


@private
static func _box(background: Color, border: Color, radius: int, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 20.0
	style.content_margin_right = 20.0
	style.content_margin_top = 13.0
	style.content_margin_bottom = 13.0
	return style
