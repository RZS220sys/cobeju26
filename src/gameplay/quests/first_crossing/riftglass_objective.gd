class_name RiftglassObjective
extends Node

const POSITIONS: Array[Vector3] = [
	Vector3(-11.0, 0.2, -23.0),
	Vector3(17.0, 0.2, -18.0),
	Vector3(19.0, 0.2, 9.0),
]

var spawned_shards: Array[RiftglassShard] = []
var world_state: GameWorldState
var hud: GameHud
var world: GameWorld


func configure(state: GameWorldState, game_hud: GameHud, world_root: GameWorld) -> void:
	world_state = state
	hud = game_hud
	world = world_root


func restore() -> void:
	var collected := Inventory.count(world_state, ItemCatalog.Id.RIFTGLASS)
	if world_state.quest_stage > QuestCatalog.Stage.GATHER_RIFTGLASS:
		return
	for index: int in range(collected, POSITIONS.size()):
		var shard := RiftglassShard.new()
		shard.name = "Riftglass_%d" % index
		shard.configure(InteractionCatalog.Id.RIFTGLASS_SHARD, "Gather the singing shard")
		shard.position = POSITIONS[index]
		world.story_root.add_child(shard)
		spawned_shards.append(shard)
	update_objective()


func collect(interactable: WorldInteractable) -> void:
	interactable.remove_from_group(&"interactables")
	interactable.set_interaction_focus(false)
	Inventory.add(world_state, ItemCatalog.Id.RIFTGLASS)
	world.soundscape.play_collect()
	world_state.riftglass_pieces = Inventory.count(world_state, ItemCatalog.Id.RIFTGLASS)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(interactable, "scale", Vector3.ZERO, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(interactable, "position:y", interactable.position.y + 1.2, 0.28)
	tween.chain().tween_callback(interactable.queue_free)
	if world_state.riftglass_pieces >= POSITIONS.size():
		world_state.quest_stage = QuestCatalog.Stage.RETURN_SHARDS_TO_BRAM
		world_state.active_quest_id = QuestCatalog.Id.RIFTGLASS_IS_NOT_COIN
		hud.show_dialogue("Mara", "All three. Hear how they harmonize? Bram will know what shape they want.", 4.8)
		hud.set_objective("Bring the singing shards to Bram")
	else:
		hud.show_dialogue("Wayfarer", "It is warm—and the sound is inside my hand.", 3.5)
		update_objective()
	world.persistence.save_checkpoint()


func update_objective() -> void:
	var pieces := Inventory.count(world_state, ItemCatalog.Id.RIFTGLASS)
	hud.set_objective("Gather the singing shards  •  %d / %d" % [pieces, POSITIONS.size()])
