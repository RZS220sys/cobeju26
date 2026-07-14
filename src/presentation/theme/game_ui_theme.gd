class_name GameUiTheme
extends RefCounted


static func create() -> Theme:
	var theme := Theme.new()
	theme.set_font_size(&"font_size", &"Label", 19)
	theme.set_color(&"font_color", &"Label", Color("f8eccb"))
	theme.set_font_size(&"font_size", &"Button", 18)
	theme.set_color(&"font_color", &"Button", Color("fff2ca"))
	theme.set_color(&"font_hover_color", &"Button", Color("25170c"))
	theme.set_color(&"font_pressed_color", &"Button", Color("25170c"))
	theme.set_stylebox(&"normal", &"Button", _texture_box("res://assets/ui/button_normal.svg", 18.0, 10.0))
	theme.set_stylebox(&"hover", &"Button", _texture_box("res://assets/ui/button_hover.svg", 18.0, 10.0))
	theme.set_stylebox(&"pressed", &"Button", _texture_box("res://assets/ui/button_pressed.svg", 18.0, 10.0))
	theme.set_stylebox(&"focus", &"Button", _texture_box("res://assets/ui/button_hover.svg", 18.0, 10.0))
	theme.set_font_size(&"font_size", &"LineEdit", 20)
	theme.set_color(&"font_color", &"LineEdit", Color("fff2d0"))
	theme.set_stylebox(&"normal", &"LineEdit", _box(Color("10261f"), Color("9b7436"), 8, 2))
	theme.set_stylebox(&"focus", &"LineEdit", _box(Color("173529"), Color("edc56e"), 8, 3))
	return theme


static func panel() -> StyleBox:
	return _texture_box("res://assets/ui/panel_frame.svg", 22.0, 38.0)


static func card() -> StyleBox:
	return _texture_box("res://assets/ui/card_frame.svg", 18.0, 27.0)


static func meter_background() -> StyleBoxFlat:
	return _box(Color("101b18"), Color("415e50"), 5, 1)


static func meter_fill() -> StyleBoxFlat:
	return _box(Color("c94b4b"), Color("f39a68"), 5, 1)


@private
static func _texture_box(path: String, margin: float, content_margin: float) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = ResourceLoader.load(path, "Texture2D") as Texture2D
	style.texture_margin_left = margin
	style.texture_margin_right = margin
	style.texture_margin_top = margin
	style.texture_margin_bottom = margin
	style.content_margin_left = content_margin
	style.content_margin_right = content_margin
	style.content_margin_top = content_margin * 0.58
	style.content_margin_bottom = content_margin * 0.58
	return style


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
