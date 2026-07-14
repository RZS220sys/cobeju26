class_name WorldPersistenceController
extends Node

const AUTOSAVE_INTERVAL := 20.0

var world_state: LumenfallWorldState
var player: WayfarerController
var _autosave_elapsed: float = 0.0


func configure(state: LumenfallWorldState, player_controller: WayfarerController) -> void:
	world_state = state
	player = player_controller


@override
func _process(delta: float) -> void:
	if not is_instance_valid(world_state) or not is_instance_valid(player):
		return
	world_state.played_seconds += delta
	_autosave_elapsed += delta
	if _autosave_elapsed >= AUTOSAVE_INTERVAL:
		_autosave_elapsed = 0.0
		save_checkpoint()


@override
func _exit_tree() -> void:
	if is_instance_valid(world_state) and is_instance_valid(player) and player.is_inside_tree():
		save_checkpoint()


func save_checkpoint() -> bool:
	world_state.player_x = player.global_position.x
	world_state.player_y = maxf(-5.0, player.global_position.y)
	world_state.player_z = player.global_position.z
	world_state.player_yaw = player.rotation.y
	world_state.current_health = player.current_health
	world_state.maximum_health = player.maximum_health
	for npc_node: Node in get_tree().get_nodes_in_group(&"npcs"):
		if npc_node is NpcActor:
			(npc_node as NpcActor).save_state()
	return WorldLibrary.save_world(world_state)
