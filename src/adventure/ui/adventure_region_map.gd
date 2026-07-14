class_name AdventureRegionMap
extends CanvasLayer

signal region_selected(region_id: StringName)
signal closed

var profile: LumenfallSaveData


func configure(profile_value: LumenfallSaveData) -> void:
	profile = profile_value


@override
func _ready() -> void:
	layer = 50
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_build_interface()


@private
func _build_interface() -> void:
	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(0.015, 0.04, 0.035, 0.93)
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(veil)
	var frame := PanelContainer.new()
	frame.set_anchors_preset(Control.PRESET_CENTER)
	frame.position = Vector2(-650.0, -330.0)
	frame.size = Vector2(1300.0, 660.0)
	frame.theme = LumenfallUiTheme.create()
	frame.add_theme_stylebox_override(&"panel", LumenfallUiTheme.panel())
	veil.add_child(frame)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 16)
	frame.add_child(column)
	var title := Label.new()
	title.text = "MARA'S FIELD MAP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override(&"font_size", 32)
	title.add_theme_color_override(&"font_color", Color("ffd477"))
	column.add_child(title)
	var lead := Label.new()
	lead.text = "The answering rift touched three old instruments. Choose which trail to walk next; discoveries remain marked for this traveler."
	lead.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lead.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lead.add_theme_color_override(&"font_color", Color("c6dfce"))
	column.add_child(lead)
	var regions := HBoxContainer.new()
	regions.size_flags_vertical = Control.SIZE_EXPAND_FILL
	regions.add_theme_constant_override(&"separation", 14)
	column.add_child(regions)
	_add_region_card(regions, &"glasswood", "NORTH  •  GLASSWOOD", "A crystal shrine is repeating Aster's name in voices from several decades.", "glasswood_resonance", Color("72ddff"))
	_add_region_card(regions, &"amberfen", "EAST  •  AMBERFEN", "An abandoned sky-orrery has begun tracking something beneath the horizon.", "amber_orbit", Color("f0b35b"))
	_add_region_card(regions, &"bellscar", "SOUTH  •  BELLSCAR", "The great warning bell casts a moving shadow, though the bell itself is still.", "bellscar_echo", Color("e17d78"))
	var close_button := Button.new()
	close_button.text = "FOLD THE MAP"
	close_button.custom_minimum_size.y = 54.0
	close_button.pressed.connect(close_map)
	column.add_child(close_button)


@private
func _add_region_card(parent: HBoxContainer, region_id: StringName, heading: String, description: String, discovery_item: String, color: Color) -> void:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override(&"panel", LumenfallUiTheme.card())
	parent.add_child(card)
	var content := VBoxContainer.new()
	content.add_theme_constant_override(&"separation", 15)
	card.add_child(content)
	var region_heading := Label.new()
	region_heading.text = heading
	region_heading.add_theme_font_size_override(&"font_size", 23)
	region_heading.add_theme_color_override(&"font_color", color)
	content.add_child(region_heading)
	var copy := Label.new()
	copy.text = description
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.size_flags_vertical = Control.SIZE_EXPAND_FILL
	copy.add_theme_font_size_override(&"font_size", 18)
	content.add_child(copy)
	var completed := AdventureInventory.count(profile, discovery_item) > 0
	var choose := Button.new()
	choose.name = "Choose_%s" % region_id
	choose.text = "DISCOVERED  ✓" if completed else "FOLLOW THIS LEAD"
	choose.disabled = completed
	choose.custom_minimum_size.y = 58.0
	choose.pressed.connect(choose_region.bind(region_id))
	content.add_child(choose)


@override
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		close_map()


func choose_region(region_id: StringName) -> void:
	region_selected.emit(region_id)
	closed.emit()
	queue_free()


func close_map() -> void:
	closed.emit()
	queue_free()
