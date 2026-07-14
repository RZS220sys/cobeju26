class_name PauseMenu
extends CanvasLayer

signal resume_requested
signal traveler_book_requested
signal quit_requested
signal settings_requested

var _root: Control


@override
func _ready() -> void:
	layer = 80
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_interface()
	visible = false


@private
func _build_interface() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.theme = GameUiTheme.create()
	add_child(_root)
	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(0.01, 0.035, 0.03, 0.9)
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(veil)
	var layout := HBoxContainer.new()
	layout.set_anchors_preset(Control.PRESET_CENTER)
	layout.position = Vector2(-520.0, -300.0)
	layout.size = Vector2(1040.0, 600.0)
	layout.add_theme_constant_override(&"separation", 28)
	veil.add_child(layout)
	var menu := PanelContainer.new()
	menu.custom_minimum_size.x = 430.0
	menu.add_theme_stylebox_override(&"panel", GameUiTheme.panel())
	layout.add_child(menu)
	var menu_column := VBoxContainer.new()
	menu_column.add_theme_constant_override(&"separation", 14)
	menu.add_child(menu_column)
	var title := Label.new()
	title.text = "JOURNEY PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override(&"font_size", 32)
	title.add_theme_color_override(&"font_color", Color("ffd477"))
	menu_column.add_child(title)
	_add_button(menu_column, "CONTINUE", _resume)
	_add_button(menu_column, "TRAVEL SETTINGS", _settings)
	_add_button(menu_column, "SAVE & OPEN TRAVELER BOOK", _open_book)
	_add_button(menu_column, "SAVE & QUIT", _quit)
	var hint := Label.new()
	hint.text = "ESC closes this journal"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_color_override(&"font_color", Color("9fc3aa"))
	menu_column.add_child(hint)
	var guide := PanelContainer.new()
	guide.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	guide.add_theme_stylebox_override(&"panel", GameUiTheme.card())
	layout.add_child(guide)
	var guide_column := VBoxContainer.new()
	guide_column.add_theme_constant_override(&"separation", 14)
	guide.add_child(guide_column)
	var heading := Label.new()
	heading.text = "WAYFARER'S NOTES"
	heading.add_theme_font_size_override(&"font_size", 25)
	heading.add_theme_color_override(&"font_color", Color("73e8ff"))
	guide_column.add_child(heading)
	var controls := Label.new()
	controls.text = "WASD  Move relative to camera\nMouse  Orbit camera\nWheel  Zoom\nShift  Sprint\nSpace  Jump\nE  Speak / examine\nLeft click  Sword strike"
	controls.add_theme_font_size_override(&"font_size", 19)
	controls.add_theme_color_override(&"font_color", Color("f3e5bd"))
	guide_column.add_child(controls)
	var economy := Label.new()
	economy.text = "HEARTH-COINS\nWages and trade between people.\n\nRIFTGLASS\nMemory crystallized by a rift. A crafting material; never legal tender."
	economy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	economy.add_theme_color_override(&"font_color", Color("bfe1cd"))
	guide_column.add_child(economy)


@private
func _add_button(parent: VBoxContainer, text_value: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size.y = 62.0
	button.pressed.connect(callback)
	parent.add_child(button)


func open() -> void:
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


@override
func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_resume()


@private
func _resume() -> void:
	visible = false
	resume_requested.emit()


@private
func _open_book() -> void:
	traveler_book_requested.emit()


@private
func _settings() -> void:
	settings_requested.emit()


@private
func _quit() -> void:
	quit_requested.emit()
