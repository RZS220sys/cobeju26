class_name BoonChoiceOverlay
extends CanvasLayer

signal boon_selected(boon_id: StringName)

var _choices: Array[StringName] = []
var _chosen: bool = false


func configure(choice_ids: Array[StringName]) -> void:
	_choices = choice_ids


@override
func _ready() -> void:
	layer = 40
	_build_interface()


@private
func _build_interface() -> void:
	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(0.01, 0.03, 0.05, 0.91)
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	veil.theme = ArchivePalette.build_ui_theme()
	add_child(veil)
	var layout := VBoxContainer.new()
	layout.set_anchors_preset(Control.PRESET_CENTER)
	layout.position = Vector2(-610.0, -260.0)
	layout.size = Vector2(1220.0, 520.0)
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override(&"separation", 18)
	veil.add_child(layout)
	var eyebrow := Label.new()
	eyebrow.text = "THE LANTERN REMEMBERS A NEW SHAPE"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_color_override(&"font_color", ArchivePalette.cyan())
	eyebrow.add_theme_font_size_override(&"font_size", 15)
	layout.add_child(eyebrow)
	var heading := Label.new()
	heading.text = "CHOOSE AN ANNOTATION"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_color_override(&"font_color", ArchivePalette.amber())
	heading.add_theme_font_size_override(&"font_size", 38)
	layout.add_child(heading)
	var prompt := Label.new()
	prompt.text = "Each recovered echo can rewrite the bearer. The other possibilities will sink with this tide."
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override(&"font_size", 17)
	layout.add_child(prompt)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 18)
	layout.add_child(row)
	for index: int in range(_choices.size()):
		_add_boon_button(row, _choices[index], index == 0)


@private
func _add_boon_button(row: HBoxContainer, boon_id: StringName, focus_first: bool) -> void:
	var info := BoonCatalog.definition(boon_id)
	var button := Button.new()
	button.name = "%sBoon" % info.title.capitalize().replace(" ", "")
	button.text = "%s\n\n%s\n\n“%s”" % [info.title, info.description, info.flavor]
	button.custom_minimum_size = Vector2(380.0, 250.0)
	button.add_theme_font_size_override(&"font_size", 16)
	button.add_theme_stylebox_override(&"hover", ArchivePalette.panel_style(info.color.darkened(0.25), info.color, 12, 2))
	button.pressed.connect(_choose.bind(boon_id))
	row.add_child(button)
	if focus_first:
		button.grab_focus.call_deferred()


@private
func _choose(boon_id: StringName) -> void:
	if _chosen:
		return
	_chosen = true
	boon_selected.emit(boon_id)
