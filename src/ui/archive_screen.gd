class_name ArchiveScreen
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
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override(&"margin_left", 56)
	margin.add_theme_constant_override(&"margin_right", 56)
	margin.add_theme_constant_override(&"margin_top", 38)
	margin.add_theme_constant_override(&"margin_bottom", 38)
	add_child(margin)
	var root_column := VBoxContainer.new()
	root_column.add_theme_constant_override(&"separation", 18)
	margin.add_child(root_column)
	var header := HBoxContainer.new()
	root_column.add_child(header)
	var title := Label.new()
	title.text = "THE SURFACE ARCHIVE"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override(&"font_size", 38)
	title.add_theme_color_override(&"font_color", ArchivePalette.amber())
	header.add_child(title)
	var back := Button.new()
	back.name = "BackButton"
	back.text = "RETURN"
	back.custom_minimum_size = Vector2(190.0, 48.0)
	back.pressed.connect(func() -> void: back_requested.emit())
	header.add_child(back)
	back.grab_focus.call_deferred()

	var content := HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override(&"separation", 22)
	root_column.add_child(content)
	var summary := PanelContainer.new()
	summary.custom_minimum_size.x = 355.0
	summary.add_theme_stylebox_override(&"panel", ArchivePalette.panel_style(Color(0.02, 0.07, 0.1, 0.93), Color(0.35, 0.61, 0.62, 0.45), 12, 1))
	content.add_child(summary)
	var summary_column := VBoxContainer.new()
	summary_column.add_theme_constant_override(&"separation", 12)
	summary.add_child(summary_column)
	_add_summary(summary_column, "ARCHIVE DEPTH", str(_profile.story_depth), ArchivePalette.amber())
	_add_summary(summary_column, "SUCCESSFUL DESCENTS", "%d / %d" % [_profile.successful_expeditions, _profile.expeditions], ArchivePalette.cyan())
	_add_summary(summary_column, "ECHOES WITNESSED", str(_profile.total_echoes), ArchivePalette.bone())
	_add_summary(summary_column, "HOLLOWS DISPERSED", str(_profile.total_hollows), ArchivePalette.bone())
	_add_summary(summary_column, "FRAGMENTS", str(_profile.archive_fragments), ArchivePalette.brass())
	_add_summary(summary_column, "ENDINGS WITNESSED", "%d / 3" % _profile.endings_seen.size(), ArchivePalette.magenta())
	var divider := HSeparator.new()
	summary_column.add_child(divider)
	var vectors := Label.new()
	vectors.text = "CURATOR VECTORS\n\nWITNESS      %d\nMERCY          %d\nCONTINUANCE  %d" % [_profile.witness_affinity, _profile.mercy_affinity, _profile.continuance_affinity]
	vectors.add_theme_font_size_override(&"font_size", 17)
	vectors.add_theme_color_override(&"font_color", ArchivePalette.bone().darkened(0.06))
	summary_column.add_child(vectors)
	var note := Label.new()
	note.text = "These are not morality scores. They are the kinds of truth you have made easier for the Archive to imagine."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override(&"font_size", 14)
	note.add_theme_color_override(&"font_color", Color(0.62, 0.72, 0.74, 0.9))
	summary_column.add_child(note)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)
	var records_column := VBoxContainer.new()
	records_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	records_column.add_theme_constant_override(&"separation", 12)
	scroll.add_child(records_column)
	for record: LoreRecord in LoreCatalog.all_records():
		_add_record(records_column, record, record.record_id in _profile.discovered_records or record.title in _profile.discovered_records)


@private
func _add_summary(parent: VBoxContainer, label_text: String, value_text: String, color: Color) -> void:
	var label := Label.new()
	label.text = "%s\n%s" % [label_text, value_text]
	label.add_theme_font_size_override(&"font_size", 18)
	label.add_theme_color_override(&"font_color", color)
	parent.add_child(label)


@private
func _add_record(parent: VBoxContainer, record: LoreRecord, discovered: bool) -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override(&"panel", ArchivePalette.panel_style(Color(0.02, 0.065, 0.095, 0.94), Color(0.28, 0.48, 0.51, 0.45), 9, 1))
	parent.add_child(panel)
	var text := Label.new()
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.add_theme_font_size_override(&"font_size", 16)
	if discovered:
		text.text = "%s\n%s\n\n%s" % [record.title.to_upper(), record.excerpt, record.body]
		text.add_theme_color_override(&"font_color", ArchivePalette.bone())
	else:
		text.text = "UNRECOVERED ECHO // DEPTH %d\nThe water has not surrendered this memory." % record.depth
		text.add_theme_color_override(&"font_color", Color(0.39, 0.49, 0.51, 0.75))
	panel.add_child(text)
