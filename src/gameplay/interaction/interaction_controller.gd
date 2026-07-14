class_name InteractionController
extends Node

signal target_activated(target: Node3D)

const INTERACTION_RANGE := 3.25

var player: WayfarerController
var hud: GameHud
var soundscape: LumenfallSoundscape
var _focused_target: Node3D


func configure(player_controller: WayfarerController, game_hud: GameHud, audio: LumenfallSoundscape) -> void:
	player = player_controller
	hud = game_hud
	soundscape = audio


@override
func _ready() -> void:
	player.interaction_requested.connect(_activate_focused_target)


@override
func _process(_delta: float) -> void:
	var nearest := _nearest_target()
	if nearest != _focused_target:
		_set_focus(_focused_target, false)
		_focused_target = nearest
		_set_focus(_focused_target, true)
	hud.set_interaction(_prompt(_focused_target))


@private
func _activate_focused_target() -> void:
	if not is_instance_valid(_focused_target):
		return
	soundscape.play_interaction()
	target_activated.emit(_focused_target)


@private
func _nearest_target() -> Node3D:
	var nearest: Node3D
	var nearest_distance := INTERACTION_RANGE
	for candidate: Node in get_tree().get_nodes_in_group(&"interactables"):
		if candidate is Node3D:
			var candidate_3d := candidate as Node3D
			var distance := player.global_position.distance_to(candidate_3d.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest = candidate_3d
	return nearest


@private
func _set_focus(target: Node3D, focused: bool) -> void:
	if target is NpcActor:
		(target as NpcActor).set_interaction_focus(focused)
	elif target is WorldInteractable:
		(target as WorldInteractable).set_interaction_focus(focused)


@private
func _prompt(target: Node3D) -> String:
	if target is NpcActor:
		return (target as NpcActor).get_interaction_prompt()
	if target is WorldInteractable:
		return (target as WorldInteractable).get_interaction_prompt()
	return ""
