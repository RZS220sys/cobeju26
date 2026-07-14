class_name FirstCrossingQuest
extends Node

var world_state: LumenfallWorldState
var player: WayfarerController
var hud: GameHud
var world: LumenfallWorld

var _rift_visual: Node3D
var riftglass: RiftglassObjective
var first_hunt: FirstHuntObjective
var regional_instruments: RegionalInstrumentObjective


func configure(state_value: LumenfallWorldState, player_value: WayfarerController, hud_value: GameHud, world_value: LumenfallWorld) -> void:
	world_state = state_value
	player = player_value
	hud = hud_value
	world = world_value


@override
func _ready() -> void:
	riftglass = RiftglassObjective.new()
	riftglass.configure(world_state, hud, world)
	add_child(riftglass)
	first_hunt = FirstHuntObjective.new()
	first_hunt.configure(world_state, player, hud, world)
	add_child(first_hunt)
	regional_instruments = RegionalInstrumentObjective.new()
	regional_instruments.configure(world_state, hud, world)
	add_child(regional_instruments)
	match world_state.quest_stage:
		QuestCatalog.Stage.SUMMONED:
			_play_summoning()
		QuestCatalog.Stage.WAKE_WAYSTONE:
			hud.set_objective("Inspect the sleeping Waystone")
		QuestCatalog.Stage.MEET_MARA:
			_restore_answered_sky()
			hud.set_objective("Meet Mara by the village road")
		QuestCatalog.Stage.GATHER_RIFTGLASS:
			_restore_answered_sky()
			riftglass.restore()
		QuestCatalog.Stage.RETURN_SHARDS_TO_BRAM:
			_restore_answered_sky()
			hud.set_objective("Bring the singing shards to Bram")
		QuestCatalog.Stage.CRAFT_LANTERN_LENS:
			_restore_answered_sky()
			hud.set_objective("Use Bram's lantern bench")
		QuestCatalog.Stage.SHOW_LENS_TO_MARA:
			_restore_answered_sky()
			hud.set_objective("Show the Lantern Lens to Mara")
		QuestCatalog.Stage.REACH_EASTERN_CROSSING:
			_restore_answered_sky()
			hud.set_objective("Follow Mara beyond the eastern lanterns")
		QuestCatalog.Stage.DEFEND_LANTERN_ROAD:
			_restore_answered_sky()
			first_hunt.begin(true)
		QuestCatalog.Stage.LISTEN_TO_ASTER:
			_restore_answered_sky()
			first_hunt.restore_memory()
		QuestCatalog.Stage.REPORT_ASTER:
			_restore_answered_sky()
			hud.set_objective("Tell Nia what the hound remembered")
		QuestCatalog.Stage.CHOOSE_REGION:
			_restore_answered_sky()
			hud.set_objective("Consult Mara's field map beside the well")
		QuestCatalog.Stage.DISCOVER_REGION_INSTRUMENT:
			_restore_answered_sky()
			regional_instruments.set_travel_objective()
		QuestCatalog.Stage.MARK_REGION_DISCOVERY:
			_restore_answered_sky()
			hud.set_objective("Mark the discovery on Mara's field map")
		QuestCatalog.Stage.REPORT_THREE_INSTRUMENTS:
			_restore_answered_sky()
			hud.set_objective("Tell Nia what the three instruments revealed")
		_:
			_restore_answered_sky()
			hud.set_objective("Prepare for the Crossing of Three Voices")


@private
func _play_summoning() -> void:
	player.input_enabled = false
	player.scale = Vector3.ONE * 0.06
	var beam := MeshInstance3D.new()
	beam.name = "SummoningLight"
	var beam_mesh := CylinderMesh.new()
	beam_mesh.top_radius = 0.9
	beam_mesh.bottom_radius = 1.5
	beam_mesh.height = 8.0
	beam_mesh.radial_segments = 20
	beam.mesh = beam_mesh
	beam.position = player.global_position + Vector3.UP * 4.0
	var beam_material := StandardMaterial3D.new()
	beam_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_material.albedo_color = Color(0.25, 0.85, 1.0, 0.2)
	beam_material.emission_enabled = true
	beam_material.emission = Color(0.18, 0.75, 1.0)
	beam_material.emission_energy_multiplier = 2.0
	beam.material_override = beam_material
	world.story_root.add_child(beam)
	var light := OmniLight3D.new()
	light.light_color = Color(0.3, 0.82, 1.0)
	light.light_energy = 6.0
	light.omni_range = 13.0
	light.position = player.global_position + Vector3.UP * 2.0
	world.story_root.add_child(light)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(player, "scale", Vector3.ONE, 1.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(beam, "transparency", 1.0, 1.5).set_delay(0.7)
	tween.tween_property(light, "light_energy", 0.0, 1.2).set_delay(0.8)
	tween.chain().tween_callback(func() -> void:
		beam.queue_free()
		light.queue_free()
		player.input_enabled = true
		hud.set_objective("Talk to Nia beside the Waystone")
		hud.show_dialogue("Nia", "You came through! ...Can you move?", 4.2)
	)


func handle_interaction(interactable: Node3D) -> void:
	if interactable is NpcActor:
		_handle_npc(interactable as NpcActor)
	elif interactable is WorldInteractable:
		_handle_world_object(interactable as WorldInteractable)


@private
func _handle_npc(npc: NpcActor) -> void:
	npc.greet(player.global_position)
	match npc.npc_id:
		NpcCatalog.Id.NIA:
			if world_state.quest_stage == QuestCatalog.Stage.SUMMONED:
				world_state.quest_stage = QuestCatalog.Stage.WAKE_WAYSTONE
				world_state.active_quest_id = QuestCatalog.Id.WAKE_THE_WAYSTONE
				hud.show_dialogue("Nia", "I was aiming for a lantern. You're much better. Help me wake this stone?", 5.2)
				hud.set_objective("Inspect the sleeping Waystone")
				world.persistence.save_checkpoint()
			elif world_state.quest_stage == QuestCatalog.Stage.REPORT_ASTER:
				npc.remember_event(NpcCatalog.Event.ASTER_REMEMBERED)
				world_state.quest_stage = QuestCatalog.Stage.CHOOSE_REGION
				world_state.active_quest_id = QuestCatalog.Id.HEARTHMERE_WAGES
				world_state.completed_quest_ids.append(QuestCatalog.Id.THE_FIRST_CROSSING)
				world_state.gold_coins += 18
				hud.show_dialogue("Nia", "Aster. Then the rifts remember names. Take eighteen hearth-coins—wages from us, not loot from it.", 5.8)
				hud.set_objective("Explore Hearthmere before the next crossing")
				world.persistence.save_checkpoint()
			elif world_state.quest_stage == QuestCatalog.Stage.REPORT_THREE_INSTRUMENTS:
				npc.remember_event(NpcCatalog.Event.REGIONAL_TRUTH_SHARED)
				world_state.quest_stage = QuestCatalog.Stage.RESCUE_MISSING_VILLAGERS
				world_state.active_quest_id = QuestCatalog.Id.THE_CROSSING_OF_THREE_VOICES
				world_state.completed_quest_ids.append(QuestCatalog.Id.THE_THREE_INSTRUMENTS)
				world_state.gold_coins += 40
				hud.show_dialogue("Nia", "Shrine, orrery, bell—three machines built to remember one missing road. We open it together, or not at all.", 6.0)
				hud.set_objective("Prepare for the Crossing of Three Voices")
				world.persistence.save_checkpoint()
			else:
				hud.show_dialogue("Nia", "The blue ring is the part that refuses to wake.", 3.5)
		NpcCatalog.Id.BRAM:
			if world_state.quest_stage == QuestCatalog.Stage.RETURN_SHARDS_TO_BRAM:
				world_state.quest_stage = QuestCatalog.Stage.CRAFT_LANTERN_LENS
				world_state.active_quest_id = QuestCatalog.Id.A_LENS_FOR_THE_ROAD
				hud.show_dialogue("Bram", "These are memories that forgot their owners. Bring them to my bench; we'll give them a kinder purpose.", 5.4)
				hud.set_objective("Use Bram's lantern bench")
				world.persistence.save_checkpoint()
			else:
				hud.show_dialogue("Bram", "A tool should leave a place better than it found it.", 3.8)
		NpcCatalog.Id.MARA:
			if world_state.quest_stage == QuestCatalog.Stage.MEET_MARA:
				world_state.quest_stage = QuestCatalog.Stage.GATHER_RIFTGLASS
				world_state.active_quest_id = QuestCatalog.Id.THE_SINGING_SHARDS
				hud.show_dialogue("Mara", "The rift dropped three blue notes around Hearthmere. No beasts yet. Gather them before the notes learn to scream.", 5.8)
				riftglass.restore()
				world.persistence.save_checkpoint()
			elif world_state.quest_stage == QuestCatalog.Stage.SHOW_LENS_TO_MARA:
				world_state.quest_stage = QuestCatalog.Stage.REACH_EASTERN_CROSSING
				world_state.active_quest_id = QuestCatalog.Id.BEYOND_THE_LANTERNS
				hud.show_dialogue("Mara", "Good. The lens sees what fear hides. Meet me beyond the eastern lanterns when you're ready.", 5.2)
				hud.set_objective("Follow Mara beyond the eastern lanterns")
				world.persistence.save_checkpoint()
			else:
				hud.show_dialogue("Mara", "Stay inside the lantern posts until we understand the sky.", 4.0)
		NpcCatalog.Id.PIP:
			hud.show_dialogue("Pip", "You fell out of a star! I saw your shoes first.", 4.0)


@private
func _handle_world_object(interactable: WorldInteractable) -> void:
	if interactable.interaction_id == InteractionCatalog.Id.WAYSTONE and world_state.quest_stage == QuestCatalog.Stage.WAKE_WAYSTONE:
		world_state.quest_stage = QuestCatalog.Stage.MEET_MARA
		world_state.active_quest_id = QuestCatalog.Id.THE_ANSWERING_SKY
		hud.show_dialogue("Nia", "That wasn't me. The sky just answered us.", 4.5)
		hud.set_objective("Find Mara at the village road")
		_activate_waystone(interactable)
		_spawn_distant_rift()
		world.soundscape.play_memory()
		world.persistence.save_checkpoint()
	elif interactable.interaction_id == InteractionCatalog.Id.RIFTGLASS_SHARD and world_state.quest_stage == QuestCatalog.Stage.GATHER_RIFTGLASS:
		riftglass.collect(interactable)
	elif interactable.interaction_id == InteractionCatalog.Id.BRAM_WORKBENCH and world_state.quest_stage >= QuestCatalog.Stage.CRAFT_LANTERN_LENS:
		_open_workshop()
	elif interactable.interaction_id == InteractionCatalog.Id.EASTERN_CROSSING and world_state.quest_stage == QuestCatalog.Stage.REACH_EASTERN_CROSSING:
		world_state.quest_stage = QuestCatalog.Stage.DEFEND_LANTERN_ROAD
		world_state.active_quest_id = QuestCatalog.Id.THE_HOUND_CALLED_ASTER
		first_hunt.begin(false)
		world.persistence.save_checkpoint()
	elif interactable.interaction_id == InteractionCatalog.Id.HOUND_MEMORY and world_state.quest_stage == QuestCatalog.Stage.LISTEN_TO_ASTER:
		first_hunt.listen(interactable)
	elif interactable.interaction_id == InteractionCatalog.Id.FIELD_MAP and world_state.quest_stage in [QuestCatalog.Stage.CHOOSE_REGION, QuestCatalog.Stage.MARK_REGION_DISCOVERY]:
		regional_instruments.open_map()
	elif world_state.quest_stage == QuestCatalog.Stage.DISCOVER_REGION_INSTRUMENT and interactable.interaction_id in [InteractionCatalog.Id.GLASSWOOD_SHRINE, InteractionCatalog.Id.AMBERFEN_ORRERY, InteractionCatalog.Id.BELLSCAR_BELL]:
		regional_instruments.discover(interactable)


@private
func _activate_waystone(interactable: WorldInteractable) -> void:
	interactable.interaction_prompt = "Examine the awakened Waystone"
	if interactable.has_node("AwakenedLight"):
		return
	var light := OmniLight3D.new()
	light.name = "AwakenedLight"
	light.light_color = Color(0.18, 0.78, 1.0)
	light.light_energy = 0.0
	light.omni_range = 14.0
	interactable.add_child(light)
	var tween := create_tween()
	tween.tween_property(light, "light_energy", 7.0, 0.35)
	tween.tween_property(light, "light_energy", 2.5, 1.2)


@private
func _spawn_distant_rift() -> void:
	if is_instance_valid(_rift_visual):
		return
	_rift_visual = Node3D.new()
	_rift_visual.name = "FirstRift"
	_rift_visual.position = Vector3(0.0, 17.0, -48.0)
	world.story_root.add_child(_rift_visual)
	for index: int in range(4):
		var ring := MeshInstance3D.new()
		var mesh := TorusMesh.new()
		mesh.inner_radius = 2.0 + float(index) * 0.55
		mesh.outer_radius = mesh.inner_radius + 0.11
		mesh.rings = 10
		mesh.ring_segments = 36
		ring.mesh = mesh
		ring.rotation = Vector3(PI * 0.5, float(index) * 0.4, float(index) * 0.2)
		var material := StandardMaterial3D.new()
		material.albedo_color = Color("8c39d8")
		material.emission_enabled = true
		material.emission = Color("9b42ef")
		material.emission_energy_multiplier = 1.6
		ring.material_override = material
		_rift_visual.add_child(ring)
	var tween := create_tween().set_loops()
	tween.tween_property(_rift_visual, "rotation:z", TAU, 10.0).from(0.0)


@private
func _restore_answered_sky() -> void:
	_spawn_distant_rift()
	if is_instance_valid(world.village) and is_instance_valid(world.village.waystone_interactable):
		_activate_waystone(world.village.waystone_interactable)


@private
func _open_workshop() -> void:
	var workshop := world.overlays.open_workshop()
	if not workshop.crafted_lantern_lens.is_connected(_on_lantern_lens_crafted):
		workshop.crafted_lantern_lens.connect(_on_lantern_lens_crafted)


@private
func _on_lantern_lens_crafted() -> void:
	world_state.riftglass_pieces = Inventory.count(world_state, ItemCatalog.Id.RIFTGLASS)
	world_state.quest_stage = maxi(world_state.quest_stage, QuestCatalog.Stage.SHOW_LENS_TO_MARA)
	world_state.active_quest_id = QuestCatalog.Id.THE_GUARDIANS_MEASURE
	hud.show_dialogue("Bram", "A lens doesn't tell truth. It only shows which truths can still be survived.", 5.0)
	hud.set_objective("Show the Lantern Lens to Mara")
	world.player_coordinator.refresh_inventory_hud()
	world.soundscape.play_craft()
	world.persistence.save_checkpoint()


func on_player_rescued() -> void:
	first_hunt.rescue_player()
