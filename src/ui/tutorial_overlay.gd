class_name TutorialOverlay
extends CanvasLayer

signal dismissed


@override
func _ready() -> void:
	layer = 45
	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(0.008, 0.028, 0.043, 0.95)
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	veil.theme = ArchivePalette.build_ui_theme()
	add_child(veil)
	var column := VBoxContainer.new()
	column.set_anchors_preset(Control.PRESET_CENTER)
	column.position = Vector2(-570.0, -350.0)
	column.size = Vector2(1140.0, 700.0)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override(&"separation", 17)
	veil.add_child(column)
	var eyebrow := Label.new()
	eyebrow.text = "LAMPLIGHTER ORIENTATION // READ ONCE"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_color_override(&"font_color", ArchivePalette.cyan())
	column.add_child(eyebrow)
	var title := Label.new()
	title.text = "CARRY THE NINTH LANTERN"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override(&"font_size", 42)
	title.add_theme_color_override(&"font_color", ArchivePalette.amber())
	column.add_child(title)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 14)
	column.add_child(row)
	_add_lesson(row, "MOVE", "WASD / LEFT STICK", "The camera follows the lantern. The brass rim marks the safe edge of each memory island.", ArchivePalette.cyan())
	_add_lesson(row, "CAST", "J / LMB / RB", "Pulses aim toward the mouse. Keyboard and controller casts gently seek the nearest Hollow.", ArchivePalette.amber())
	_add_lesson(row, "SLIP", "SPACE / A", "Move while slipping to cross danger without harm. The technique needs a brief moment to recover.", ArchivePalette.bone())
	_add_lesson(row, "RESONATE", "Q / B", "Spend cyan focus to disperse and push every Hollow nearby. Focus returns over time.", ArchivePalette.magenta())
	var mandate := Label.new()
	mandate.text = "RECOVER 7 CYAN ECHOES  →  CHOOSE 2 ANNOTATIONS  →  DISPERSE THE INDEX WARDEN  →  ENTER THE SEAL"
	mandate.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mandate.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mandate.add_theme_font_size_override(&"font_size", 18)
	mandate.add_theme_color_override(&"font_color", ArchivePalette.bone())
	column.add_child(mandate)
	var reassurance := Label.new()
	reassurance.text = "Every defeat keeps recovered fragments. Tide intensity can be changed without losing story access. Escape pauses safely."
	reassurance.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reassurance.add_theme_font_size_override(&"font_size", 15)
	reassurance.add_theme_color_override(&"font_color", Color(0.65, 0.74, 0.76, 0.9))
	column.add_child(reassurance)
	var start := Button.new()
	start.name = "DescendButton"
	start.text = "UNCOVER THE LANTERN"
	start.custom_minimum_size = Vector2(410.0, 58.0)
	start.pressed.connect(func() -> void: dismissed.emit())
	column.add_child(start)
	start.grab_focus.call_deferred()


@private
func _add_lesson(parent: HBoxContainer, heading: String, control: String, body: String, color: Color) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(268.0, 220.0)
	panel.add_theme_stylebox_override(&"panel", ArchivePalette.panel_style(Color(0.02, 0.07, 0.1, 0.95), color.darkened(0.2), 10, 1))
	parent.add_child(panel)
	var label := Label.new()
	label.text = "%s\n%s\n\n%s" % [heading, control, body]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override(&"font_size", 16)
	label.add_theme_color_override(&"font_color", color.lightened(0.12))
	panel.add_child(label)
