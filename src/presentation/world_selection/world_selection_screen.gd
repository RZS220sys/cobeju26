class_name WorldSelectionScreen
extends Control

signal world_selected(state: GameWorldState)

const BACKGROUND_PATH := "res://assets/ui/title_screen/listening_stone_background.png"
const MENU_LEFT_RATIO := 0.64
const MENU_TOP_RATIO := 0.48
const MENU_RIGHT_RATIO := 0.97
const MENU_BOTTOM_RATIO := 0.94
const WORLD_LIST_WIDTH_RATIO := 0.9
const WORLD_LIST_RAISE_RATIO := 0.1
const MENU_BUTTON_WIDTH_RATIO := 0.4
const WORLD_ENTRY_HEIGHT_RATIO := 0.18
const MENU_BUTTON_HEIGHT_RATIO := 0.1
const MENU_GAP_RATIO := 0.023
const WORLD_ENTRY_GAP_RATIO := 0.01

var _world_list: VBoxContainer
var _first_world_button: WorldEntryButton
var _new_traveler_button: Button
var _settings_button: Button
var _quit_button: Button
var _traveler_menu: Control
var _traveler_scroll: SmoothScrollContainer
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
	_spawn_purple_dots()
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
func _spawn_purple_dots() -> void:
	var particles := PurpleDotParticles.new()
	add_child(particles)


@private
func _build_identity() -> void:
	var identity := VBoxContainer.new()
	identity.name = "Identity"
	identity.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	identity.anchor_left = 0.035
	identity.anchor_top = 0.05
	identity.anchor_right = 0.35
	identity.anchor_bottom = 0.2
	identity.add_theme_constant_override(&"separation", 8)
	add_child(identity)
	var title := Label.new()
	title.text = "LUMENFALL"
	title.add_theme_font_size_override(&"font_size", 42)
	title.add_theme_color_override(&"font_color", Color(0.94, 0.96, 0.98, 0.96))
	identity.add_child(title)
	var rule := ColorRect.new()
	rule.custom_minimum_size.y = 1.0
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	_traveler_menu = Control.new()
	_traveler_menu.name = "TravelerMenu"
	_traveler_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_traveler_menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_traveler_menu.resized.connect(_resize_traveler_layout)
	add_child(_traveler_menu)
	var menu_width := MENU_RIGHT_RATIO - MENU_LEFT_RATIO
	var menu_height := MENU_BOTTOM_RATIO - MENU_TOP_RATIO
	var menu_center := (MENU_LEFT_RATIO + MENU_RIGHT_RATIO) * 0.5
	var list_half_width := menu_width * WORLD_LIST_WIDTH_RATIO * 0.5
	var button_half_width := menu_width * MENU_BUTTON_WIDTH_RATIO * 0.5
	var button_height := menu_height * MENU_BUTTON_HEIGHT_RATIO
	var button_gap := menu_height * MENU_GAP_RATIO
	var quit_bottom := MENU_BOTTOM_RATIO
	var quit_top := quit_bottom - button_height
	var settings_bottom := quit_top - button_gap
	var settings_top := settings_bottom - button_height
	var new_bottom := settings_top - button_gap
	var new_top := new_bottom - button_height
	var list_bottom := new_top - button_gap
	_traveler_scroll = SmoothScrollContainer.new()
	_traveler_scroll.name = "TravelerScroll"
	_traveler_scroll.anchor_left = menu_center - list_half_width
	_traveler_scroll.anchor_top = MENU_TOP_RATIO - WORLD_LIST_RAISE_RATIO
	_traveler_scroll.anchor_right = menu_center + list_half_width
	_traveler_scroll.anchor_bottom = list_bottom
	_traveler_scroll.response = 15.0
	_traveler_menu.add_child(_traveler_scroll)
	_world_list = VBoxContainer.new()
	_world_list.name = "TravelerList"
	_world_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_traveler_scroll.add_child(_world_list)
	_empty_hint = Label.new()
	_empty_hint.text = "NO TRAVELER HAS CROSSED YET"
	_empty_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_empty_hint.anchor_left = menu_center - list_half_width
	_empty_hint.anchor_top = MENU_TOP_RATIO - WORLD_LIST_RAISE_RATIO
	_empty_hint.anchor_right = menu_center + list_half_width
	_empty_hint.anchor_bottom = list_bottom
	_empty_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_empty_hint.add_theme_font_size_override(&"font_size", 13)
	_empty_hint.add_theme_color_override(&"font_color", Color(0.8, 0.84, 0.89, 0.62))
	_traveler_menu.add_child(_empty_hint)
	_new_traveler_button = _add_menu_button("NewTravelerButton", "NEW JOURNEY", _show_creation, menu_center - button_half_width, new_top, menu_center + button_half_width, new_bottom)
	_settings_button = _add_menu_button("SettingsButton", "SETTINGS", _open_settings, menu_center - button_half_width, settings_top, menu_center + button_half_width, settings_bottom)
	_quit_button = _add_menu_button("QuitButton", "QUIT", _quit, menu_center - button_half_width, quit_top, menu_center + button_half_width, quit_bottom)
	_resize_traveler_layout.call_deferred()


@private
func _add_menu_button(node_name: String, text_value: String, callback: Callable, left_ratio: float, top_ratio: float, right_ratio: float, bottom_ratio: float) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = text_value
	button.anchor_left = left_ratio
	button.anchor_top = top_ratio
	button.anchor_right = right_ratio
	button.anchor_bottom = bottom_ratio
	button.add_theme_font_size_override(&"font_size", 15)
	button.add_theme_stylebox_override(&"normal", WorldSelectionTheme.menu_action(Color(0.0, 0.0, 0.0, 0.0), Color(0.82, 0.87, 0.92, 0.22)))
	button.add_theme_stylebox_override(&"hover", WorldSelectionTheme.menu_action(Color(0.04, 0.05, 0.08, 0.4), Color(0.82, 0.72, 1.0, 0.72)))
	button.add_theme_stylebox_override(&"pressed", WorldSelectionTheme.menu_action(Color(0.08, 0.06, 0.12, 0.5), Color(0.82, 0.72, 1.0, 0.92)))
	button.pressed.connect(callback)
	_traveler_menu.add_child(button)
	return button


@private
func _resize_traveler_layout() -> void:
	if not is_instance_valid(_traveler_menu) or not is_instance_valid(_traveler_scroll):
		return
	var menu_height := MENU_BOTTOM_RATIO - MENU_TOP_RATIO
	var entry_height := _traveler_menu.size.y * menu_height * WORLD_ENTRY_HEIGHT_RATIO
	_world_list.add_theme_constant_override(&"separation", maxi(2, roundi(_traveler_menu.size.y * WORLD_ENTRY_GAP_RATIO)))
	_traveler_scroll.wheel_step = entry_height * 1.05
	for child: Node in _world_list.get_children():
		if child is WorldEntryButton:
			(child as WorldEntryButton).custom_minimum_size.y = entry_height


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
	_creation_panel.anchor_left = 0.34
	_creation_panel.anchor_top = 0.3
	_creation_panel.anchor_right = 0.66
	_creation_panel.anchor_bottom = 0.7
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
	for summary: GameWorldSummary in index.worlds:
		if not is_instance_valid(summary):
			continue
		_add_world_row(summary)
	if not is_instance_valid(_first_world_button):
		_show_creation.call_deferred()
	else:
		_first_world_button.grab_focus.call_deferred()


@private
func _add_world_row(summary: GameWorldSummary) -> void:
	var entry := WorldEntryButton.new()
	entry.name = "Load_%s" % summary.world_id
	entry.configure(summary, "LAST PLAYED %s" % RelativeTimeFormatter.format_since(summary.last_played_unix))
	entry.pressed.connect(_load_world.bind(summary.world_id))
	_world_list.add_child(entry)
	entry.custom_minimum_size.y = _traveler_menu.size.y * (MENU_BOTTOM_RATIO - MENU_TOP_RATIO) * WORLD_ENTRY_HEIGHT_RATIO
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
