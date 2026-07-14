class_name WorldTravelController
extends Node

var world_root: Node3D
var player: WayfarerController
var echo_causeway: EchoCauseway


func configure(root: Node3D, player_controller: WayfarerController) -> void:
	world_root = root
	player = player_controller


func enter_echo_causeway() -> void:
	if not is_instance_valid(echo_causeway):
		echo_causeway = EchoCauseway.new()
		world_root.add_child(echo_causeway)
	player.global_position = Vector3(420.0, 19.2, -408.0)
	player.velocity = Vector3.ZERO


func return_to_hearthmere() -> void:
	player.global_position = Vector3(0.0, 0.7, -10.5)
	player.velocity = Vector3.ZERO
