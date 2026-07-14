class_name HearthmereVillage
extends Node3D

var npcs: Dictionary[NpcCatalog.Id, NpcActor] = {}
var waystone_interactable: WorldInteractable
var workshop_interactable: WorldInteractable
var eastern_crossing: WorldInteractable
var field_map: WorldInteractable
var crossing_aftermath: WorldInteractable

var _world_id: String
var _aftermath: CrossingAftermath


func configure(world_id: String) -> void:
	_world_id = world_id


@override
func _ready() -> void:
	name = "Hearthmere"
	add_child(HearthmereScenery.new())
	var residents := HearthmereResidents.new()
	residents.configure(_world_id)
	add_child(residents)
	npcs = residents.npcs
	var interactions := HearthmereInteractions.new()
	add_child(interactions)
	waystone_interactable = interactions.waystone
	workshop_interactable = interactions.workshop
	eastern_crossing = interactions.eastern_crossing
	field_map = interactions.field_map


func apply_crossing_choice(state: LumenfallWorldState) -> void:
	if is_instance_valid(_aftermath):
		return
	_aftermath = CrossingAftermath.new()
	add_child(_aftermath)
	_aftermath.configure(state)
	if is_instance_valid(_aftermath.interactable):
		crossing_aftermath = _aftermath.interactable
