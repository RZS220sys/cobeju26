class_name HearthmereResidents
extends Node3D

var npcs: Dictionary[NpcCatalog.Id, NpcActor] = {}
var _world_id: String


func configure(world_id: String) -> void:
	_world_id = world_id


@override
func _ready() -> void:
	name = "Residents"
	_spawn(NpcCatalog.Id.NIA, Vector3(2.2, 0.0, -12.8), PI)
	_spawn(NpcCatalog.Id.BRAM, Vector3(8.0, 0.0, -2.0), -1.3)
	_spawn(NpcCatalog.Id.MARA, Vector3(-5.5, 0.0, 5.0), 2.5)
	_spawn(NpcCatalog.Id.PIP, Vector3(2.0, 0.0, 4.0), -0.4)


@private
func _spawn(npc_id: NpcCatalog.Id, at: Vector3, yaw: float) -> void:
	var actor := NpcFactory.create_humanoid(npc_id)
	if not is_instance_valid(actor):
		return
	actor.bind_world(_world_id)
	actor.position = at
	actor.rotation.y = yaw
	add_child(actor)
	npcs[npc_id] = actor
