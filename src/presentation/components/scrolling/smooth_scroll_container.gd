class_name SmoothScrollContainer
extends ScrollContainer

@export_range(24.0, 240.0, 1.0) var wheel_step: float = 92.0
@export_range(4.0, 30.0, 0.5) var response: float = 14.0
@export_range(0.0, 1.0, 0.01) var inertia: float = 0.22
@export_range(0.0, 32.0, 1.0) var drag_deadzone: float = 8.0
@export var mouse_drag_enabled: bool = true
@export var touch_drag_enabled: bool = true

var _target_scroll: float = 0.0
var _dragging: bool = false
var _drag_moved: bool = false
var _drag_distance: float = 0.0
var _drag_velocity: float = 0.0
var _pressed_control: Control
var _pressed_mouse_filter: Control.MouseFilter = Control.MOUSE_FILTER_STOP


@override
func _ready() -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	follow_focus = false
	mouse_filter = Control.MOUSE_FILTER_PASS
	_target_scroll = float(scroll_vertical)
	_apply_pass_filter(self)
	get_tree().node_added.connect(_on_node_added)
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	set_process(false)


@override
func _process(delta: float) -> void:
	if _dragging:
		return
	_target_scroll = clampf(_target_scroll, 0.0, _maximum_scroll())
	var difference := _target_scroll - float(scroll_vertical)
	if absf(difference) <= 0.5:
		scroll_vertical = roundi(_target_scroll)
		set_process(false)
		return
	var blend := 1.0 - exp(-response * delta)
	scroll_vertical = roundi(lerpf(float(scroll_vertical), _target_scroll, blend))


@override
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event as InputEventMouseButton)
	elif event is InputEventMouseMotion and mouse_drag_enabled:
		_handle_drag_motion((event as InputEventMouseMotion).relative.y)
	elif event is InputEventScreenTouch and touch_drag_enabled:
		_handle_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag and touch_drag_enabled:
		_handle_drag_motion((event as InputEventScreenDrag).relative.y)
	elif event is InputEventPanGesture:
		var gesture := event as InputEventPanGesture
		_scroll_by(gesture.delta.y * wheel_step)
		accept_event()


func scroll_to(control: Control) -> void:
	if not is_instance_valid(control) or not is_ancestor_of(control):
		return
	var viewport_rect := get_global_rect()
	var control_rect := control.get_global_rect()
	if control_rect.position.y < viewport_rect.position.y:
		_scroll_by(control_rect.position.y - viewport_rect.position.y)
	elif control_rect.end.y > viewport_rect.end.y:
		_scroll_by(control_rect.end.y - viewport_rect.end.y)


@private
func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		_scroll_by(-wheel_step * event.factor)
		accept_event()
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
		_scroll_by(wheel_step * event.factor)
		accept_event()
	elif event.button_index == MOUSE_BUTTON_LEFT and mouse_drag_enabled:
		if event.pressed:
			_begin_drag()
		else:
			_end_drag()


@private
func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_begin_drag()
	else:
		_end_drag()


@private
func _begin_drag() -> void:
	_dragging = true
	_drag_moved = false
	_drag_distance = 0.0
	_drag_velocity = 0.0
	_pressed_control = get_viewport().gui_get_hovered_control()


@private
func _handle_drag_motion(relative_y: float) -> void:
	if not _dragging or is_zero_approx(_maximum_scroll()):
		return
	_drag_distance += absf(relative_y)
	if not _drag_moved and _drag_distance < drag_deadzone:
		return
	if not _drag_moved:
		_drag_moved = true
		_suppress_pressed_control()
	var next_scroll := clampf(float(scroll_vertical) - relative_y, 0.0, _maximum_scroll())
	scroll_vertical = roundi(next_scroll)
	_target_scroll = next_scroll
	_drag_velocity = lerpf(_drag_velocity, -relative_y * 60.0, 0.34)
	accept_event()


@private
func _end_drag() -> void:
	if not _dragging:
		return
	_dragging = false
	if _drag_moved:
		_target_scroll = clampf(float(scroll_vertical) + _drag_velocity * inertia, 0.0, _maximum_scroll())
		set_process(true)
		accept_event()
	_restore_pressed_control.call_deferred()


@private
func _scroll_by(amount: float) -> void:
	_target_scroll = clampf(maxf(_target_scroll, float(scroll_vertical)) + amount, 0.0, _maximum_scroll()) if amount > 0.0 else clampf(minf(_target_scroll, float(scroll_vertical)) + amount, 0.0, _maximum_scroll())
	set_process(true)


@private
func _maximum_scroll() -> float:
	var bar := get_v_scroll_bar()
	return maxf(0.0, bar.max_value - bar.page)


@private
func _suppress_pressed_control() -> void:
	if not is_instance_valid(_pressed_control) or not _pressed_control is BaseButton:
		return
	_pressed_mouse_filter = _pressed_control.mouse_filter
	_pressed_control.mouse_filter = Control.MOUSE_FILTER_IGNORE


@private
func _restore_pressed_control() -> void:
	if is_instance_valid(_pressed_control):
		_pressed_control.mouse_filter = _pressed_mouse_filter
	_pressed_control = null


@private
func _on_focus_changed(control: Control) -> void:
	if is_instance_valid(control) and is_ancestor_of(control):
		scroll_to.call_deferred(control)


@private
func _on_node_added(node: Node) -> void:
	if node is Control and is_ancestor_of(node):
		_apply_pass_filter(node)


@private
func _apply_pass_filter(node: Node) -> void:
	if node is Control and node != self:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_PASS
	for child: Node in node.get_children():
		_apply_pass_filter(child)
