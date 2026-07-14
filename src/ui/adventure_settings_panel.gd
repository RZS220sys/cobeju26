class_name AdventureSettingsPanel
extends CanvasLayer

signal closed

var settings: LumenfallSettings
var camera_rig: ThirdPersonAdventureCamera


func configure(settings_value: LumenfallSettings, camera_value: ThirdPersonAdventureCamera) -> void:
	settings = settings_value
	camera_rig = camera_value


@override
func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_interface()


@private
func _build_interface() -> void:
	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(0.01, 0.035, 0.03, 0.96)
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	veil.theme = LumenfallUiTheme.create()
	add_child(veil)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-430.0, -320.0)
	panel.size = Vector2(860.0, 640.0)
	panel.add_theme_stylebox_override(&"panel", LumenfallUiTheme.panel())
	veil.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 16)
	panel.add_child(column)
	var title := Label.new()
	title.text = "TRAVEL SETTINGS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override(&"font_size", 30)
	title.add_theme_color_override(&"font_color", Color("ffd477"))
	column.add_child(title)
	_add_slider(column, "MASTER VOLUME", 0.0, 1.0, 0.01, settings.master_volume, _set_volume)
	_add_slider(column, "MOUSE ORBIT SPEED", 0.0008, 0.006, 0.0001, settings.mouse_sensitivity, _set_sensitivity)
	_add_slider(column, "FIELD OF VIEW", 55.0, 90.0, 1.0, settings.field_of_view, _set_fov)
	_add_check(column, "INVERT VERTICAL ORBIT", settings.invert_vertical, _set_invert)
	_add_check(column, "FULLSCREEN", settings.fullscreen, _set_fullscreen)
	_add_check(column, "REDUCE CAMERA MOTION", settings.reduce_motion, _set_reduce_motion)
	var note := Label.new()
	note.text = "Settings apply immediately and are shared by every traveler."
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_color_override(&"font_color", Color("a9cbb5"))
	column.add_child(note)
	var done := Button.new()
	done.text = "SAVE & RETURN"
	done.custom_minimum_size.y = 58.0
	done.pressed.connect(close_panel)
	column.add_child(done)


@private
func _add_slider(parent: VBoxContainer, label_text: String, minimum: float, maximum: float, step: float, value: float, callback: Callable) -> void:
	var label := Label.new()
	label.text = label_text
	parent.add_child(label)
	var slider := HSlider.new()
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = step
	slider.value = value
	slider.custom_minimum_size.y = 34.0
	slider.value_changed.connect(callback)
	parent.add_child(slider)


@private
func _add_check(parent: VBoxContainer, text_value: String, pressed: bool, callback: Callable) -> void:
	var check := CheckButton.new()
	check.text = text_value
	check.button_pressed = pressed
	check.toggled.connect(callback)
	parent.add_child(check)


@private
func _set_volume(value: float) -> void:
	settings.master_volume = value
	_apply()


@private
func _set_sensitivity(value: float) -> void:
	settings.mouse_sensitivity = value
	_apply()


@private
func _set_fov(value: float) -> void:
	settings.field_of_view = value
	_apply()


@private
func _set_invert(value: bool) -> void:
	settings.invert_vertical = value
	_apply()


@private
func _set_fullscreen(value: bool) -> void:
	settings.fullscreen = value
	_apply()


@private
func _set_reduce_motion(value: bool) -> void:
	settings.reduce_motion = value
	_apply()


@private
func _apply() -> void:
	AdventureSettingsStore.apply(settings)
	if is_instance_valid(camera_rig):
		camera_rig.apply_settings(settings)


@override
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		close_panel()


func close_panel() -> void:
	AdventureSettingsStore.save_settings(settings)
	closed.emit()
	queue_free()
