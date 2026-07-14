class_name LumenfallApp
extends Node


@override
func _ready() -> void:
	_configure_input()
	var director := GameDirector.new()
	director.name = "GameDirector"
	add_child(director)


@private
func _configure_input() -> void:
	_add_key_action(&"move_forward", KEY_W)
	_add_key_action(&"move_back", KEY_S)
	_add_key_action(&"move_left", KEY_A)
	_add_key_action(&"move_right", KEY_D)
	_add_key_action(&"attack", KEY_J)
	_add_key_action(&"dash", KEY_SPACE)
	_add_key_action(&"resonance", KEY_Q)
	_add_key_action(&"interact", KEY_E)
	_add_key_action(&"pause_game", KEY_ESCAPE)
	_add_key_action(&"jump", KEY_SPACE)
	_add_key_action(&"sprint", KEY_SHIFT)
	_add_joy_axis(&"move_left", JOY_AXIS_LEFT_X, -1.0)
	_add_joy_axis(&"move_right", JOY_AXIS_LEFT_X, 1.0)
	_add_joy_axis(&"move_forward", JOY_AXIS_LEFT_Y, -1.0)
	_add_joy_axis(&"move_back", JOY_AXIS_LEFT_Y, 1.0)
	_add_joy_button(&"attack", JOY_BUTTON_RIGHT_SHOULDER)
	_add_joy_button(&"dash", JOY_BUTTON_A)
	_add_joy_button(&"resonance", JOY_BUTTON_B)
	_add_joy_button(&"interact", JOY_BUTTON_X)
	_add_joy_button(&"pause_game", JOY_BUTTON_START)


@private
func _add_key_action(action: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for mapped_event: InputEvent in InputMap.action_get_events(action):
		if mapped_event is InputEventKey:
			var mapped_key := mapped_event as InputEventKey
			if mapped_key.physical_keycode == keycode:
				return
	var key_event := InputEventKey.new()
	key_event.physical_keycode = keycode
	InputMap.action_add_event(action, key_event)


@private
func _add_joy_button(action: StringName, button: JoyButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var joy_event := InputEventJoypadButton.new()
	joy_event.button_index = button
	InputMap.action_add_event(action, joy_event)


@private
func _add_joy_axis(action: StringName, axis: JoyAxis, axis_value: float) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var joy_event := InputEventJoypadMotion.new()
	joy_event.axis = axis
	joy_event.axis_value = axis_value
	InputMap.action_add_event(action, joy_event)
