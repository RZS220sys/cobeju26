class_name EndingScreen
extends Control

signal continue_requested

var _ending_path: StringName


func configure(path: StringName) -> void:
	_ending_path = path


@override
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = ArchivePalette.build_ui_theme()
	var backdrop := ArchiveBackdrop.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = _ending_color()
	veil.color.a = 0.34
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)
	var column := VBoxContainer.new()
	column.set_anchors_preset(Control.PRESET_CENTER)
	column.position = Vector2(-520.0, -350.0)
	column.size = Vector2(1040.0, 700.0)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override(&"separation", 21)
	add_child(column)
	var eyebrow := Label.new()
	eyebrow.text = "AN ENDING // AND A NEW TIDE"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_color_override(&"font_color", ArchivePalette.bone())
	column.add_child(eyebrow)
	var title := Label.new()
	title.text = _ending_title()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override(&"font_size", 48)
	title.add_theme_color_override(&"font_color", _ending_color())
	column.add_child(title)
	var body := Label.new()
	body.text = _ending_body()
	body.custom_minimum_size = Vector2(900.0, 300.0)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override(&"font_size", 21)
	column.add_child(body)
	var coda := Label.new()
	coda.text = "Other verdicts remain possible. The Archive remembers this ending without making it the only one."
	coda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coda.add_theme_font_size_override(&"font_size", 15)
	coda.add_theme_color_override(&"font_color", Color(0.67, 0.75, 0.76, 0.9))
	column.add_child(coda)
	var button := Button.new()
	button.name = "ContinueButton"
	button.text = "WAKE ON THE SURFACE"
	button.custom_minimum_size = Vector2(390.0, 58.0)
	button.pressed.connect(func() -> void: continue_requested.emit())
	column.add_child(button)
	button.grab_focus.call_deferred()


@private
func _ending_color() -> Color:
	match _ending_path:
		&"witness": return ArchivePalette.cyan()
		&"mercy": return ArchivePalette.amber()
	return ArchivePalette.magenta()


@private
func _ending_title() -> String:
	match _ending_path:
		&"witness": return "THE SEA BECOMES GLASS"
		&"mercy": return "THE SEA LEARNS TO EMPTY"
	return "THE GOLD CITY, IMPERFECT"


@private
func _ending_body() -> String:
	match _ending_path:
		&"witness":
			return "You open every sealed record. The pressure beneath the Archive becomes visible all at once: grief, guilt, ordinary tenderness. The sea hardens into clear glass—not healed, not hidden.\n\nFuture Lamplighters walk above the drowned streets and see exactly what holds them up. Some call this cruelty. None can call it ignorance."
		&"mercy":
			return "You give every memory the right to end. Names rise through the water like breath and vanish without being replaced. The city becomes lighter than its history.\n\nThe Archive closes its final file, then asks your name. You tell it. It does not store the answer. For the first time, forgetting is a gift freely given."
	return "You refuse the choice between fact and oblivion. The Archive becomes a workshop where memories declare their edits and contradictions remain visible in gold.\n\nThe rebuilt city is not innocent. Children learn regret without inheriting guilt. Each generation redraws the streets—and leaves one deliberate blank for a future it cannot own."
