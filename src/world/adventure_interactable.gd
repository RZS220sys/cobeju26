class_name AdventureWorldInteractable
extends Node3D

var interaction_id: LumenfallTypes.InteractionId
var interaction_prompt: String
var _marker: Label3D


func configure(id_value: LumenfallTypes.InteractionId, prompt_value: String) -> void:
	interaction_id = id_value
	interaction_prompt = prompt_value


@override
func _ready() -> void:
	add_to_group(&"adventure_interactables")
	_marker = Label3D.new()
	_marker.name = "InteractionMarker"
	_marker.text = "✦"
	_marker.position.y = 2.7
	_marker.font_size = 48
	_marker.outline_size = 10
	_marker.modulate = Color(0.35, 0.9, 1.0, 0.96)
	_marker.no_depth_test = true
	_marker.visible = false
	add_child(_marker)


func set_interaction_focus(focused: bool) -> void:
	_marker.visible = focused


func get_interaction_prompt() -> String:
	return interaction_prompt
