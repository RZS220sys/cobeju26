class_name FirstCrossingQuest
extends Node

var profile: LumenfallSaveData
var player: WayfarerController
var hud: AdventureHud
var world: LumenfallAdventureWorld

var _rift_visual: Node3D
var _spawned_shards: Array[AdventureRiftglassShard] = []
var _first_hound: AdventureRiftHound
var _hound_memory: AdventureRiftglassShard

const RIFTGLASS_POSITIONS: Array[Vector3] = [
	Vector3(-11.0, 0.2, -23.0),
	Vector3(17.0, 0.2, -18.0),
	Vector3(19.0, 0.2, 9.0),
]


func configure(profile_value: LumenfallSaveData, player_value: WayfarerController, hud_value: AdventureHud, world_value: LumenfallAdventureWorld) -> void:
	profile = profile_value
	player = player_value
	hud = hud_value
	world = world_value


@override
func _ready() -> void:
	match profile.quest_stage:
		LumenfallTypes.QuestStage.SUMMONED:
			_play_summoning()
		LumenfallTypes.QuestStage.WAKE_WAYSTONE:
			hud.set_objective("Inspect the sleeping Waystone")
		LumenfallTypes.QuestStage.MEET_MARA:
			_restore_answered_sky()
			hud.set_objective("Meet Mara by the village road")
		LumenfallTypes.QuestStage.GATHER_RIFTGLASS:
			_restore_answered_sky()
			_spawn_remaining_riftglass()
			_update_riftglass_objective()
		LumenfallTypes.QuestStage.RETURN_SHARDS_TO_BRAM:
			_restore_answered_sky()
			hud.set_objective("Bring the singing shards to Bram")
		LumenfallTypes.QuestStage.CRAFT_LANTERN_LENS:
			_restore_answered_sky()
			hud.set_objective("Use Bram's lantern bench")
		LumenfallTypes.QuestStage.SHOW_LENS_TO_MARA:
			_restore_answered_sky()
			hud.set_objective("Show the Lantern Lens to Mara")
		LumenfallTypes.QuestStage.REACH_EASTERN_CROSSING:
			_restore_answered_sky()
			hud.set_objective("Follow Mara beyond the eastern lanterns")
		LumenfallTypes.QuestStage.DEFEND_LANTERN_ROAD:
			_restore_answered_sky()
			_begin_first_hunt(true)
		LumenfallTypes.QuestStage.LISTEN_TO_ASTER:
			_restore_answered_sky()
			_restore_hound_memory()
		LumenfallTypes.QuestStage.REPORT_ASTER:
			_restore_answered_sky()
			hud.set_objective("Tell Nia what the hound remembered")
		LumenfallTypes.QuestStage.CHOOSE_REGION:
			_restore_answered_sky()
			hud.set_objective("Consult Mara's field map beside the well")
		LumenfallTypes.QuestStage.DISCOVER_REGION_INSTRUMENT:
			_restore_answered_sky()
			_set_region_objective()
		LumenfallTypes.QuestStage.MARK_REGION_DISCOVERY:
			_restore_answered_sky()
			hud.set_objective("Mark the discovery on Mara's field map")
		LumenfallTypes.QuestStage.REPORT_THREE_INSTRUMENTS:
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
	world.add_child(beam)
	var light := OmniLight3D.new()
	light.light_color = Color(0.3, 0.82, 1.0)
	light.light_energy = 6.0
	light.omni_range = 13.0
	light.position = player.global_position + Vector3.UP * 2.0
	world.add_child(light)
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
	if interactable is AdventureNpc:
		_handle_npc(interactable as AdventureNpc)
	elif interactable is AdventureWorldInteractable:
		_handle_world_object(interactable as AdventureWorldInteractable)


@private
func _handle_npc(npc: AdventureNpc) -> void:
	npc.greet(player.global_position)
	match npc.npc_id:
		LumenfallTypes.NpcId.NIA:
			if profile.quest_stage == LumenfallTypes.QuestStage.SUMMONED:
				profile.quest_stage = LumenfallTypes.QuestStage.WAKE_WAYSTONE
				profile.active_quest_id = LumenfallTypes.QuestId.WAKE_THE_WAYSTONE
				hud.show_dialogue("Nia", "I was aiming for a lantern. You're much better. Help me wake this stone?", 5.2)
				hud.set_objective("Inspect the sleeping Waystone")
				world.save_checkpoint()
			elif profile.quest_stage == LumenfallTypes.QuestStage.REPORT_ASTER:
				profile.quest_stage = LumenfallTypes.QuestStage.CHOOSE_REGION
				profile.active_quest_id = LumenfallTypes.QuestId.HEARTHMERE_WAGES
				profile.completed_quest_ids.append(LumenfallTypes.QuestId.THE_FIRST_CROSSING)
				profile.gold_coins += 18
				hud.show_dialogue("Nia", "Aster. Then the rifts remember names. Take eighteen hearth-coins—wages from us, not loot from it.", 5.8)
				hud.set_objective("Explore Hearthmere before the next crossing")
				world.save_checkpoint()
			elif profile.quest_stage == LumenfallTypes.QuestStage.REPORT_THREE_INSTRUMENTS:
				profile.quest_stage = LumenfallTypes.QuestStage.RESCUE_MISSING_VILLAGERS
				profile.active_quest_id = LumenfallTypes.QuestId.THE_CROSSING_OF_THREE_VOICES
				profile.completed_quest_ids.append(LumenfallTypes.QuestId.THE_THREE_INSTRUMENTS)
				profile.gold_coins += 40
				hud.show_dialogue("Nia", "Shrine, orrery, bell—three machines built to remember one missing road. We open it together, or not at all.", 6.0)
				hud.set_objective("Prepare for the Crossing of Three Voices")
				world.save_checkpoint()
			else:
				hud.show_dialogue("Nia", "The blue ring is the part that refuses to wake.", 3.5)
		LumenfallTypes.NpcId.BRAM:
			if profile.quest_stage == LumenfallTypes.QuestStage.RETURN_SHARDS_TO_BRAM:
				profile.quest_stage = LumenfallTypes.QuestStage.CRAFT_LANTERN_LENS
				profile.active_quest_id = LumenfallTypes.QuestId.A_LENS_FOR_THE_ROAD
				hud.show_dialogue("Bram", "These are memories that forgot their owners. Bring them to my bench; we'll give them a kinder purpose.", 5.4)
				hud.set_objective("Use Bram's lantern bench")
				world.save_checkpoint()
			else:
				hud.show_dialogue("Bram", "A tool should leave a place better than it found it.", 3.8)
		LumenfallTypes.NpcId.MARA:
			if profile.quest_stage == LumenfallTypes.QuestStage.MEET_MARA:
				profile.quest_stage = LumenfallTypes.QuestStage.GATHER_RIFTGLASS
				profile.active_quest_id = LumenfallTypes.QuestId.THE_SINGING_SHARDS
				hud.show_dialogue("Mara", "The rift dropped three blue notes around Hearthmere. No beasts yet. Gather them before the notes learn to scream.", 5.8)
				_spawn_remaining_riftglass()
				_update_riftglass_objective()
				world.save_checkpoint()
			elif profile.quest_stage == LumenfallTypes.QuestStage.SHOW_LENS_TO_MARA:
				profile.quest_stage = LumenfallTypes.QuestStage.REACH_EASTERN_CROSSING
				profile.active_quest_id = LumenfallTypes.QuestId.BEYOND_THE_LANTERNS
				hud.show_dialogue("Mara", "Good. The lens sees what fear hides. Meet me beyond the eastern lanterns when you're ready.", 5.2)
				hud.set_objective("Follow Mara beyond the eastern lanterns")
				world.save_checkpoint()
			else:
				hud.show_dialogue("Mara", "Stay inside the lantern posts until we understand the sky.", 4.0)
		LumenfallTypes.NpcId.PIP:
			hud.show_dialogue("Pip", "You fell out of a star! I saw your shoes first.", 4.0)


@private
func _handle_world_object(interactable: AdventureWorldInteractable) -> void:
	if interactable.interaction_id == LumenfallTypes.InteractionId.WAYSTONE and profile.quest_stage == LumenfallTypes.QuestStage.WAKE_WAYSTONE:
		profile.quest_stage = LumenfallTypes.QuestStage.MEET_MARA
		profile.active_quest_id = LumenfallTypes.QuestId.THE_ANSWERING_SKY
		hud.show_dialogue("Nia", "That wasn't me. The sky just answered us.", 4.5)
		hud.set_objective("Find Mara at the village road")
		_activate_waystone(interactable)
		_spawn_distant_rift()
		world.soundscape.play_memory()
		world.save_checkpoint()
	elif interactable.interaction_id == LumenfallTypes.InteractionId.RIFTGLASS_SHARD and profile.quest_stage == LumenfallTypes.QuestStage.GATHER_RIFTGLASS:
		_collect_riftglass(interactable)
	elif interactable.interaction_id == LumenfallTypes.InteractionId.BRAM_WORKBENCH and profile.quest_stage >= LumenfallTypes.QuestStage.CRAFT_LANTERN_LENS:
		_open_workshop()
	elif interactable.interaction_id == LumenfallTypes.InteractionId.EASTERN_CROSSING and profile.quest_stage == LumenfallTypes.QuestStage.REACH_EASTERN_CROSSING:
		profile.quest_stage = LumenfallTypes.QuestStage.DEFEND_LANTERN_ROAD
		profile.active_quest_id = LumenfallTypes.QuestId.THE_HOUND_CALLED_ASTER
		_begin_first_hunt(false)
		world.save_checkpoint()
	elif interactable.interaction_id == LumenfallTypes.InteractionId.HOUND_MEMORY and profile.quest_stage == LumenfallTypes.QuestStage.LISTEN_TO_ASTER:
		_listen_to_hound_memory(interactable)
	elif interactable.interaction_id == LumenfallTypes.InteractionId.FIELD_MAP and profile.quest_stage in [LumenfallTypes.QuestStage.CHOOSE_REGION, LumenfallTypes.QuestStage.MARK_REGION_DISCOVERY]:
		_open_field_map()
	elif profile.quest_stage == LumenfallTypes.QuestStage.DISCOVER_REGION_INSTRUMENT and interactable.interaction_id in [LumenfallTypes.InteractionId.GLASSWOOD_SHRINE, LumenfallTypes.InteractionId.AMBERFEN_ORRERY, LumenfallTypes.InteractionId.BELLSCAR_BELL]:
		_discover_region_instrument(interactable)


@private
func _activate_waystone(interactable: AdventureWorldInteractable) -> void:
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
	world.add_child(_rift_visual)
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
func _spawn_remaining_riftglass() -> void:
	var collected := AdventureInventory.count(profile, LumenfallTypes.ItemId.RIFTGLASS)
	if profile.quest_stage > LumenfallTypes.QuestStage.GATHER_RIFTGLASS:
		return
	for index: int in range(collected, RIFTGLASS_POSITIONS.size()):
		var shard := AdventureRiftglassShard.new()
		shard.name = "Riftglass_%d" % index
		shard.configure(LumenfallTypes.InteractionId.RIFTGLASS_SHARD, "Gather the singing shard")
		shard.position = RIFTGLASS_POSITIONS[index]
		world.add_child(shard)
		_spawned_shards.append(shard)


@private
func _collect_riftglass(interactable: AdventureWorldInteractable) -> void:
	interactable.remove_from_group(&"adventure_interactables")
	interactable.set_interaction_focus(false)
	AdventureInventory.add(profile, LumenfallTypes.ItemId.RIFTGLASS)
	world.soundscape.play_collect()
	profile.riftglass_pieces = AdventureInventory.count(profile, LumenfallTypes.ItemId.RIFTGLASS)
	var pieces := profile.riftglass_pieces
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(interactable, "scale", Vector3.ZERO, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(interactable, "position:y", interactable.position.y + 1.2, 0.28)
	tween.chain().tween_callback(interactable.queue_free)
	if pieces >= 3:
		profile.quest_stage = LumenfallTypes.QuestStage.RETURN_SHARDS_TO_BRAM
		profile.active_quest_id = LumenfallTypes.QuestId.RIFTGLASS_IS_NOT_COIN
		hud.show_dialogue("Mara", "All three. Hear how they harmonize? Bram will know what shape they want.", 4.8)
		hud.set_objective("Bring the singing shards to Bram")
	else:
		hud.show_dialogue("Wayfarer", "It is warm—and the sound is inside my hand.", 3.5)
		_update_riftglass_objective()
	world.save_checkpoint()


@private
func _update_riftglass_objective() -> void:
	var pieces := AdventureInventory.count(profile, LumenfallTypes.ItemId.RIFTGLASS)
	hud.set_objective("Gather the singing shards  •  %d / 3" % pieces)


@private
func _open_workshop() -> void:
	var workshop := world.open_workshop()
	if not workshop.crafted_lantern_lens.is_connected(_on_lantern_lens_crafted):
		workshop.crafted_lantern_lens.connect(_on_lantern_lens_crafted)


@private
func _on_lantern_lens_crafted() -> void:
	profile.riftglass_pieces = AdventureInventory.count(profile, LumenfallTypes.ItemId.RIFTGLASS)
	profile.quest_stage = maxi(profile.quest_stage, LumenfallTypes.QuestStage.SHOW_LENS_TO_MARA)
	profile.active_quest_id = LumenfallTypes.QuestId.THE_GUARDIANS_MEASURE
	hud.show_dialogue("Bram", "A lens doesn't tell truth. It only shows which truths can still be survived.", 5.0)
	hud.set_objective("Show the Lantern Lens to Mara")
	world.refresh_inventory_hud()
	world.soundscape.play_craft()
	world.save_checkpoint()


@private
func _begin_first_hunt(restored: bool) -> void:
	if is_instance_valid(_first_hound):
		return
	if is_instance_valid(world.village):
		world.village.eastern_crossing.remove_from_group(&"adventure_interactables")
		var mara: AdventureNpc = world.village.npcs.get(LumenfallTypes.NpcId.MARA) as AdventureNpc
		if is_instance_valid(mara):
			mara.global_position = Vector3(34.5, 0.0, 3.8)
			mara.rotation.y = -1.2
	_first_hound = AdventureRiftHound.new()
	_first_hound.configure(player)
	_first_hound.position = Vector3(41.0, 1.0, 1.5)
	_first_hound.defeated.connect(_on_first_hound_defeated)
	world.add_child(_first_hound)
	hud.set_objective("Defend the lantern road  •  Left click to strike")
	if not restored:
		hud.show_dialogue("Mara", "Wait. That hound is terrified—hold the road, but watch its rift-scar.", 5.0)


@private
func _on_first_hound_defeated(hound: AdventureRiftHound) -> void:
	if profile.quest_stage != LumenfallTypes.QuestStage.DEFEND_LANTERN_ROAD:
		return
	profile.quest_stage = LumenfallTypes.QuestStage.LISTEN_TO_ASTER
	profile.active_quest_id = LumenfallTypes.QuestId.A_NAME_INSIDE_THE_NOISE
	hud.show_dialogue("Mara", "It wasn't hunting us. It was running from something that knew its name.", 5.2)
	hud.set_objective("Use the Lantern Lens on the hound's rift-scar")
	_spawn_hound_memory(hound.global_position + Vector3.UP * 0.25)
	world.soundscape.play_memory()
	world.save_checkpoint()


@private
func _restore_hound_memory() -> void:
	hud.set_objective("Use the Lantern Lens on the hound's rift-scar")
	if is_instance_valid(world.village):
		world.village.eastern_crossing.remove_from_group(&"adventure_interactables")
		var mara: AdventureNpc = world.village.npcs.get(LumenfallTypes.NpcId.MARA) as AdventureNpc
		if is_instance_valid(mara):
			mara.global_position = Vector3(34.5, 0.0, 3.8)
	_spawn_hound_memory(Vector3(40.0, 0.25, 1.5))


@private
func _spawn_hound_memory(at: Vector3) -> void:
	if is_instance_valid(_hound_memory):
		return
	_hound_memory = AdventureRiftglassShard.new()
	_hound_memory.name = "AsterMemory"
	_hound_memory.configure(LumenfallTypes.InteractionId.HOUND_MEMORY, "Listen through the Lantern Lens")
	_hound_memory.position = at
	_hound_memory.scale = Vector3.ONE * 0.78
	world.add_child(_hound_memory)


@private
func _listen_to_hound_memory(interactable: AdventureWorldInteractable) -> void:
	interactable.remove_from_group(&"adventure_interactables")
	interactable.queue_free()
	AdventureInventory.add(profile, LumenfallTypes.ItemId.ASTER_MEMORY)
	world.soundscape.play_memory()
	profile.quest_stage = LumenfallTypes.QuestStage.REPORT_ASTER
	profile.active_quest_id = LumenfallTypes.QuestId.THE_NAME_ASTER
	hud.show_dialogue("Aster's Memory", "Small hands. A red ribbon. Someone promising: I will come back before the bells.", 6.0)
	hud.set_objective("Tell Nia what the hound remembered")
	world.save_checkpoint()


func on_player_rescued() -> void:
	if profile.quest_stage != LumenfallTypes.QuestStage.DEFEND_LANTERN_ROAD:
		return
	profile.quest_stage = LumenfallTypes.QuestStage.REACH_EASTERN_CROSSING
	profile.active_quest_id = LumenfallTypes.QuestId.BEYOND_THE_LANTERNS
	if is_instance_valid(_first_hound):
		_first_hound.queue_free()
		_first_hound = null
	if is_instance_valid(world.village):
		if not world.village.eastern_crossing.is_in_group(&"adventure_interactables"):
			world.village.eastern_crossing.add_to_group(&"adventure_interactables")
		var mara: AdventureNpc = world.village.npcs.get(LumenfallTypes.NpcId.MARA) as AdventureNpc
		if is_instance_valid(mara):
			mara.global_position = Vector3(-5.5, 0.0, 5.0)
	hud.set_objective("Regroup with Mara beyond the eastern lanterns")


@private
func _open_field_map() -> void:
	if profile.quest_stage == LumenfallTypes.QuestStage.MARK_REGION_DISCOVERY:
		if _region_discovery_count() >= 3:
			profile.quest_stage = LumenfallTypes.QuestStage.REPORT_THREE_INSTRUMENTS
			profile.active_quest_id = LumenfallTypes.QuestId.THREE_INSTRUMENTS_ANSWERED
			hud.show_dialogue("Mara", "All three marks point to the same blank place. Nia needs to see this.", 4.5)
			hud.set_objective("Tell Nia what the three instruments revealed")
			world.save_checkpoint()
			return
		profile.quest_stage = LumenfallTypes.QuestStage.CHOOSE_REGION
	var map := world.open_region_map()
	if not map.region_selected.is_connected(_on_region_selected):
		map.region_selected.connect(_on_region_selected)


@private
func _on_region_selected(region_id: LumenfallTypes.RegionId) -> void:
	profile.quest_stage = LumenfallTypes.QuestStage.DISCOVER_REGION_INSTRUMENT
	match region_id:
		LumenfallTypes.RegionId.GLASSWOOD:
			profile.active_quest_id = LumenfallTypes.QuestId.GLASSWOOD_CALL
		LumenfallTypes.RegionId.AMBERFEN:
			profile.active_quest_id = LumenfallTypes.QuestId.AMBERFEN_ORBIT
		LumenfallTypes.RegionId.BELLSCAR:
			profile.active_quest_id = LumenfallTypes.QuestId.BELLSCAR_WAKE
	_set_region_objective()
	world.save_checkpoint()


@private
func _set_region_objective() -> void:
	match profile.active_quest_id:
		LumenfallTypes.QuestId.GLASSWOOD_CALL:
			hud.set_objective("Travel north to the Glasswood Shrine")
		LumenfallTypes.QuestId.AMBERFEN_ORBIT:
			hud.set_objective("Travel east to the Amberfen Orrery")
		LumenfallTypes.QuestId.BELLSCAR_WAKE:
			hud.set_objective("Travel south to the Bellscar bell")
		_:
			hud.set_objective("Consult Mara's field map beside the well")


@private
func _discover_region_instrument(interactable: AdventureWorldInteractable) -> void:
	var expected_id: LumenfallTypes.InteractionId
	var discovery_item: LumenfallTypes.ItemId
	var speaker := ""
	var line := ""
	match profile.active_quest_id:
		LumenfallTypes.QuestId.GLASSWOOD_CALL:
			expected_id = LumenfallTypes.InteractionId.GLASSWOOD_SHRINE
			discovery_item = LumenfallTypes.ItemId.GLASSWOOD_RESONANCE
			speaker = "Glasswood Shrine"
			line = "Aster was not the first hound. Every guardian here once had a human name."
		LumenfallTypes.QuestId.AMBERFEN_ORBIT:
			expected_id = LumenfallTypes.InteractionId.AMBERFEN_ORRERY
			discovery_item = LumenfallTypes.ItemId.AMBER_ORBIT
			speaker = "Amberfen Orrery"
			line = "The rift is not above the world. It is the shadow cast by a road removed from memory."
		LumenfallTypes.QuestId.BELLSCAR_WAKE:
			expected_id = LumenfallTypes.InteractionId.BELLSCAR_BELL
			discovery_item = LumenfallTypes.ItemId.BELLSCAR_ECHO
			speaker = "Bellscar Bell"
			line = "The bell remembers being rung by someone who has not been born yet."
		_:
			return
	if interactable.interaction_id != expected_id:
		return
	AdventureInventory.add(profile, discovery_item)
	world.soundscape.play_memory()
	profile.quest_stage = LumenfallTypes.QuestStage.MARK_REGION_DISCOVERY
	hud.show_dialogue(speaker, line, 6.0)
	hud.set_objective("Mark the discovery on Mara's field map")
	_pulse_landmark(interactable)
	world.save_checkpoint()


@private
func _pulse_landmark(interactable: AdventureWorldInteractable) -> void:
	var landmark_root := interactable.get_parent().get_node_or_null(interactable.name.trim_suffix("Interactable")) as Node3D
	if not is_instance_valid(landmark_root):
		return
	var tween := create_tween()
	tween.tween_property(landmark_root, "scale", Vector3.ONE * 1.08, 0.28).set_trans(Tween.TRANS_BACK)
	tween.tween_property(landmark_root, "scale", Vector3.ONE, 0.75).set_trans(Tween.TRANS_ELASTIC)


@private
func _region_discovery_count() -> int:
	var total := 0
	for item_id: LumenfallTypes.ItemId in [
		LumenfallTypes.ItemId.GLASSWOOD_RESONANCE,
		LumenfallTypes.ItemId.AMBER_ORBIT,
		LumenfallTypes.ItemId.BELLSCAR_ECHO,
	]:
		if AdventureInventory.count(profile, item_id) > 0:
			total += 1
	return total
