class_name WorldSelectionScreen
extends Control

enum WorldAction {
	NONE,
	RESET,
	DELETE,
}

signal world_selected(state: LumenfallWorldState)

var _world_list: VBoxContainer
var _creation_panel: PanelContainer
var _name_edit: LineEdit
var _empty_hint: Label
var _confirm_dialog: ConfirmationDialog
var _pending_world_id: String = ""
var _pending_action: WorldAction = WorldAction.NONE


@override
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = LumenfallUiTheme.create()
	_build_interface()
	_refresh_worlds()


@private
func _build_interface() -> void:
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("0a201b")
	add_child(background)
	var sun := Polygon2D.new()
	sun.polygon = PackedVector2Array([Vector2(0, 0), Vector2(360, 0), Vector2(360, 360), Vector2(0, 360)])
	sun.position = Vector2(80, 80)
	sun.color = Color(0.94, 0.58, 0.19, 0.18)
	background.add_child(sun)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override(&"margin_left", 70)
	margin.add_theme_constant_override(&"margin_right", 70)
	margin.add_theme_constant_override(&"margin_top", 55)
	margin.add_theme_constant_override(&"margin_bottom", 50)
	add_child(margin)
	var layout := HBoxContainer.new()
	layout.add_theme_constant_override(&"separation", 42)
	margin.add_child(layout)
	var identity := VBoxContainer.new()
	identity.custom_minimum_size.x = 540.0
	identity.alignment = BoxContainer.ALIGNMENT_CENTER
	identity.add_theme_constant_override(&"separation", 14)
	layout.add_child(identity)
	var mark := Label.new()
	mark.text = "✦  ◇  ✦"
	mark.add_theme_font_size_override(&"font_size", 42)
	mark.add_theme_color_override(&"font_color", Color("edbd5e"))
	identity.add_child(mark)
	var title := Label.new()
	title.text = "LUMENFALL"
	title.add_theme_font_size_override(&"font_size", 65)
	title.add_theme_color_override(&"font_color", Color("ffd477"))
	identity.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "THE FIRST CROSSING"
	subtitle.add_theme_font_size_override(&"font_size", 23)
	subtitle.add_theme_color_override(&"font_color", Color("b7dbc2"))
	identity.add_child(subtitle)
	var pitch := Label.new()
	pitch.text = "Choose a traveler. Each journey keeps its own world, choices, and friendships."
	pitch.custom_minimum_size.x = 500.0
	pitch.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pitch.add_theme_font_size_override(&"font_size", 18)
	pitch.add_theme_color_override(&"font_color", Color("dfd2ae"))
	identity.add_child(pitch)

	var book := PanelContainer.new()
	book.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	book.add_theme_stylebox_override(&"panel", LumenfallUiTheme.panel())
	layout.add_child(book)
	var book_column := VBoxContainer.new()
	book_column.add_theme_constant_override(&"separation", 14)
	book.add_child(book_column)
	var book_title := Label.new()
	book_title.text = "TRAVELER BOOK"
	book_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	book_title.add_theme_font_size_override(&"font_size", 30)
	book_title.add_theme_color_override(&"font_color", Color("ffd477"))
	book_column.add_child(book_title)
	_empty_hint = Label.new()
	_empty_hint.text = "No traveler has crossed yet. Name the first."
	_empty_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_hint.add_theme_color_override(&"font_color", Color("c6b98e"))
	book_column.add_child(_empty_hint)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	book_column.add_child(scroll)
	_world_list = VBoxContainer.new()
	_world_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_world_list.add_theme_constant_override(&"separation", 10)
	scroll.add_child(_world_list)
	var new_button := Button.new()
	new_button.name = "NewTravelerButton"
	new_button.text = "✦  NAME A NEW TRAVELER"
	new_button.custom_minimum_size.y = 58.0
	new_button.pressed.connect(_show_creation)
	book_column.add_child(new_button)
	_creation_panel = _build_creation_panel()
	add_child(_creation_panel)
	_confirm_dialog = ConfirmationDialog.new()
	_confirm_dialog.title = "TRAVELER BOOK"
	_confirm_dialog.min_size = Vector2i(560, 240)
	_confirm_dialog.confirmed.connect(_confirm_world_action)
	add_child(_confirm_dialog)


@private
func _build_creation_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = "CreateTraveler"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-310.0, -160.0)
	panel.size = Vector2(620.0, 320.0)
	panel.add_theme_stylebox_override(&"panel", LumenfallUiTheme.panel())
	panel.visible = false
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 18)
	panel.add_child(column)
	var heading := Label.new()
	heading.text = "WHO CROSSES THE FALLING STAR?"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override(&"font_size", 25)
	column.add_child(heading)
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
	cancel.text = "NOT YET"
	cancel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cancel.pressed.connect(func() -> void: _creation_panel.visible = false)
	row.add_child(cancel)
	var create := Button.new()
	create.name = "CreateButton"
	create.text = "BEGIN JOURNEY  ✦"
	create.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	create.pressed.connect(_create_world)
	row.add_child(create)
	return panel


@private
func _refresh_worlds() -> void:
	for child: Node in _world_list.get_children():
		child.queue_free()
	var index := WorldLibrary.list_worlds()
	_empty_hint.visible = index.worlds.is_empty()
	for summary: LumenfallWorldSummary in index.worlds:
		if is_instance_valid(summary):
			_add_world_card(summary)
	if index.worlds.is_empty():
		_show_creation.call_deferred()


@private
func _add_world_card(summary: LumenfallWorldSummary) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 8)
	_world_list.add_child(row)
	var load_button := Button.new()
	load_button.name = "Load_%s" % summary.world_id
	load_button.text = "◇  %s\nChapter %d  •  %s played" % [summary.display_name, summary.quest_stage + 1, _format_time(summary.played_seconds)]
	load_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	load_button.custom_minimum_size.y = 76.0
	load_button.pressed.connect(_load_world.bind(summary.world_id))
	row.add_child(load_button)
	var reset_button := Button.new()
	reset_button.text = "↺"
	reset_button.tooltip_text = "Start this traveler over"
	reset_button.custom_minimum_size.x = 55.0
	reset_button.pressed.connect(_reset_world.bind(summary.world_id))
	row.add_child(reset_button)
	var delete_button := Button.new()
	delete_button.text = "✕"
	delete_button.tooltip_text = "Delete this traveler"
	delete_button.custom_minimum_size.x = 55.0
	delete_button.pressed.connect(_delete_world.bind(summary.world_id))
	row.add_child(delete_button)


@private
func _show_creation() -> void:
	_creation_panel.visible = true
	_name_edit.text = ""
	_name_edit.grab_focus.call_deferred()


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
	_confirm_dialog.dialog_text = "Begin this traveler's story again? Their world progress, belongings, and choices will be replaced."
	_confirm_dialog.ok_button_text = "BEGIN AGAIN"
	_confirm_dialog.popup_centered()


@private
func _delete_world(world_id: String) -> void:
	_pending_world_id = world_id
	_pending_action = WorldAction.DELETE
	_confirm_dialog.dialog_text = "Remove this traveler from the book? This cannot be undone."
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
func _format_time(seconds: float) -> String:
	var whole_minutes := floori(seconds / 60.0)
	if whole_minutes < 60:
		return "%dm" % whole_minutes
	return "%dh %02dm" % [floori(float(whole_minutes) / 60.0), whole_minutes % 60]
