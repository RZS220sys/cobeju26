class_name PauseOverlay
extends CanvasLayer

signal resume_requested
signal abandon_requested


@override
func _ready() -> void:
	layer = 50
	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(0.01, 0.03, 0.045, 0.9)
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	veil.theme = ArchivePalette.build_ui_theme()
	add_child(veil)
	var column := VBoxContainer.new()
	column.set_anchors_preset(Control.PRESET_CENTER)
	column.position = Vector2(-300.0, -210.0)
	column.size = Vector2(600.0, 420.0)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override(&"separation", 18)
	veil.add_child(column)
	var eyebrow := Label.new()
	eyebrow.text = "THE TIDE WAITS"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_color_override(&"font_color", ArchivePalette.cyan())
	column.add_child(eyebrow)
	var title := Label.new()
	title.text = "LANTERN COVERED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override(&"font_size", 40)
	title.add_theme_color_override(&"font_color", ArchivePalette.amber())
	column.add_child(title)
	var note := Label.new()
	note.text = "Nothing beneath the water moves while the flame is covered."
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_font_size_override(&"font_size", 17)
	column.add_child(note)
	var resume := Button.new()
	resume.name = "ResumeButton"
	resume.text = "UNCOVER LANTERN"
	resume.custom_minimum_size = Vector2(390.0, 55.0)
	resume.pressed.connect(func() -> void: resume_requested.emit())
	column.add_child(resume)
	resume.grab_focus.call_deferred()
	var abandon := Button.new()
	abandon.name = "AbandonButton"
	abandon.text = "RETURN TO SURFACE — KEEP RECOVERED FRAGMENTS"
	abandon.custom_minimum_size = Vector2(490.0, 50.0)
	abandon.pressed.connect(func() -> void: abandon_requested.emit())
	column.add_child(abandon)
