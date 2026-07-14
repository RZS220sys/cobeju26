class_name EchoWorld
extends Node3D

signal expedition_finished(result: ExpeditionResult)

var _player: ArchivistController
var _hud: ExpeditionHud
var _arena: ArchiveArenaGenerator
var _gate: ArchiveGate
var _spawn_timer: Timer
var _elapsed: float = 0.0
var _echoes: int = 0
var _kills: int = 0
var _echo_goal: int = 7
var _finished: bool = false
var _rng := RandomNumberGenerator.new()
var _recovered_records: Array[String] = []
var _profile: PalimpsestSaveData
var _boon_overlay: BoonChoiceOverlay
var _boss_active: bool = false
var _pause_overlay: PauseOverlay
var _manually_paused: bool = false
var _soundscape: ArchiveSoundscape


func configure(profile: PalimpsestSaveData, soundscape: ArchiveSoundscape) -> void:
	_profile = profile
	_soundscape = soundscape


@override
func _ready() -> void:
	_rng.seed = _profile.last_seed if is_instance_valid(_profile) else 1907
	_build_environment()
	_build_expedition()


@private
func _build_environment() -> void:
	var environment_node := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = ArchivePalette.ink()
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("7790a0")
	environment.ambient_light_energy = 1.15
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.fog_enabled = true
	environment.fog_light_color = Color("183847")
	environment.fog_light_energy = 0.7
	environment.fog_density = 0.012
	environment.fog_sky_affect = 1.0
	environment_node.environment = environment
	add_child(environment_node)

	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-58.0, -28.0, 0.0)
	moon.light_color = Color("9bc9cf")
	moon.light_energy = 1.35
	moon.shadow_enabled = true
	moon.directional_shadow_max_distance = 48.0
	add_child(moon)


@private
func _build_expedition() -> void:
	_arena = ArchiveArenaGenerator.new()
	_arena.name = "TheSiltCourt"
	_arena.seed_value = _profile.last_seed if is_instance_valid(_profile) else 1907
	add_child(_arena)

	_player = ArchivistController.new()
	_player.position = Vector3(0.0, 0.0, 0.0)
	if is_instance_valid(_profile):
		_player.aim_assist = _profile.aim_assist
		_player.max_health += float(_profile.wick_rank) * 6.0
		_player.health = _player.max_health
		_player.pulse_damage += float(_profile.lens_rank) * 2.0
		_player.max_focus += float(_profile.reservoir_rank) * 6.0
		_player.focus = _player.max_focus
		if _profile.difficulty == 0:
			_player.max_health += 40.0
			_player.health = _player.max_health
			_player.damage_reduction = 0.15
	_player.died.connect(_on_player_died)
	_player.resonance_cast.connect(_on_resonance_cast)
	_player.pulse_cast.connect(_soundscape.play_cast)
	_player.hurt.connect(_soundscape.play_hurt)
	add_child(_player)

	_gate = ArchiveGate.new()
	_gate.name = "DescentSeal"
	_gate.position = Vector3(0.0, 0.0, 14.2)
	_gate.entered.connect(_on_gate_entered)
	add_child(_gate)

	var story_depth := _profile.story_depth if is_instance_valid(_profile) else 0
	var records := LoreCatalog.available_records(story_depth)
	var selected_records: Array[LoreRecord] = []
	while selected_records.size() < _echo_goal and not records.is_empty():
		var selected_index := _rng.randi_range(0, records.size() - 1)
		selected_records.append(records[selected_index])
		records.remove_at(selected_index)
	for index: int in range(_echo_goal):
		var shard := MemoryShard.new()
		shard.name = "Echo_%02d" % (index + 1)
		shard.record_id = selected_records[index].record_id
		shard.record_title = selected_records[index].title
		shard.position = _arena.random_open_position(5.0, 17.0)
		shard.collected.connect(_on_shard_collected)
		add_child(shard)

	for index: int in range(3):
		_spawn_enemy(false, false, index % 2)

	_spawn_timer = Timer.new()
	_spawn_timer.wait_time = 5.2
	_spawn_timer.timeout.connect(_on_spawn_timer)
	add_child(_spawn_timer)
	_spawn_timer.start()

	_hud = ExpeditionHud.new()
	_hud.name = "ExpeditionHud"
	_hud.return_requested.connect(_on_return_requested)
	add_child(_hud)
	_hud.bind_player(_player)
	_hud.set_objective(_echoes, _echo_goal)
	_hud.show_toast("WITNESS // FIRST CONTACT", "Lamplighter. Seven echoes will open the cyan descent seal. The Hollows are memories that learned hunger.", 7.5)


@override
func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"pause_game") and not is_instance_valid(_boon_overlay):
		_toggle_pause()
	if _finished:
		return
	if _manually_paused:
		return
	_elapsed += delta
	_soundscape.set_combat_intensity(float(get_tree().get_nodes_in_group(&"enemies").size()) / 9.0)
	if is_instance_valid(_hud):
		_hud.set_elapsed(_elapsed)


@private
func _spawn_enemy(elite: bool = false, boss: bool = false, forced_kind: int = -1) -> void:
	if not is_instance_valid(_player) or _finished:
		return
	var enemy := HollowEnemy.new()
	var kind := forced_kind
	if kind < 0:
		kind = _rng.randi_range(0, 2 if _elapsed > 35.0 else 1)
	enemy.configure(_player, kind, elite, boss)
	if is_instance_valid(_profile):
		if _profile.difficulty == 0:
			enemy.max_health *= 0.8
			enemy.health = enemy.max_health
			enemy.touch_damage *= 0.7
		elif _profile.difficulty == 2:
			enemy.max_health *= 1.25
			enemy.health = enemy.max_health
			enemy.touch_damage *= 1.2
			enemy.move_speed *= 1.12
	if boss:
		enemy.name = "TheIndexWarden"
	elif kind == 1:
		enemy.name = "Murmur"
	elif kind == 2:
		enemy.name = "Keeper"
	else:
		enemy.name = "GildedHollow" if elite else "Hollow"
	enemy.position = _arena.random_open_position(12.0, 18.0)
	enemy.defeated.connect(_on_enemy_defeated.bind(enemy))
	add_child(enemy)


@private
func _on_spawn_timer() -> void:
	var active_enemies := get_tree().get_nodes_in_group(&"enemies").size()
	if active_enemies < 7:
		_spawn_enemy(_elapsed > 55.0 and _rng.randf() < 0.12)


@private
func _on_shard_collected(shard: MemoryShard) -> void:
	_echoes += 1
	_soundscape.play_collect()
	_recovered_records.append(shard.record_id)
	_hud.set_objective(_echoes, _echo_goal, false)
	_hud.show_toast("ECHO RECOVERED // %d OF %d" % [_echoes, _echo_goal], shard.record_title, 3.7)
	_player.heal(5.0)
	if _echoes == 2 or _echoes == 5:
		_offer_boon.call_deferred()
	if _echoes >= _echo_goal and not _boss_active:
		_boss_active = true
		_hud.set_mandate("MANDATE — DISPERSE THE INDEX WARDEN", ArchivePalette.magenta())
		_hud.show_toast("THE INDEX WARDEN OBJECTS", "It was built to prevent unauthorized endings. Break its argument, then enter the seal.", 6.0)
		_spawn_enemy(true, true, 2)


@private
func _on_enemy_defeated(_at: Vector3, enemy: HollowEnemy) -> void:
	_kills += 1
	_player.reward_defeat()
	if _kills == 1:
		_hud.show_toast("HOLLOW DISPERSED", "Not killed. Returned to a memory without teeth.", 3.8)
	if enemy.is_boss:
		_boss_active = false
		_gate.activate()
		_hud.set_objective(_echoes, _echo_goal, true)
		_hud.show_toast("WARDEN DISPERSED // SEAL OPEN", "The Archive cannot stop you now. It can only remember what you choose next.", 6.0)


@private
func _offer_boon() -> void:
	if _finished or is_instance_valid(_boon_overlay):
		return
	var pool := BoonCatalog.base_ids()
	if is_instance_valid(_profile):
		for unlocked: String in _profile.unlocked_boons:
			var unlocked_id := StringName(unlocked)
			if unlocked_id not in pool:
				pool.append(unlocked_id)
	var choices: Array[StringName] = []
	while choices.size() < 3 and not pool.is_empty():
		var selected_index := _rng.randi_range(0, pool.size() - 1)
		choices.append(pool[selected_index])
		pool.remove_at(selected_index)
	_set_combat_paused(true)
	_boon_overlay = BoonChoiceOverlay.new()
	_boon_overlay.name = "BoonChoice"
	_boon_overlay.configure(choices)
	_boon_overlay.boon_selected.connect(_on_boon_selected)
	add_child(_boon_overlay)


@private
func _on_boon_selected(boon_id: StringName) -> void:
	_player.apply_boon(boon_id)
	var info := BoonCatalog.definition(boon_id)
	_hud.show_toast("ANNOTATION ACCEPTED // %s" % info.title, info.description, 4.0)
	if is_instance_valid(_boon_overlay):
		_boon_overlay.queue_free()
	_set_combat_paused(false)


@private
func _set_combat_paused(paused_now: bool) -> void:
	if is_instance_valid(_player):
		_player.set_physics_process(not paused_now)
	if is_instance_valid(_spawn_timer):
		_spawn_timer.paused = paused_now
	for enemy_node: Node in get_tree().get_nodes_in_group(&"enemies"):
		enemy_node.set_physics_process(not paused_now)
	for orb_node: Node in get_tree().get_nodes_in_group(&"enemy_projectiles"):
		orb_node.set_physics_process(not paused_now)


@private
func _on_resonance_cast(at: Vector3) -> void:
	_soundscape.play_resonance()
	var ring := MeshInstance3D.new()
	var mesh := TorusMesh.new()
	mesh.inner_radius = 0.8
	mesh.outer_radius = 0.9
	mesh.rings = 8
	mesh.ring_segments = 40
	ring.mesh = mesh
	ring.position = at + Vector3.UP * 0.12
	ring.material_override = ArchivePalette.make_material(ArchivePalette.cyan(), 3.5, 0.12)
	add_child(ring)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(ring, "scale", Vector3.ONE * 6.0, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(ring, "position:y", ring.position.y + 0.3, 0.42)
	tween.chain().tween_callback(ring.queue_free)


@private
func _on_gate_entered() -> void:
	_finish(true)


@private
func _on_player_died() -> void:
	_finish(false)


@private
func _finish(victory: bool) -> void:
	if _finished:
		return
	_finished = true
	_spawn_timer.stop()
	_player.set_physics_process(false)
	for enemy_node: Node in get_tree().get_nodes_in_group(&"enemies"):
		enemy_node.set_physics_process(false)
	_hud.show_result(victory, _echoes, _kills, _elapsed)


@private
func _on_return_requested() -> void:
	_emit_result(_echoes >= _echo_goal and _player.health > 0.0)


@private
func _emit_result(victory: bool) -> void:
	var result := ExpeditionResult.new()
	result.victory = victory
	result.echoes = _echoes
	result.hollows = _kills
	result.elapsed_seconds = _elapsed
	result.recovered_records = _recovered_records.duplicate()
	expedition_finished.emit(result)


@private
func _toggle_pause() -> void:
	if _finished:
		return
	if _manually_paused:
		_resume_from_pause()
	else:
		_manually_paused = true
		_set_combat_paused(true)
		_pause_overlay = PauseOverlay.new()
		_pause_overlay.name = "PauseOverlay"
		_pause_overlay.resume_requested.connect(_resume_from_pause)
		_pause_overlay.abandon_requested.connect(_abandon_expedition)
		add_child(_pause_overlay)


@private
func _resume_from_pause() -> void:
	_manually_paused = false
	if is_instance_valid(_pause_overlay):
		_pause_overlay.queue_free()
	_set_combat_paused(false)


@private
func _abandon_expedition() -> void:
	_manually_paused = false
	_finished = true
	_emit_result(false)
