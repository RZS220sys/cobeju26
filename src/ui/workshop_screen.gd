class_name WorkshopScreen
extends Control

signal back_requested

var _profile: PalimpsestSaveData
var _fragments_label: Label
var _upgrade_column: VBoxContainer


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
	panel.position = Vector2(-530.0, -365.0)
	panel.size = Vector2(1060.0, 730.0)
	panel.add_theme_stylebox_override(&"panel", ArchivePalette.panel_style(Color(0.018, 0.06, 0.09, 0.96), Color(0.68, 0.54, 0.3, 0.65), 14, 1))
	add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 16)
	panel.add_child(column)
	var title := Label.new()
	title.text = "THE LANTERN WORKSHOP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override(&"font_size", 38)
	title.add_theme_color_override(&"font_color", ArchivePalette.amber())
	column.add_child(title)
	var intro := Label.new()
	intro.text = "Archive fragments are memories too damaged to read, but not too damaged to become useful.\nPermanent fittings apply to every future descent. Maximum rank: 5."
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.add_theme_font_size_override(&"font_size", 17)
	column.add_child(intro)
	_fragments_label = Label.new()
	_fragments_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_fragments_label.add_theme_font_size_override(&"font_size", 22)
	_fragments_label.add_theme_color_override(&"font_color", ArchivePalette.cyan())
	column.add_child(_fragments_label)
	_upgrade_column = VBoxContainer.new()
	_upgrade_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_upgrade_column.add_theme_constant_override(&"separation", 12)
	column.add_child(_upgrade_column)
	var back := Button.new()
	back.name = "BackButton"
	back.text = "RETURN TO THE ARCHIVE"
	back.custom_minimum_size.y = 54.0
	back.pressed.connect(_return)
	column.add_child(back)
	_refresh()
	back.grab_focus.call_deferred()


@private
func _refresh() -> void:
	_fragments_label.text = "%d ARCHIVE FRAGMENTS AVAILABLE" % _profile.archive_fragments
	for child: Node in _upgrade_column.get_children():
		child.queue_free()
	_add_upgrade(&"wick", "REINFORCED WICK HOUSING", "+6 maximum health per rank", _profile.wick_rank)
	_add_upgrade(&"lens", "FACETED BRASS LENS", "+2 pulse damage per rank", _profile.lens_rank)
	_add_upgrade(&"reservoir", "DEEP RESONANCE RESERVOIR", "+6 maximum focus per rank", _profile.reservoir_rank)


@private
func _add_upgrade(upgrade_id: StringName, title_text: String, description: String, rank: int) -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override(&"panel", ArchivePalette.panel_style(Color(0.025, 0.085, 0.115, 0.95), Color(0.31, 0.53, 0.54, 0.55), 9, 1))
	_upgrade_column.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 16)
	panel.add_child(row)
	var label := Label.new()
	label.text = "%s\n%s\nRANK %d / 5" % [title_text, description, rank]
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override(&"font_size", 17)
	row.add_child(label)
	var button := Button.new()
	button.name = "%sUpgrade" % String(upgrade_id).capitalize()
	var cost := _upgrade_cost(rank)
	button.text = "MAXIMUM" if rank >= 5 else "FIT PART\n%d FRAGMENTS" % cost
	button.custom_minimum_size = Vector2(220.0, 72.0)
	button.disabled = rank >= 5 or _profile.archive_fragments < cost
	button.pressed.connect(_purchase.bind(upgrade_id, rank))
	row.add_child(button)


@private
func _upgrade_cost(rank: int) -> int:
	return 6 + rank * 5


@private
func _purchase(upgrade_id: StringName, current_rank: int) -> void:
	if current_rank >= 5:
		return
	var cost := _upgrade_cost(current_rank)
	if _profile.archive_fragments < cost:
		return
	_profile.archive_fragments -= cost
	match upgrade_id:
		&"wick": _profile.wick_rank += 1
		&"lens": _profile.lens_rank += 1
		&"reservoir": _profile.reservoir_rank += 1
	ArchiveSaveManager.save_profile(_profile)
	_refresh()


@private
func _return() -> void:
	ArchiveSaveManager.save_profile(_profile)
	back_requested.emit()
