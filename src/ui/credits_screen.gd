class_name CreditsScreen
extends Control

signal back_requested


@override
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = ArchivePalette.build_ui_theme()
	var backdrop := ArchiveBackdrop.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var column := VBoxContainer.new()
	column.set_anchors_preset(Control.PRESET_CENTER)
	column.position = Vector2(-430.0, -300.0)
	column.size = Vector2(860.0, 600.0)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override(&"separation", 18)
	add_child(column)
	var title := Label.new()
	title.text = "PALIMPSEST"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override(&"font_size", 52)
	title.add_theme_color_override(&"font_color", ArchivePalette.amber())
	column.add_child(title)
	var body := Label.new()
	body.text = "LANTERNS OF THE DROWNED ARCHIVE\n\nCreated as an original interactive work\nDesign • code • narrative • procedural art direction\n\nBuilt with Godot / WGodot\nPhysics by Jolt Physics\nPersistence models generated with CCL\n\nThank you for carrying the lantern.\n\nNo generative live services, telemetry, advertisements,\nor paid progression are used by this game."
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_theme_font_size_override(&"font_size", 18)
	body.add_theme_color_override(&"font_color", ArchivePalette.bone())
	column.add_child(body)
	var back := Button.new()
	back.name = "BackButton"
	back.text = "RETURN"
	back.custom_minimum_size = Vector2(280.0, 52.0)
	back.pressed.connect(func() -> void: back_requested.emit())
	column.add_child(back)
	back.grab_focus.call_deferred()
