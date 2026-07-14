class_name PalimpsestApp
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
