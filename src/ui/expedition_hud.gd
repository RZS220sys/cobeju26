class_name ExpeditionHud
extends CanvasLayer

signal return_requested

var _health_bar: ProgressBar
var _focus_bar: ProgressBar
var _objective_label: Label
var _time_label: Label
var _toast_panel: PanelContainer
var _toast_title: Label
var _toast_body: Label
var _toast_timer: float = 0.0
var _end_overlay: Control


@override
func _ready() -> void:
	layer = 20
	_build_interface()


@private
func _build_interface() -> void:
	var root := Control.new()
	root.name = "HudRoot"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = ArchivePalette.build_ui_theme()
	add_child(root)

	var top_margin := MarginContainer.new()
	top_margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_margin.offset_bottom = 96.0
	top_margin.add_theme_constant_override(&"margin_left", 28)
	top_margin.add_theme_constant_override(&"margin_right", 28)
	top_margin.add_theme_constant_override(&"margin_top", 22)
	root.add_child(top_margin)
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override(&"separation", 18)
	top_margin.add_child(top_row)

	var vitals := VBoxContainer.new()
	vitals.custom_minimum_size.x = 280.0
	vitals.add_theme_constant_override(&"separation", 7)
	top_row.add_child(vitals)
	_health_bar = _make_bar(ArchivePalette.danger(), "LANTERN BODY")
	vitals.add_child(_health_bar)
	_focus_bar = _make_bar(ArchivePalette.cyan(), "RESONANCE")
	vitals.add_child(_focus_bar)

	_objective_label = Label.new()
	_objective_label.text = "ECHOES  0 / 7"
	_objective_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_objective_label.add_theme_font_size_override(&"font_size", 20)
	_objective_label.add_theme_color_override(&"font_color", ArchivePalette.amber())
	top_row.add_child(_objective_label)

	_time_label = Label.new()
	_time_label.text = "TIDE  00:00"
	_time_label.custom_minimum_size.x = 220.0
	_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_time_label.add_theme_font_size_override(&"font_size", 18)
	top_row.add_child(_time_label)

	var controls := Label.new()
	controls.text = "J / LMB  CAST     SPACE  SLIP     Q  RESONATE"
	controls.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	controls.position = Vector2(28.0, -48.0)
	controls.add_theme_font_size_override(&"font_size", 13)
	controls.add_theme_color_override(&"font_color", Color(0.7, 0.78, 0.79, 0.78))
	root.add_child(controls)

	_toast_panel = PanelContainer.new()
	_toast_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_toast_panel.position = Vector2(-500.0, -182.0)
	_toast_panel.size = Vector2(468.0, 124.0)
	_toast_panel.add_theme_stylebox_override(&"panel", ArchivePalette.panel_style(Color(0.02, 0.075, 0.11, 0.95), Color(0.39, 0.82, 0.8, 0.65), 10, 1))
	_toast_panel.modulate.a = 0.0
	root.add_child(_toast_panel)
	var toast_column := VBoxContainer.new()
	toast_column.add_theme_constant_override(&"separation", 5)
	_toast_panel.add_child(toast_column)
	_toast_title = Label.new()
	_toast_title.add_theme_color_override(&"font_color", ArchivePalette.cyan())
	_toast_title.add_theme_font_size_override(&"font_size", 15)
	toast_column.add_child(_toast_title)
	_toast_body = Label.new()
	_toast_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_toast_body.add_theme_font_size_override(&"font_size", 16)
	toast_column.add_child(_toast_body)

	var reticle := Label.new()
	reticle.text = "·"
	reticle.set_anchors_preset(Control.PRESET_CENTER)
	reticle.position = Vector2(-3.0, -12.0)
	reticle.add_theme_font_size_override(&"font_size", 28)
	reticle.add_theme_color_override(&"font_color", Color(1.0, 0.8, 0.4, 0.7))
	root.add_child(reticle)

	_end_overlay = _build_end_overlay(root)


@private
func _make_bar(fill_color: Color, label_text: String) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.name = label_text.capitalize().replace(" ", "")
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.value = 100.0
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(280.0, 18.0)
	bar.add_theme_stylebox_override(&"background", ArchivePalette.panel_style(Color(0.015, 0.04, 0.06, 0.92), Color(0.2, 0.33, 0.36, 0.8), 4, 1))
	bar.add_theme_stylebox_override(&"fill", ArchivePalette.panel_style(fill_color.darkened(0.18), fill_color, 4, 1))
	bar.tooltip_text = label_text
	return bar


@private
func _build_end_overlay(root: Control) -> Control:
	var overlay := ColorRect.new()
	overlay.name = "EndOverlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.015, 0.035, 0.055, 0.93)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.visible = false
	root.add_child(overlay)
	var center := VBoxContainer.new()
	center.name = "ResultPanel"
	center.set_anchors_preset(Control.PRESET_CENTER)
	center.position = Vector2(-285.0, -170.0)
	center.size = Vector2(570.0, 340.0)
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override(&"separation", 15)
	overlay.add_child(center)
	var heading := Label.new()
	heading.name = "Heading"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override(&"font_size", 42)
	heading.add_theme_color_override(&"font_color", ArchivePalette.amber())
	center.add_child(heading)
	var body := Label.new()
	body.name = "Body"
	body.custom_minimum_size = Vector2(570.0, 120.0)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override(&"font_size", 19)
	center.add_child(body)
	var button := Button.new()
	button.name = "ReturnButton"
	button.text = "RETURN TO THE SURFACE"
	button.custom_minimum_size = Vector2(360.0, 56.0)
	button.pressed.connect(func() -> void: return_requested.emit())
	center.add_child(button)
	return overlay


@override
func _process(delta: float) -> void:
	if _toast_timer > 0.0:
		_toast_timer -= delta
		if _toast_timer <= 0.0:
			var tween := create_tween()
			tween.tween_property(_toast_panel, "modulate:a", 0.0, 0.35)


func bind_player(player: ArchivistController) -> void:
	player.health_changed.connect(_on_health_changed)
	player.focus_changed.connect(_on_focus_changed)
	_on_health_changed(player.health, player.max_health)
	_on_focus_changed(player.focus, player.max_focus)


func set_objective(current: int, required: int, gate_ready: bool = false) -> void:
	_objective_label.text = "DESCENT OPEN — ENTER THE CYAN SEAL" if gate_ready else "ECHOES  %d / %d" % [current, required]
	_objective_label.add_theme_color_override(&"font_color", ArchivePalette.cyan() if gate_ready else ArchivePalette.amber())


func set_mandate(mandate: String, color: Color) -> void:
	_objective_label.text = mandate
	_objective_label.add_theme_color_override(&"font_color", color)


func set_elapsed(seconds: float) -> void:
	var whole_seconds := floori(seconds)
	_time_label.text = "TIDE  %02d:%02d" % [floori(float(whole_seconds) / 60.0), whole_seconds % 60]


func show_toast(title_text: String, body_text: String, duration: float = 4.5) -> void:
	_toast_title.text = title_text.to_upper()
	_toast_body.text = body_text
	_toast_timer = duration
	var tween := create_tween()
	tween.tween_property(_toast_panel, "modulate:a", 1.0, 0.22)


func show_result(victory: bool, echoes: int, kills: int, elapsed: float) -> void:
	_end_overlay.visible = true
	var heading := _end_overlay.get_node("ResultPanel/Heading") as Label
	var body := _end_overlay.get_node("ResultPanel/Body") as Label
	if not is_instance_valid(heading) or not is_instance_valid(body):
		return
	heading.text = "THE LANTERN RETURNS" if victory else "THE TIDE CLOSES"
	heading.add_theme_color_override(&"font_color", ArchivePalette.amber() if victory else ArchivePalette.magenta())
	body.text = ("You carried %d living memories back through the seal.\n%d Hollows dispersed • %02d:%02d beneath the water\n\nThe Archive has learned the shape of your attention." if victory else "The lantern went dark, but memory is stubborn.\n%d echoes touched • %d Hollows dispersed • %02d:%02d survived") % [echoes, kills, floori(elapsed / 60.0), floori(elapsed) % 60]
	var button := _end_overlay.get_node("ResultPanel/ReturnButton") as Button
	if is_instance_valid(button):
		button.grab_focus.call_deferred()


@private
func _on_health_changed(current: float, maximum: float) -> void:
	_health_bar.max_value = maximum
	_health_bar.value = current


@private
func _on_focus_changed(current: float, maximum: float) -> void:
	_focus_bar.max_value = maximum
	_focus_bar.value = current
