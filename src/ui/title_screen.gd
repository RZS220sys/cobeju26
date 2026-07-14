class_name PalimpsestTitleScreen
extends Control

signal expedition_requested
signal archive_requested
signal workshop_requested
signal settings_requested
signal credits_requested
signal quit_requested

var _status_label: Label
var _profile: PalimpsestSaveData


func configure(profile: PalimpsestSaveData) -> void:
	_profile = profile


@override
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = ArchivePalette.build_ui_theme()
	_build_interface()


@private
func _build_interface() -> void:
	var backdrop := ArchiveBackdrop.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override(&"margin_left", 72)
	margin.add_theme_constant_override(&"margin_right", 72)
	margin.add_theme_constant_override(&"margin_top", 56)
	margin.add_theme_constant_override(&"margin_bottom", 44)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override(&"separation", 12)
	margin.add_child(layout)

	var eyebrow := Label.new()
	eyebrow.text = "THE NINTH LANTERN PRESENTS"
	eyebrow.add_theme_color_override(&"font_color", ArchivePalette.cyan())
	eyebrow.add_theme_font_size_override(&"font_size", 16)
	_add_limited(layout, eyebrow, 610.0)

	var title := Label.new()
	title.text = "PALIMPSEST"
	title.add_theme_color_override(&"font_color", ArchivePalette.amber())
	title.add_theme_font_size_override(&"font_size", 68)
	title.add_theme_constant_override(&"outline_size", 8)
	title.add_theme_color_override(&"font_outline_color", Color(0.02, 0.06, 0.09, 0.92))
	_add_limited(layout, title, 610.0)

	var subtitle := Label.new()
	subtitle.text = "LANTERNS OF THE DROWNED ARCHIVE"
	subtitle.add_theme_font_size_override(&"font_size", 21)
	subtitle.add_theme_color_override(&"font_color", ArchivePalette.bone().darkened(0.08))
	_add_limited(layout, subtitle, 610.0)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 36.0
	layout.add_child(spacer)

	var premise_panel := PanelContainer.new()
	premise_panel.add_theme_stylebox_override(&"panel", ArchivePalette.panel_style(Color(0.025, 0.07, 0.11, 0.9), Color(0.32, 0.63, 0.65, 0.35), 12, 1))
	premise_panel.custom_minimum_size = Vector2(610.0, 108.0)
	layout.add_child(premise_panel)
	var premise := Label.new()
	premise.text = "The sea remembers what the city paid to forget.\nCarry the last lantern below. Decide what deserves to remain."
	premise.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	premise.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	premise.add_theme_font_size_override(&"font_size", 19)
	premise_panel.add_child(premise)

	var start_button := Button.new()
	start_button.text = "BEGIN THE FIRST DESCENT"
	start_button.custom_minimum_size = Vector2(430.0, 58.0)
	start_button.pressed.connect(_on_start_pressed)
	layout.add_child(start_button)
	start_button.grab_focus.call_deferred()

	var secondary_row := HBoxContainer.new()
	secondary_row.alignment = BoxContainer.ALIGNMENT_CENTER
	secondary_row.add_theme_constant_override(&"separation", 10)
	layout.add_child(secondary_row)
	_add_secondary_button(secondary_row, "ARCHIVE", archive_requested.emit)
	_add_secondary_button(secondary_row, "WORKSHOP", workshop_requested.emit)
	_add_secondary_button(secondary_row, "CALIBRATION", settings_requested.emit)
	_add_secondary_button(secondary_row, "CREDITS", credits_requested.emit)
	_add_secondary_button(secondary_row, "QUIT", quit_requested.emit)

	var controls := Label.new()
	controls.text = "WASD move   •   J / left click cast   •   SPACE slip   •   Q resonate   •   E interact"
	controls.add_theme_font_size_override(&"font_size", 14)
	controls.add_theme_color_override(&"font_color", Color(0.65, 0.76, 0.78, 0.9))
	_add_limited(layout, controls, 610.0)

	_status_label = Label.new()
	_status_label.text = _profile_status()
	_status_label.add_theme_font_size_override(&"font_size", 13)
	_status_label.add_theme_color_override(&"font_color", ArchivePalette.magenta().lightened(0.1))
	_add_limited(layout, _status_label, 610.0)

	var footer := Label.new()
	footer.text = "v0.1 — THE ARCHIVE IS LISTENING"
	footer.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	footer.position = Vector2(-290.0, -42.0)
	footer.add_theme_font_size_override(&"font_size", 12)
	footer.add_theme_color_override(&"font_color", Color(0.45, 0.56, 0.58, 0.8))
	add_child(footer)


@private
func _add_limited(parent: Control, child: Control, width: float) -> void:
	child.custom_minimum_size.x = width
	parent.add_child(child)


@private
func _on_start_pressed() -> void:
	_status_label.text = "Opening descent seal…"
	expedition_requested.emit()


@private
func _add_secondary_button(parent: HBoxContainer, button_text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = button_text
	button.custom_minimum_size = Vector2(142.0, 42.0)
	button.add_theme_font_size_override(&"font_size", 14)
	button.pressed.connect(callback)
	parent.add_child(button)


@private
func _profile_status() -> String:
	if not is_instance_valid(_profile) or _profile.expeditions == 0:
		return "No memory has been committed yet."
	return "Archive depth %d  •  %d echoes witnessed  •  %d fragments available" % [_profile.story_depth, _profile.total_echoes, _profile.archive_fragments]
