class_name PlayerCoordinator
extends Node

var player: WayfarerController
var camera_rig: ThirdPersonCamera
var world_state: GameWorldState
var hud: GameHud
var soundscape: GameSoundscape
var quests: QuestCoordinator
var persistence: WorldPersistenceController
var _last_safe_position: Vector3 = Vector3(0.0, 0.1, 9.0)


func configure(player_controller: WayfarerController, camera_controller: ThirdPersonCamera, state: GameWorldState, game_hud: GameHud, audio: GameSoundscape, quest_coordinator: QuestCoordinator, persistence_controller: WorldPersistenceController) -> void:
	player = player_controller
	camera_rig = camera_controller
	world_state = state
	hud = game_hud
	soundscape = audio
	quests = quest_coordinator
	persistence = persistence_controller


@override
func _ready() -> void:
	player.set_camera(camera_rig.get_player_camera())
	player.attack_started.connect(_on_attack_started)
	player.attack_started.connect(soundscape.play_sword)
	player.health_changed.connect(_on_health_changed)
	player.health_changed.connect(soundscape.on_health_changed)
	player.defeated.connect(_on_defeated)
	_last_safe_position = player.global_position
	hud.set_health(player.current_health, player.maximum_health)
	refresh_inventory_hud()


@override
func _process(_delta: float) -> void:
	if player.is_on_floor() and player.global_position.y > -5.0:
		_last_safe_position = player.global_position
	if player.global_position.y < -35.0:
		player.global_position = _last_safe_position + Vector3.UP * 0.8
		player.velocity = Vector3.ZERO


func refresh_inventory_hud() -> void:
	hud.set_lens_owned(Inventory.count(world_state, ItemCatalog.Id.LANTERN_LENS) > 0)


@private
func _on_attack_started() -> void:
	var nearest: BeastNpc
	var nearest_distance := 3.0
	var forward := -player.global_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	for candidate: Node in get_tree().get_nodes_in_group(&"enemies"):
		if candidate is BeastNpc:
			var beast := candidate as BeastNpc
			var offset := beast.global_position - player.global_position
			offset.y = 0.0
			var distance := offset.length()
			if distance < nearest_distance and distance > 0.01 and forward.dot(offset / distance) > 0.05:
				nearest = beast
				nearest_distance = distance
	if is_instance_valid(nearest):
		nearest.take_damage(28.0)


@private
func _on_health_changed(current: float, maximum: float) -> void:
	world_state.current_health = current
	world_state.maximum_health = maximum
	hud.set_health(current, maximum)


@private
func _on_defeated() -> void:
	hud.show_dialogue("Mara", "Breathe. The village lanterns still know your name.", 4.5)
	quests.on_player_rescued()
	player.global_position = Vector3(0.0, 0.6, -10.5)
	player.velocity = Vector3.ZERO
	player.restore_full_health()
	persistence.save_checkpoint()
