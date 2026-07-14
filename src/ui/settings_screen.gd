class_name SettingsScreen
extends Control

signal back_requested

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
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-390.0, -315.0)
	panel.size = Vector2(780.0, 630.0)
	panel.add_theme_stylebox_override(&"panel", ArchivePalette.panel_style(Color(0.018, 0.06, 0.09, 0.96), Color(0.36, 0.68, 0.68, 0.55), 14, 1))
	add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 18)
	panel.add_child(column)
	var title := Label.new()
	title.text = "LANTERN CALIBRATION"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override(&"font_size", 36)
	title.add_theme_color_override(&"font_color", ArchivePalette.amber())
	column.add_child(title)
	var difficulty := OptionButton.new()
	difficulty.name = "Difficulty"
	difficulty.add_item("STORY — forgiving combat, same narrative")
	difficulty.add_item("STANDARD — intended pressure")
	difficulty.add_item("SEVERE — faster and less forgiving")
	difficulty.selected = clampi(_profile.difficulty, 0, 2)
	difficulty.item_selected.connect(_on_difficulty_selected)
	_add_setting(column, "TIDE INTENSITY", difficulty)
	var volume := HSlider.new()
	volume.name = "MasterVolume"
	volume.min_value = 0.0
	volume.max_value = 1.0
	volume.step = 0.05
	volume.value = _profile.master_volume
	volume.value_changed.connect(_on_volume_changed)
	_add_setting(column, "MASTER VOLUME", volume)
	var fullscreen := CheckButton.new()
	fullscreen.name = "Fullscreen"
	fullscreen.text = "FULLSCREEN"
	fullscreen.button_pressed = _profile.fullscreen
	fullscreen.toggled.connect(_on_fullscreen_toggled)
	column.add_child(fullscreen)
	var aim_assist := CheckButton.new()
	aim_assist.name = "AimAssist"
	aim_assist.text = "KEYBOARD AIM ASSIST"
	aim_assist.button_pressed = _profile.aim_assist
	aim_assist.toggled.connect(func(enabled: bool) -> void: _profile.aim_assist = enabled)
	column.add_child(aim_assist)
	var accessibility := Label.new()
	accessibility.text = "Accessibility baseline\n• generous dash invulnerability  • high-contrast silhouettes\n• keyboard auto-aim  • no rapid taps  • all story available on every intensity"
	accessibility.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	accessibility.add_theme_font_size_override(&"font_size", 15)
	accessibility.add_theme_color_override(&"font_color", Color(0.68, 0.76, 0.77, 0.92))
	column.add_child(accessibility)
	var back := Button.new()
	back.name = "SaveAndReturn"
	back.text = "SAVE AND RETURN"
	back.custom_minimum_size.y = 54.0
	back.pressed.connect(_save_and_return)
	column.add_child(back)
	back.grab_focus.call_deferred()


@private
func _add_setting(parent: VBoxContainer, label_text: String, control: Control) -> void:
	var label := Label.new()
	label.text = label_text
	label.add_theme_color_override(&"font_color", ArchivePalette.cyan())
	label.add_theme_font_size_override(&"font_size", 15)
	parent.add_child(label)
	control.custom_minimum_size.y = 44.0
	parent.add_child(control)


@private
func _on_difficulty_selected(index: int) -> void:
	_profile.difficulty = index


@private
func _on_volume_changed(value: float) -> void:
	_profile.master_volume = value
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	AudioServer.set_bus_mute(0, value <= 0.001)


@private
func _on_fullscreen_toggled(enabled: bool) -> void:
	_profile.fullscreen = enabled
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_MAXIMIZED)


@private
func _save_and_return() -> void:
	ArchiveSaveManager.save_profile(_profile)
	back_requested.emit()
