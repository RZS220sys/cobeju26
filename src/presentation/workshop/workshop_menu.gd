class_name WorkshopMenu
extends CanvasLayer

signal crafted_lantern_lens
signal crafted_memory_compass
signal closed

var world_state: GameWorldState
var _material_label: Label
var _craft_button: Button
var _status_label: Label
var _recipe_name: Label
var _description: Label
var _showing_compass: bool = false


func configure(state_value: GameWorldState) -> void:
	world_state = state_value


@override
func _ready() -> void:
	layer = 50
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_build_interface()


@private
func _build_interface() -> void:
	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.color = Color(0.015, 0.045, 0.04, 0.9)
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(veil)
	var frame := PanelContainer.new()
	frame.set_anchors_preset(Control.PRESET_CENTER)
	frame.position = Vector2(-420.0, -285.0)
	frame.size = Vector2(840.0, 570.0)
	frame.theme = GameUiTheme.create()
	frame.add_theme_stylebox_override(&"panel", GameUiTheme.panel())
	veil.add_child(frame)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 16)
	frame.add_child(column)
	var heading := Label.new()
	heading.text = "BRAM'S LANTERN BENCH"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override(&"font_size", 30)
	heading.add_theme_color_override(&"font_color", Color("ffd477"))
	column.add_child(heading)
	var explanation := Label.new()
	explanation.text = "Riftglass is memory made solid when a sky-rift touches the earth. It is a crafting material—not money. Gold pays people; riftglass changes tools."
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explanation.add_theme_font_size_override(&"font_size", 19)
	explanation.add_theme_color_override(&"font_color", Color("cae7d2"))
	column.add_child(explanation)
	var recipe := PanelContainer.new()
	recipe.size_flags_vertical = Control.SIZE_EXPAND_FILL
	recipe.add_theme_stylebox_override(&"panel", GameUiTheme.card())
	column.add_child(recipe)
	var recipe_column := VBoxContainer.new()
	recipe_column.add_theme_constant_override(&"separation", 12)
	recipe.add_child(recipe_column)
	_recipe_name = Label.new()
	_recipe_name.text = "◇  LANTERN LENS"
	_recipe_name.add_theme_font_size_override(&"font_size", 26)
	_recipe_name.add_theme_color_override(&"font_color", Color("73e8ff"))
	recipe_column.add_child(_recipe_name)
	_description = Label.new()
	_description.text = "Reveals the safe seams around unstable rifts. Mara will not lead anyone beyond the lantern road without one."
	_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	recipe_column.add_child(_description)
	_material_label = Label.new()
	_material_label.add_theme_font_size_override(&"font_size", 21)
	recipe_column.add_child(_material_label)
	_status_label = Label.new()
	_status_label.add_theme_color_override(&"font_color", Color("ffd477"))
	recipe_column.add_child(_status_label)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override(&"separation", 12)
	column.add_child(buttons)
	var leave := Button.new()
	leave.text = "LEAVE BENCH"
	leave.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	leave.pressed.connect(close_workshop)
	buttons.add_child(leave)
	_craft_button = Button.new()
	_craft_button.name = "CraftLanternLens"
	_craft_button.text = "FORGE LANTERN LENS"
	_craft_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_craft_button.pressed.connect(_craft_selected)
	buttons.add_child(_craft_button)
	_refresh()


@override
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		close_workshop()


@private
func _refresh() -> void:
	_showing_compass = Inventory.has_recipe(world_state, RecipeCatalog.Id.MEMORY_COMPASS) and Inventory.count(world_state, ItemCatalog.Id.MEMORY_COMPASS) == 0
	if _showing_compass:
		_refresh_compass()
		return
	var pieces := Inventory.count(world_state, ItemCatalog.Id.RIFTGLASS)
	_recipe_name.text = "◇  LANTERN LENS"
	_description.text = "Reveals the safe seams around unstable rifts. Mara will not lead anyone beyond the lantern road without one."
	_craft_button.text = "FORGE LANTERN LENS"
	_material_label.text = "Riftglass pieces: %d / 3" % pieces
	if Inventory.count(world_state, ItemCatalog.Id.LANTERN_LENS) > 0:
		_status_label.text = "This traveler already carries a Lantern Lens."
		_craft_button.disabled = true
	else:
		_status_label.text = "The shards will be fused, not spent as currency."
		_craft_button.disabled = pieces < 3


@private
func _refresh_compass() -> void:
	var threads := Inventory.count(world_state, ItemCatalog.Id.MEMORY_THREAD)
	_recipe_name.text = "◇  MEMORY COMPASS"
	_description.text = "Braids the three rescued villagers' memory-threads. Points toward places deliberately removed from maps and minds."
	_material_label.text = "Returned memory-threads: %d / 3" % threads
	_status_label.text = "No thread is consumed as fuel; the compass keeps all three names woven inside it."
	_craft_button.text = "BRAID MEMORY COMPASS"
	_craft_button.disabled = threads < 3


@private
func _craft_selected() -> void:
	if _showing_compass:
		craft_memory_compass()
	else:
		craft_lantern_lens()


func craft_lantern_lens() -> void:
	if not Inventory.remove(world_state, ItemCatalog.Id.RIFTGLASS, 3):
		_refresh()
		return
	Inventory.add(world_state, ItemCatalog.Id.LANTERN_LENS)
	Inventory.unlock_recipe(world_state, RecipeCatalog.Id.LANTERN_LENS)
	_status_label.text = "Forged. The lens warms when it faces a safe path."
	_craft_button.disabled = true
	crafted_lantern_lens.emit()


func craft_memory_compass() -> void:
	if not Inventory.remove(world_state, ItemCatalog.Id.MEMORY_THREAD, 3):
		_refresh()
		return
	Inventory.add(world_state, ItemCatalog.Id.MEMORY_COMPASS)
	_status_label.text = "Braided. Three names circle a needle that refuses north."
	_craft_button.disabled = true
	crafted_memory_compass.emit()


func close_workshop() -> void:
	closed.emit()
	queue_free()
