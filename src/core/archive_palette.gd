class_name ArchivePalette
extends RefCounted


static func ink() -> Color:
	return Color("07131e")


static func deep_blue() -> Color:
	return Color("10293a")


static func brass() -> Color:
	return Color("d2a85b")


static func amber() -> Color:
	return Color("ffca72")


static func cyan() -> Color:
	return Color("66e0dc")


static func magenta() -> Color:
	return Color("e66baf")


static func bone() -> Color:
	return Color("edf2e4")


static func danger() -> Color:
	return Color("ff6b66")


static func make_material(color: Color, emission_strength: float = 0.0, roughness: float = 0.75) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = roughness
	if emission_strength > 0.0:
		result.emission_enabled = true
		result.emission = color
		result.emission_energy_multiplier = emission_strength
	return result


static func make_archive_floor_material() -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = Color(0.56, 0.63, 0.68, 1.0)
	var resource := ResourceLoader.load("res://assets/textures/archive_floor.png", "Texture2D")
	if resource is Texture2D:
		result.albedo_texture = resource as Texture2D
	result.roughness = 0.86
	result.metallic = 0.08
	result.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return result


static func panel_style(color: Color, border: Color, radius: int = 10, width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 18.0
	style.content_margin_right = 18.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	return style


static func build_ui_theme() -> Theme:
	var theme := Theme.new()
	theme.set_color(&"font_color", &"Label", bone())
	theme.set_color(&"font_shadow_color", &"Label", Color(0.0, 0.0, 0.0, 0.5))
	theme.set_constant(&"shadow_offset_x", &"Label", 1)
	theme.set_constant(&"shadow_offset_y", &"Label", 2)
	theme.set_font_size(&"font_size", &"Label", 18)
	theme.set_font_size(&"font_size", &"Button", 17)
	theme.set_color(&"font_color", &"Button", bone())
	theme.set_color(&"font_hover_color", &"Button", ink())
	theme.set_color(&"font_pressed_color", &"Button", ink())
	theme.set_stylebox(&"normal", &"Button", panel_style(Color(0.06, 0.14, 0.20, 0.94), Color(0.38, 0.58, 0.61, 0.7), 8, 1))
	theme.set_stylebox(&"hover", &"Button", panel_style(amber(), amber(), 8, 2))
	theme.set_stylebox(&"pressed", &"Button", panel_style(brass(), bone(), 8, 2))
	theme.set_stylebox(&"focus", &"Button", panel_style(Color(0.0, 0.0, 0.0, 0.0), cyan(), 8, 2))
	theme.set_constant(&"outline_size", &"Label", 2)
	return theme
