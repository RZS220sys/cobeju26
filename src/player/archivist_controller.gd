class_name ArchivistController
extends CharacterBody3D

signal health_changed(current: float, maximum: float)
signal focus_changed(current: float, maximum: float)
signal died
signal resonance_cast(position_now: Vector3)
signal pulse_cast
signal hurt

var max_health: float = 120.0
var health: float = 120.0
var max_focus: float = 100.0
var focus: float = 100.0
var move_speed: float = 7.0
var pulse_damage: float = 25.0
var attack_interval: float = 0.27
var focus_regeneration: float = 11.0
var resonance_damage: float = 38.0
var resonance_radius: float = 5.25
var dash_cooldown_duration: float = 1.05
var damage_reduction: float = 0.0
var healing_per_defeat: float = 0.0
var focus_per_defeat: float = 0.0
var aim_assist: bool = true

var _attack_cooldown: float = 0.0
var _dash_cooldown: float = 0.0
var _dash_time: float = 0.0
var _dash_direction: Vector3 = Vector3.ZERO
var _invulnerable_time: float = 0.0
var _camera: Camera3D
var _body_visual: MeshInstance3D
var _model_visual: Node3D
var _camera_shake: float = 0.0
var _camera_time: float = 0.0


@override
func _ready() -> void:
	name = "Archivist"
	add_to_group(&"player")
	collision_layer = 1
	collision_mask = 32
	_build_body()
	health_changed.emit(health, max_health)
	focus_changed.emit(focus, max_focus)


@private
func _build_body() -> void:
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.38
	capsule.height = 1.7
	collision.shape = capsule
	collision.position.y = 0.85
	add_child(collision)

	_body_visual = MeshInstance3D.new()
	var body_mesh := CylinderMesh.new()
	body_mesh.top_radius = 0.26
	body_mesh.bottom_radius = 0.48
	body_mesh.height = 1.35
	body_mesh.radial_segments = 8
	_body_visual.mesh = body_mesh
	_body_visual.position.y = 0.83
	_body_visual.material_override = ArchivePalette.make_material(Color("263a47"), 0.0, 0.58)
	add_child(_body_visual)

	var mantle := MeshInstance3D.new()
	var mantle_mesh := TorusMesh.new()
	mantle_mesh.inner_radius = 0.32
	mantle_mesh.outer_radius = 0.53
	mantle_mesh.rings = 8
	mantle_mesh.ring_segments = 12
	mantle.mesh = mantle_mesh
	mantle.position.y = 1.35
	mantle.material_override = ArchivePalette.make_material(ArchivePalette.brass(), 0.25, 0.45)
	add_child(mantle)

	var lantern := MeshInstance3D.new()
	var lantern_mesh := SphereMesh.new()
	lantern_mesh.radius = 0.18
	lantern_mesh.height = 0.36
	lantern_mesh.radial_segments = 12
	lantern_mesh.rings = 6
	lantern.mesh = lantern_mesh
	lantern.position = Vector3(0.0, 1.43, -0.43)
	lantern.material_override = ArchivePalette.make_material(ArchivePalette.amber(), 4.5, 0.12)
	add_child(lantern)

	var lantern_light := OmniLight3D.new()
	lantern_light.position = lantern.position
	lantern_light.light_color = ArchivePalette.amber()
	lantern_light.light_energy = 4.0
	lantern_light.omni_range = 8.0
	lantern_light.shadow_enabled = true
	lantern_light.shadow_opacity = 0.5
	add_child(lantern_light)

	_model_visual = ArchiveModelLibrary.instantiate_model("res://assets/models/archivist.glb")
	if is_instance_valid(_model_visual):
		_model_visual.name = "LamplighterModel"
		_model_visual.rotation.y = PI
		add_child(_model_visual)
		_body_visual.visible = false
		mantle.visible = false
		lantern.visible = false

	_camera = Camera3D.new()
	_camera.name = "ExpeditionCamera"
	_camera.position = Vector3(0.0, 13.0, 10.5)
	_camera.rotation_degrees = Vector3(-49.0, 0.0, 0.0)
	_camera.fov = 49.0
	_camera.current = true
	add_child(_camera)


@override
func _physics_process(delta: float) -> void:
	_camera_time += delta
	_camera_shake = maxf(0.0, _camera_shake - delta * 2.8)
	if is_instance_valid(_camera):
		var shake_amount := _camera_shake * _camera_shake * 0.22
		_camera.position = Vector3(0.0, 13.0, 10.5) + Vector3(sin(_camera_time * 61.0), sin(_camera_time * 47.0), 0.0) * shake_amount
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	_dash_cooldown = maxf(0.0, _dash_cooldown - delta)
	_invulnerable_time = maxf(0.0, _invulnerable_time - delta)
	focus = minf(max_focus, focus + delta * focus_regeneration)
	focus_changed.emit(focus, max_focus)

	var input_vector := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	var desired := Vector3(input_vector.x, 0.0, input_vector.y)
	if desired.length_squared() > 0.01:
		desired = desired.normalized()
		rotation.y = lerp_angle(rotation.y, atan2(-desired.x, -desired.z), minf(1.0, delta * 14.0))

	if Input.is_action_just_pressed(&"dash") and _dash_cooldown <= 0.0 and desired.length_squared() > 0.0:
		_dash_time = 0.18
		_dash_cooldown = dash_cooldown_duration
		_dash_direction = desired
		_invulnerable_time = 0.28

	if _dash_time > 0.0:
		_dash_time -= delta
		velocity = _dash_direction * move_speed * 3.0
	else:
		velocity = desired * move_speed
	move_and_slide()
	var arena_offset := Vector2(global_position.x, global_position.z)
	if arena_offset.length() > 18.8:
		arena_offset = arena_offset.normalized() * 18.8
		global_position.x = arena_offset.x
		global_position.z = arena_offset.y

	if Input.is_action_pressed(&"attack") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_try_attack()
	if Input.is_action_just_pressed(&"resonance"):
		_try_resonance()


@private
func _try_attack() -> void:
	if _attack_cooldown > 0.0:
		return
	_attack_cooldown = attack_interval
	var travel_direction := _aim_direction()
	var bolt := EchoBolt.new()
	bolt.configure(self, travel_direction, pulse_damage)
	get_parent().add_child(bolt)
	bolt.global_position = global_position + Vector3.UP * 0.95 + travel_direction * 0.62
	rotation.y = atan2(-travel_direction.x, -travel_direction.z)
	pulse_cast.emit()


@private
func _aim_direction() -> Vector3:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and is_instance_valid(_camera):
		var mouse_position := get_viewport().get_mouse_position()
		var ray_origin := _camera.project_ray_origin(mouse_position)
		var ray_direction := _camera.project_ray_normal(mouse_position)
		if absf(ray_direction.y) > 0.0001:
			var distance_to_plane := (global_position.y + 0.35 - ray_origin.y) / ray_direction.y
			var intersection := ray_origin + ray_direction * distance_to_plane
			var mouse_direction := intersection - global_position
			mouse_direction.y = 0.0
			if mouse_direction.length_squared() > 0.1:
				return mouse_direction.normalized()
	if not aim_assist:
		return -global_basis.z.normalized()
	var nearest: HollowEnemy
	var nearest_distance := INF
	for candidate: Node in get_tree().get_nodes_in_group(&"enemies"):
		if candidate is HollowEnemy:
			var distance := global_position.distance_squared_to(candidate.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest = candidate
	if is_instance_valid(nearest):
		var enemy_direction := nearest.global_position - global_position
		enemy_direction.y = 0.0
		return enemy_direction.normalized()
	return -global_basis.z.normalized()


@private
func _try_resonance() -> void:
	if focus < 40.0:
		return
	focus -= 40.0
	focus_changed.emit(focus, max_focus)
	resonance_cast.emit(global_position)
	_camera_shake = maxf(_camera_shake, 0.58)
	if not Input.get_connected_joypads().is_empty():
		Input.start_joy_vibration(Input.get_connected_joypads()[0], 0.18, 0.32, 0.18)
	for candidate: Node in get_tree().get_nodes_in_group(&"enemies"):
		if candidate is HollowEnemy:
			var hollow := candidate as HollowEnemy
			if global_position.distance_to(hollow.global_position) <= resonance_radius:
				var push_direction := hollow.global_position - global_position
				push_direction.y = 0.0
				hollow.take_damage(resonance_damage, push_direction.normalized() * 2.0)


func take_damage(amount: float) -> void:
	if _invulnerable_time > 0.0 or health <= 0.0:
		return
	health = maxf(0.0, health - amount * (1.0 - damage_reduction))
	_invulnerable_time = 0.55
	health_changed.emit(health, max_health)
	hurt.emit()
	_camera_shake = 1.0
	if not Input.get_connected_joypads().is_empty():
		Input.start_joy_vibration(Input.get_connected_joypads()[0], 0.35, 0.62, 0.14)
	if is_instance_valid(_model_visual):
		var model_tween := create_tween()
		model_tween.tween_property(_model_visual, "scale", Vector3(1.2, 0.84, 1.2), 0.07)
		model_tween.tween_property(_model_visual, "scale", Vector3.ONE, 0.14)
	elif is_instance_valid(_body_visual):
		var tween := create_tween()
		tween.tween_property(_body_visual, "scale", Vector3(1.25, 0.82, 1.25), 0.07)
		tween.tween_property(_body_visual, "scale", Vector3.ONE, 0.14)
	if health <= 0.0:
		died.emit()


func heal(amount: float) -> void:
	health = minf(max_health, health + amount)
	health_changed.emit(health, max_health)


func reward_defeat() -> void:
	heal(healing_per_defeat)
	focus = minf(max_focus, focus + focus_per_defeat)
	focus_changed.emit(focus, max_focus)


func apply_boon(boon_id: StringName) -> void:
	match boon_id:
		&"steady_wick":
			max_health += 25.0
			heal(25.0)
		&"amber_edge":
			pulse_damage += 8.0
		&"fleet_footnote":
			move_speed *= 1.15
		&"deep_breath":
			max_focus += 30.0
			focus += 30.0
			focus_regeneration *= 1.2
		&"nearer_echo":
			resonance_radius *= 1.25
			resonance_damage *= 1.25
		&"borrowed_hour":
			attack_interval *= 0.82
		&"open_hand":
			healing_per_defeat += 4.0
		&"salt_insulation":
			damage_reduction = minf(0.5, damage_reduction + 0.15)
		&"unbroken_testimony":
			pulse_damage += 12.0
			max_health = maxf(60.0, max_health - 12.0)
			health = minf(health, max_health)
		&"kind_ending":
			healing_per_defeat += 8.0
			focus_per_defeat += 5.0
		&"golden_revision":
			move_speed *= 1.2
			attack_interval *= 0.8
			pulse_damage *= 0.9
	health_changed.emit(health, max_health)
	focus_changed.emit(focus, max_focus)
