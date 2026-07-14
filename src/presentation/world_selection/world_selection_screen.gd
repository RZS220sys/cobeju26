class_name WorldSelectionScreen
extends Control

signal world_selected(state: LumenfallWorldState)

const BACKGROUND_PATH := "res://assets/ui/title_screen/listening_stone_background.png"

var _world_list: VBoxContainer
var _first_world_button: WorldEntryButton
var _new_traveler_button: Button
var _creation_overlay: Control
var _creation_panel: PanelContainer
var _name_edit: LineEdit
var _empty_hint: Label
var _settings_panel: SettingsPanel


@override
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = WorldSelectionTheme.create()
	_build_interface()
	_refresh_worlds()
	_animate_entrance()


@private
func _build_interface() -> void:
	_build_background()
	_build_identity()
	_build_traveler_menu()
	_build_creation_overlay()


@private
func _build_background() -> void:
	var background := TextureRect.new()
	background.name = "ListeningStoneBackground"
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.texture = ResourceLoader.load(BACKGROUND_PATH, "Texture2D") as Texture2D
	add_child(background)
	var atmosphere := ColorRect.new()
	atmosphere.name = "Atmosphere"
	atmosphere.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	atmosphere.color = Color(0.0, 0.01, 0.02, 0.08)
	atmosphere.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(atmosphere)


@private
func _build_identity() -> void:
	var identity := VBoxContainer.new()
	identity.name = "Identity"
	identity.set_anchors_preset(Control.PRESET_TOP_LEFT)
	identity.position = Vector2(52.0, 52.0)
	identity.size = Vector2(410.0, 128.0)
	identity.add_theme_constant_override(&"separation", 8)
	add_child(identity)
	var title := Label.new()
	title.text = "LUMENFALL"
	title.add_theme_font_size_override(&"font_size", 42)
	title.add_theme_color_override(&"font_color", Color(0.94, 0.96, 0.98, 0.96))
	identity.add_child(title)
	var rule := ColorRect.new()
	rule.custom_minimum_size = Vector2(340.0, 1.0)
	rule.color = Color(0.92, 0.95, 0.98, 0.56)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	identity.add_child(rule)
	var subtitle := Label.new()
	subtitle.text = "T H E   F I R S T   C R O S S I N G"
	subtitle.add_theme_font_size_override(&"font_size", 14)
	subtitle.add_theme_color_override(&"font_color", Color(0.86, 0.89, 0.93, 0.86))
	identity.add_child(subtitle)


@private
func _build_traveler_menu() -> void:
	var menu := VBoxContainer.new()
	menu.name = "TravelerMenu"
	menu.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	menu.position = Vector2(-650.0, -490.0)
	menu.size = Vector2(590.0, 430.0)
	menu.add_theme_constant_override(&"separation", 10)
	add_child(menu)
	_empty_hint = Label.new()
	_empty_hint.text = "NO TRAVELER HAS CROSSED YET"
	_empty_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_hint.add_theme_font_size_override(&"font_size", 13)
	_empty_hint.add_theme_color_override(&"font_color", Color(0.8, 0.84, 0.89, 0.62))
	menu.add_child(_empty_hint)
	var scroll := SmoothScrollContainer.new()
	scroll.name = "TravelerScroll"
	scroll.custom_minimum_size.y = 228.0
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.wheel_step = 86.0
	scroll.response = 15.0
	menu.add_child(scroll)
	_world_list = VBoxContainer.new()
	_world_list.name = "TravelerList"
	_world_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_world_list.add_theme_constant_override(&"separation", 8)
	scroll.add_child(_world_list)
	_new_traveler_button = Button.new()
	_new_traveler_button.name = "NewTravelerButton"
	_new_traveler_button.text = "NEW JOURNEY"
	_new_traveler_button.custom_minimum_size.y = 50.0
	_new_traveler_button.add_theme_stylebox_override(&"normal", WorldSelectionTheme.menu_action(Color(0.0, 0.0, 0.0, 0.0), Color(0.82, 0.87, 0.92, 0.22)))
	_new_traveler_button.add_theme_stylebox_override(&"hover", WorldSelectionTheme.menu_action(Color(0.04, 0.05, 0.08, 0.4), Color(0.82, 0.72, 1.0, 0.72)))
	_new_traveler_button.add_theme_stylebox_override(&"pressed", WorldSelectionTheme.menu_action(Color(0.08, 0.06, 0.12, 0.5), Color(0.82, 0.72, 1.0, 0.92)))
	_new_traveler_button.pressed.connect(_show_creation)
	menu.add_child(_new_traveler_button)
	var secondary := HBoxContainer.new()
	secondary.alignment = BoxContainer.ALIGNMENT_END
	secondary.add_theme_constant_override(&"separation", 12)
	menu.add_child(secondary)
	_add_quiet_button(secondary, "SETTINGS", _open_settings)
	_add_quiet_button(secondary, "QUIT", _quit)


@private
func _add_quiet_button(parent: HBoxContainer, text_value: String, callback: Callable) -> void:
	var button := Button.new()
	button.name = text_value.capitalize().replace(" ", "") + "Button"
	button.text = text_value
	button.flat = true
	button.add_theme_font_size_override(&"font_size", 13)
	button.add_theme_stylebox_override(&"normal", WorldSelectionTheme.quiet_button())
	button.pressed.connect(callback)
	parent.add_child(button)


@private
func _build_creation_overlay() -> void:
	_creation_overlay = Control.new()
	_creation_overlay.name = "CreationOverlay"
	_creation_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_creation_overlay.visible = false
	add_child(_creation_overlay)
	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(0.0, 0.008, 0.015, 0.78)
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	_creation_overlay.add_child(veil)
	_creation_panel = PanelContainer.new()
	_creation_panel.name = "CreateTraveler"
	_creation_panel.set_anchors_preset(Control.PRESET_CENTER)
	_creation_panel.position = Vector2(-300.0, -150.0)
	_creation_panel.size = Vector2(600.0, 300.0)
	_creation_panel.add_theme_stylebox_override(&"panel", WorldSelectionTheme.glass_panel())
	_creation_overlay.add_child(_creation_panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 18)
	_creation_panel.add_child(column)
	var heading := Label.new()
	heading.text = "WHO CROSSES THE FALLING STAR?"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override(&"font_size", 22)
	column.add_child(heading)
	var note := Label.new()
	note.text = "Name a traveler. Their world, choices, and relationships will remain their own."
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_color_override(&"font_color", Color(0.79, 0.83, 0.88, 0.72))
	column.add_child(note)
	_name_edit = LineEdit.new()
	_name_edit.name = "TravelerName"
	_name_edit.placeholder_text = "Traveler name"
	_name_edit.max_length = 24
	_name_edit.text_submitted.connect(func(_text: String) -> void: _create_world())
	column.add_child(_name_edit)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 12)
	column.add_child(row)
	var cancel := Button.new()
	cancel.name = "CancelCreationButton"
	cancel.text = "NOT YET"
	cancel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cancel.pressed.connect(_hide_creation)
	row.add_child(cancel)
	var create := Button.new()
	create.name = "CreateButton"
	create.text = "BEGIN JOURNEY"
	create.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	create.pressed.connect(_create_world)
	row.add_child(create)


@private
func _refresh_worlds() -> void:
	for child: Node in _world_list.get_children():
		child.queue_free()
	_first_world_button = null
	var index := WorldLibrary.list_worlds()
	_empty_hint.visible = index.worlds.is_empty()
	for summary: LumenfallWorldSummary in index.worlds:
		if not is_instance_valid(summary):
			continue
		_add_world_row(summary)
	if not is_instance_valid(_first_world_button):
		_show_creation.call_deferred()
	else:
		_first_world_button.grab_focus.call_deferred()


@private
func _add_world_row(summary: LumenfallWorldSummary) -> void:
	var entry := WorldEntryButton.new()
	entry.name = "Load_%s" % summary.world_id
	entry.configure(summary, "%s PLAYED" % _format_time(summary.played_seconds))
	entry.pressed.connect(_load_world.bind(summary.world_id))
	_world_list.add_child(entry)
	if not is_instance_valid(_first_world_button):
		_first_world_button = entry


@private
func _show_creation() -> void:
	_creation_overlay.visible = true
	_name_edit.text = ""
	_name_edit.grab_focus.call_deferred()


@private
func _hide_creation() -> void:
	_creation_overlay.visible = false
	if is_instance_valid(_first_world_button):
		_first_world_button.grab_focus.call_deferred()
	else:
		_new_traveler_button.grab_focus.call_deferred()


@private
func _create_world() -> void:
	var state := WorldLibrary.create_world(_name_edit.text)
	world_selected.emit(state)


@private
func _load_world(world_id: String) -> void:
	var state := WorldLibrary.load_world(world_id)
	if is_instance_valid(state):
		world_selected.emit(state)


@private
func _open_settings() -> void:
	if is_instance_valid(_settings_panel):
		return
	_settings_panel = SettingsPanel.new()
	_settings_panel.name = "SettingsPanel"
	_settings_panel.configure(SettingsRepository.load_settings(), null)
	_settings_panel.closed.connect(_on_settings_closed)
	add_child(_settings_panel)


@private
func _on_settings_closed() -> void:
	_settings_panel = null


@private
func _quit() -> void:
	get_tree().quit()


@private
func _animate_entrance() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, ^"modulate:a", 1.0, 0.42)


@private
func _format_time(seconds: float) -> String:
	var whole_minutes := floori(seconds / 60.0)
	if whole_minutes < 60:
		return "%dm" % whole_minutes
	return "%dh %02dm" % [floori(float(whole_minutes) / 60.0), whole_minutes % 60]
