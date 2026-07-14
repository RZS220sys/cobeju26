class_name CrossingChoice
extends CanvasLayer

signal choice_made(choice_id: CrossingChoiceCatalog.Id)


@override
func _ready() -> void:
	layer = 60
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(0.01, 0.02, 0.045, 0.95)
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	veil.theme = LumenfallUiTheme.create()
	add_child(veil)
	var frame := PanelContainer.new()
	frame.set_anchors_preset(Control.PRESET_CENTER)
	frame.position = Vector2(-650.0, -315.0)
	frame.size = Vector2(1300.0, 630.0)
	frame.add_theme_stylebox_override(&"panel", LumenfallUiTheme.panel())
	veil.add_child(frame)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 18)
	frame.add_child(column)
	var title := Label.new()
	title.text = "THE ROAD ASKS WHAT IT MAY BECOME"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override(&"font_size", 30)
	title.add_theme_color_override(&"font_color", Color("d8c7ff"))
	column.add_child(title)
	var choices := HBoxContainer.new()
	choices.size_flags_vertical = Control.SIZE_EXPAND_FILL
	choices.add_theme_constant_override(&"separation", 14)
	column.add_child(choices)
	_add_choice(choices, CrossingChoiceCatalog.Id.SHELTER, "SHELTER", "Close the road for now. Hearthmere is safer, but the forgotten remain unreachable.", Color("70d0ef"))
	_add_choice(choices, CrossingChoiceCatalog.Id.BRIDGE, "BRIDGE", "Bind the road to three living names. Travel stays possible, and those people carry its cost.", Color("e7b75c"))
	_add_choice(choices, CrossingChoiceCatalog.Id.WITNESS, "WITNESS", "Cross without owning or closing it. Learn who erased the road before deciding its fate.", Color("c884e4"))
	var warning := Label.new()
	warning.text = "This choice changes later relationships and events. It does not delete exploration or lock the save."
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning.add_theme_color_override(&"font_color", Color("adc9bb"))
	column.add_child(warning)


@private
func _add_choice(parent: HBoxContainer, choice_id: CrossingChoiceCatalog.Id, heading: String, copy: String, color: Color) -> void:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override(&"panel", LumenfallUiTheme.card())
	parent.add_child(card)
	var content := VBoxContainer.new()
	content.add_theme_constant_override(&"separation", 15)
	card.add_child(content)
	var title := Label.new()
	title.text = heading
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override(&"font_size", 25)
	title.add_theme_color_override(&"font_color", color)
	content.add_child(title)
	var description := Label.new()
	description.text = copy
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(description)
	var choose := Button.new()
	choose.text = "CHOOSE %s" % heading
	choose.custom_minimum_size.y = 60.0
	choose.pressed.connect(make_choice.bind(choice_id))
	content.add_child(choose)


func make_choice(choice_id: CrossingChoiceCatalog.Id) -> void:
	choice_made.emit(choice_id)
	queue_free()
