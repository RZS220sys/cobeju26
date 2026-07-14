class_name WorldSelectionScreen
extends Control

enum WorldAction {
	NONE,
	RESET,
	DELETE,
}

signal world_selected(state: LumenfallWorldState)

const BACKGROUND_PATH := "res://assets/ui/title_screen/listening_stone_background.png"

var _world_list: VBoxContainer
var _world_buttons: Dictionary[String, Button] = {}
var _traveler_button_group: ButtonGroup
var _continue_button: Button
var _creation_overlay: Control
var _creation_panel: PanelContainer
var _name_edit: LineEdit
var _empty_hint: Label
var _confirm_dialog: ConfirmationDialog
var _settings_panel: SettingsPanel
var _selected_world_id: String = ""
var _pending_world_id: String = ""
var _pending_action: WorldAction = WorldAction.NONE


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
	_confirm_dialog = ConfirmationDialog.new()
	_confirm_dialog.name = "WorldActionConfirmation"
	_confirm_dialog.title = "CONFIRM"
	_confirm_dialog.min_size = Vector2i(560, 240)
	_confirm_dialog.confirmed.connect(_confirm_world_action)
	add_child(_confirm_dialog)


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
	menu.position = Vector2(-500.0, -430.0)
	menu.size = Vector2(450.0, 380.0)
	menu.add_theme_constant_override(&"separation", 10)
	add_child(menu)
	_empty_hint = Label.new()
	_empty_hint.text = "NO TRAVELER HAS CROSSED YET"
	_empty_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_hint.add_theme_font_size_override(&"font_size", 13)
	_empty_hint.add_theme_color_override(&"font_color", Color(0.8, 0.84, 0.89, 0.62))
	menu.add_child(_empty_hint)
	var scroll := ScrollContainer.new()
	scroll.name = "TravelerScroll"
	scroll.custom_minimum_size.y = 118.0
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	menu.add_child(scroll)
	_world_list = VBoxContainer.new()
	_world_list.name = "TravelerList"
	_world_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_world_list.add_theme_constant_override(&"separation", 8)
	scroll.add_child(_world_list)
	_continue_button = Button.new()
	_continue_button.name = "ContinueButton"
	_continue_button.text = "CONTINUE"
	_continue_button.custom_minimum_size.y = 54.0
	_continue_button.disabled = true
	_continue_button.pressed.connect(_continue_selected)
	menu.add_child(_continue_button)
	var new_button := Button.new()
	new_button.name = "NewTravelerButton"
	new_button.text = "NEW JOURNEY"
	new_button.custom_minimum_size.y = 48.0
	new_button.pressed.connect(_show_creation)
	menu.add_child(new_button)
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
	_world_buttons.clear()
	_selected_world_id = ""
	_continue_button.disabled = true
	_traveler_button_group = ButtonGroup.new()
	_traveler_button_group.allow_unpress = false
	var index := WorldLibrary.list_worlds()
	_empty_hint.visible = index.worlds.is_empty()
	var first_world_id := ""
	for summary: LumenfallWorldSummary in index.worlds:
		if not is_instance_valid(summary):
			continue
		if first_world_id.is_empty():
			first_world_id = summary.world_id
		_add_world_row(summary)
	if first_world_id.is_empty():
		_show_creation.call_deferred()
	else:
		_select_world(first_world_id)
		_continue_button.grab_focus.call_deferred()


@private
func _add_world_row(summary: LumenfallWorldSummary) -> void:
	var row := HBoxContainer.new()
	row.name = "Traveler_%s" % summary.world_id
	row.add_theme_constant_override(&"separation", 6)
	_world_list.add_child(row)
	var select_button := Button.new()
	select_button.name = "Load_%s" % summary.world_id
	select_button.text = "%s\nCHAPTER %d  ·  %s PLAYED" % [summary.display_name.to_upper(), summary.quest_stage + 1, _format_time(summary.played_seconds).to_upper()]
	select_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	select_button.toggle_mode = true
	select_button.button_group = _traveler_button_group
	select_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	select_button.custom_minimum_size.y = 68.0
	select_button.add_theme_font_size_override(&"font_size", 15)
	select_button.add_theme_stylebox_override(&"normal", WorldSelectionTheme.traveler_row())
	select_button.add_theme_stylebox_override(&"hover", WorldSelectionTheme.traveler_row(true))
	select_button.add_theme_stylebox_override(&"pressed", WorldSelectionTheme.traveler_row(true))
	select_button.add_theme_stylebox_override(&"focus", WorldSelectionTheme.focus_outline())
	select_button.pressed.connect(_select_world.bind(summary.world_id))
	row.add_child(select_button)
	_world_buttons[summary.world_id] = select_button
	var reset_button := Button.new()
	reset_button.name = "Reset_%s" % summary.world_id
	reset_button.text = "↺"
	reset_button.tooltip_text = "Begin this traveler again"
	reset_button.custom_minimum_size = Vector2(42.0, 68.0)
	reset_button.add_theme_stylebox_override(&"normal", WorldSelectionTheme.quiet_button())
	reset_button.pressed.connect(_reset_world.bind(summary.world_id))
	row.add_child(reset_button)
	var delete_button := Button.new()
	delete_button.name = "Delete_%s" % summary.world_id
	delete_button.text = "×"
	delete_button.tooltip_text = "Remove this traveler"
	delete_button.custom_minimum_size = Vector2(42.0, 68.0)
	delete_button.add_theme_stylebox_override(&"normal", WorldSelectionTheme.quiet_button())
	delete_button.pressed.connect(_delete_world.bind(summary.world_id))
	row.add_child(delete_button)


@private
func _select_world(world_id: String) -> void:
	if not _world_buttons.has(world_id):
		return
	_selected_world_id = world_id
	_continue_button.disabled = false
	var selected_button := _world_buttons[world_id]
	selected_button.button_pressed = true


@private
func _continue_selected() -> void:
	if _selected_world_id.is_empty():
		return
	_load_world(_selected_world_id)


@private
func _show_creation() -> void:
	_creation_overlay.visible = true
	_name_edit.text = ""
	_name_edit.grab_focus.call_deferred()


@private
func _hide_creation() -> void:
	_creation_overlay.visible = false
	_continue_button.grab_focus.call_deferred()


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
func _reset_world(world_id: String) -> void:
	_pending_world_id = world_id
	_pending_action = WorldAction.RESET
	_confirm_dialog.dialog_text = "Begin this traveler's story again? Their progress, belongings, and choices will be replaced."
	_confirm_dialog.ok_button_text = "BEGIN AGAIN"
	_confirm_dialog.popup_centered()


@private
func _delete_world(world_id: String) -> void:
	_pending_world_id = world_id
	_pending_action = WorldAction.DELETE
	_confirm_dialog.dialog_text = "Remove this traveler and their world? This cannot be undone."
	_confirm_dialog.ok_button_text = "REMOVE TRAVELER"
	_confirm_dialog.popup_centered()


@private
func _confirm_world_action() -> void:
	if _pending_world_id.is_empty():
		return
	if _pending_action == WorldAction.RESET:
		WorldLibrary.reset_world(_pending_world_id)
	elif _pending_action == WorldAction.DELETE:
		WorldLibrary.delete_world(_pending_world_id)
	_pending_world_id = ""
	_pending_action = WorldAction.NONE
	_refresh_worlds()


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
