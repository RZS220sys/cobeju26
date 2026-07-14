class_name AdventureHud
extends CanvasLayer

var _objective_panel: PanelContainer
var _objective_label: Label
var _interaction_panel: PanelContainer
var _interaction_label: Label
var _dialogue_panel: PanelContainer
var _speaker_label: Label
var _dialogue_label: Label
var _dialogue_timer: float = 0.0
var _health_bar: ProgressBar
var _health_label: Label
var _lens_badge: PanelContainer
var _navigation_panel: PanelContainer
var _navigation_label: Label


@override
func _ready() -> void:
	layer = 20
	_build_interface()


@private
func _build_interface() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = LumenfallUiTheme.create()
	add_child(root)
	_objective_panel = PanelContainer.new()
	_objective_panel.name = "ObjectiveRibbon"
	_objective_panel.position = Vector2(28.0, 26.0)
	_objective_panel.custom_minimum_size = Vector2(470.0, 84.0)
	_objective_panel.add_theme_stylebox_override(&"panel", LumenfallUiTheme.panel())
	root.add_child(_objective_panel)
	_objective_label = Label.new()
	_objective_label.text = "✦  Find your footing"
	_objective_label.add_theme_font_size_override(&"font_size", 18)
	_objective_label.add_theme_color_override(&"font_color", Color("ffe09a"))
	_objective_panel.add_child(_objective_label)
	_interaction_panel = PanelContainer.new()
	_interaction_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_interaction_panel.position = Vector2(-245.0, -120.0)
	_interaction_panel.size = Vector2(490.0, 72.0)
	_interaction_panel.add_theme_stylebox_override(&"panel", LumenfallUiTheme.panel())
	_interaction_panel.visible = false
	root.add_child(_interaction_panel)
	_interaction_label = Label.new()
	_interaction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_interaction_panel.add_child(_interaction_label)
	_dialogue_panel = PanelContainer.new()
	_dialogue_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_dialogue_panel.position = Vector2(-500.0, -240.0)
	_dialogue_panel.size = Vector2(1000.0, 122.0)
	_dialogue_panel.add_theme_stylebox_override(&"panel", LumenfallUiTheme.panel())
	_dialogue_panel.visible = false
	root.add_child(_dialogue_panel)
	var dialogue_row := HBoxContainer.new()
	dialogue_row.add_theme_constant_override(&"separation", 18)
	_dialogue_panel.add_child(dialogue_row)
	_speaker_label = Label.new()
	_speaker_label.custom_minimum_size.x = 150.0
	_speaker_label.add_theme_font_size_override(&"font_size", 20)
	_speaker_label.add_theme_color_override(&"font_color", Color("ffd36b"))
	dialogue_row.add_child(_speaker_label)
	_dialogue_label = Label.new()
	_dialogue_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_label.add_theme_font_size_override(&"font_size", 21)
	dialogue_row.add_child(_dialogue_label)
	var status := PanelContainer.new()
	status.position = Vector2(28.0, 122.0)
	status.custom_minimum_size = Vector2(330.0, 96.0)
	status.add_theme_stylebox_override(&"panel", LumenfallUiTheme.panel())
	root.add_child(status)
	var status_column := VBoxContainer.new()
	status_column.add_theme_constant_override(&"separation", 5)
	status.add_child(status_column)
	_health_label = Label.new()
	_health_label.text = "VITALITY  100 / 100"
	_health_label.add_theme_font_size_override(&"font_size", 14)
	status_column.add_child(_health_label)
	_health_bar = ProgressBar.new()
	_health_bar.name = "VitalityBar"
	_health_bar.show_percentage = false
	_health_bar.custom_minimum_size.y = 15.0
	_health_bar.add_theme_stylebox_override(&"background", LumenfallUiTheme.meter_background())
	_health_bar.add_theme_stylebox_override(&"fill", LumenfallUiTheme.meter_fill())
	status_column.add_child(_health_bar)
	_lens_badge = PanelContainer.new()
	_lens_badge.position = Vector2(28.0, 232.0)
	_lens_badge.custom_minimum_size = Vector2(220.0, 62.0)
	_lens_badge.add_theme_stylebox_override(&"panel", LumenfallUiTheme.card())
	_lens_badge.visible = false
	root.add_child(_lens_badge)
	var lens_label := Label.new()
	lens_label.text = "◇  LANTERN LENS"
	lens_label.add_theme_font_size_override(&"font_size", 14)
	lens_label.add_theme_color_override(&"font_color", Color("72e8ff"))
	_lens_badge.add_child(lens_label)
	_navigation_panel = PanelContainer.new()
	_navigation_panel.name = "NavigationRibbon"
	_navigation_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_navigation_panel.position = Vector2(-270.0, 22.0)
	_navigation_panel.size = Vector2(540.0, 74.0)
	_navigation_panel.add_theme_stylebox_override(&"panel", LumenfallUiTheme.panel())
	_navigation_panel.visible = false
	root.add_child(_navigation_panel)
	_navigation_label = Label.new()
	_navigation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_navigation_label.add_theme_font_size_override(&"font_size", 16)
	_navigation_label.add_theme_color_override(&"font_color", Color("d6edda"))
	_navigation_panel.add_child(_navigation_label)


@override
func _process(delta: float) -> void:
	if _dialogue_timer > 0.0:
		_dialogue_timer -= delta
		if _dialogue_timer <= 0.0:
			_dialogue_panel.visible = false


func set_objective(objective_text: String) -> void:
	_objective_label.text = "✦  %s" % objective_text


func set_interaction(prompt: String) -> void:
	_interaction_panel.visible = not prompt.is_empty()
	_interaction_label.text = "E  •  %s" % prompt


func show_dialogue(speaker: String, line: String, duration: float = 4.0) -> void:
	_speaker_label.text = speaker.to_upper()
	_dialogue_label.text = line
	_dialogue_timer = duration
	_dialogue_panel.visible = true


func set_health(current: float, maximum: float) -> void:
	if not is_instance_valid(_health_bar):
		return
	_health_bar.max_value = maximum
	_health_bar.value = current
	_health_label.text = "VITALITY  %d / %d" % [ceili(current), ceili(maximum)]


func set_lens_owned(owned: bool) -> void:
	if is_instance_valid(_lens_badge):
		_lens_badge.visible = owned


func set_navigation(direction_glyph: String, target_name: String, distance: float) -> void:
	if not is_instance_valid(_navigation_panel):
		return
	_navigation_panel.visible = not target_name.is_empty()
	_navigation_label.text = "%s   %s   •   %dm" % [direction_glyph, target_name, roundi(distance)]
