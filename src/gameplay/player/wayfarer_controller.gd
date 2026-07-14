class_name WayfarerController
extends CharacterBody3D

signal interaction_requested
signal attack_started
signal health_changed(current: float, maximum: float)
signal defeated

var walk_speed: float = 4.6
var sprint_speed: float = 7.4
var acceleration: float = 18.0
var air_acceleration: float = 6.0
var jump_velocity: float = 5.8
var input_enabled: bool = true
var current_health: float = 100.0
var maximum_health: float = 100.0

var _camera: Camera3D
var _avatar: Node3D
var _upper_arm_left: Node3D
var _upper_arm_right: Node3D
var _thigh_left: Node3D
var _thigh_right: Node3D
var _shin_left: Node3D
var _shin_right: Node3D
var _forearm_right: Node3D
var _hand_right: Node3D
var _weapon_root: Node3D
var _animation_time: float = 0.0
var _attack_time: float = 0.0
var _weapon_draw_time: float = 0.0
var _attack_has_connected: bool = false
var _combo_side: float = 1.0
var _gravity: float = 9.8
var _hurt_immunity: float = 0.0

const ATTACK_DURATION := 0.48


func set_camera(camera: Camera3D) -> void:
	_camera = camera


func configure_health(current: float, maximum: float) -> void:
	maximum_health = maxf(1.0, maximum)
	current_health = clampf(current, 1.0, maximum_health)
	health_changed.emit(current_health, maximum_health)


@override
func _ready() -> void:
	name = "Wayfarer"
	collision_layer = PhysicsLayers.Id.PLAYER
	collision_mask = PhysicsLayers.Id.WORLD
	_gravity = float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))
	_build_player()


@private
func _build_player() -> void:
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.37
	capsule.height = 1.76
	collision.shape = capsule
	collision.position.y = 0.88
	add_child(collision)
	_avatar = ModelLibrary.instantiate_model(ModelCatalog.Id.WAYFARER)
	if is_instance_valid(_avatar):
		_avatar.name = "WayfarerAvatar"
		_avatar.rotation.y = PI
		add_child(_avatar)
		HumanoidRigBinder.bind(_avatar)
		_upper_arm_left = _avatar.find_child("UpperArmL", true, false) as Node3D
		_upper_arm_right = _avatar.find_child("UpperArmR", true, false) as Node3D
		_forearm_right = _avatar.find_child("ForearmR", true, false) as Node3D
		_hand_right = _avatar.find_child("HandR", true, false) as Node3D
		_thigh_left = _avatar.find_child("ThighL", true, false) as Node3D
		_thigh_right = _avatar.find_child("ThighR", true, false) as Node3D
		_shin_left = _avatar.find_child("ShinL", true, false) as Node3D
		_shin_right = _avatar.find_child("ShinR", true, false) as Node3D
		_build_drawn_sword()


@private
func _build_drawn_sword() -> void:
	if not is_instance_valid(_hand_right):
		return
	_weapon_root = Node3D.new()
	_weapon_root.name = "DrawnLumenSword"
	_weapon_root.position = Vector3(0.0, -0.02, -0.06)
	_weapon_root.rotation = Vector3(0.0, 0.0, -0.08)
	_hand_right.add_child(_weapon_root)
	var grip := MeshInstance3D.new()
	var grip_mesh := CylinderMesh.new()
	grip_mesh.top_radius = 0.035
	grip_mesh.bottom_radius = 0.035
	grip_mesh.height = 0.34
	grip_mesh.radial_segments = 8
	grip.mesh = grip_mesh
	grip.material_override = ModelLibrary.material(Color("4a2818"), 0.8)
	_weapon_root.add_child(grip)
	var guard := MeshInstance3D.new()
	var guard_mesh := BoxMesh.new()
	guard_mesh.size = Vector3(0.42, 0.055, 0.075)
	guard.mesh = guard_mesh
	guard.position.y = 0.19
	guard.material_override = ModelLibrary.material(Color("c48b34"), 0.3, Color("e2ad52"), 0.45)
	_weapon_root.add_child(guard)
	var blade := MeshInstance3D.new()
	var blade_mesh := PrismMesh.new()
	blade_mesh.size = Vector3(0.095, 1.1, 0.045)
	blade.mesh = blade_mesh
	blade.position.y = 0.76
	blade.material_override = ModelLibrary.material(Color("b9dce4"), 0.2, Color("62cce8"), 0.75)
	_weapon_root.add_child(blade)
	_weapon_root.visible = false


@override
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if input_enabled and _attack_time <= 0.0 and button.pressed and button.button_index == MOUSE_BUTTON_LEFT and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_attack_time = ATTACK_DURATION
			_weapon_draw_time = 1.45
			_attack_has_connected = false
			_combo_side *= -1.0
			if is_instance_valid(_weapon_root):
				_weapon_root.visible = true


@override
func _physics_process(delta: float) -> void:
	_animation_time += delta
	_attack_time = maxf(0.0, _attack_time - delta)
	_weapon_draw_time = maxf(0.0, _weapon_draw_time - delta)
	_hurt_immunity = maxf(0.0, _hurt_immunity - delta)
	if _attack_time > 0.0:
		var attack_progress := 1.0 - _attack_time / ATTACK_DURATION
		if attack_progress >= 0.38 and not _attack_has_connected:
			_attack_has_connected = true
			attack_started.emit()
	elif _weapon_draw_time <= 0.0 and is_instance_valid(_weapon_root):
		_weapon_root.visible = false
	if not is_on_floor():
		velocity.y -= _gravity * delta
	elif input_enabled and Input.is_action_just_pressed(&"jump"):
		velocity.y = jump_velocity

	var input_vector := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back") if input_enabled else Vector2.ZERO
	var desired_direction := _camera_relative_direction(input_vector)
	var target_speed := sprint_speed if Input.is_action_pressed(&"sprint") else walk_speed
	var target_velocity := desired_direction * target_speed
	var active_acceleration := acceleration if is_on_floor() else air_acceleration
	velocity.x = move_toward(velocity.x, target_velocity.x, active_acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, active_acceleration * delta)
	if desired_direction.length_squared() > 0.001:
		var desired_yaw := atan2(-desired_direction.x, -desired_direction.z)
		rotation.y = lerp_angle(rotation.y, desired_yaw, 1.0 - exp(-delta * 13.0))
	move_and_slide()
	_animate_avatar(input_vector.length(), target_speed, delta)
	if input_enabled and Input.is_action_just_pressed(&"interact"):
		interaction_requested.emit()


func take_damage(amount: float, source_position: Vector3) -> void:
	if amount <= 0.0 or _hurt_immunity > 0.0 or current_health <= 0.0:
		return
	_hurt_immunity = 0.72
	current_health = maxf(0.0, current_health - amount)
	var impact := ImpactBurst.new()
	impact.configure(Color("f06a5f"))
	get_parent().add_child(impact)
	impact.global_position = global_position + Vector3.UP * 1.0
	var away := global_position - source_position
	away.y = 0.0
	if away.length_squared() > 0.01:
		away = away.normalized()
		velocity += away * 4.0 + Vector3.UP * 1.4
	health_changed.emit(current_health, maximum_health)
	if is_instance_valid(_avatar):
		var tween := create_tween()
		tween.tween_property(_avatar, "scale", Vector3(1.12, 0.86, 1.12), 0.08)
		tween.tween_property(_avatar, "scale", Vector3.ONE, 0.16)
	if current_health <= 0.0:
		input_enabled = false
		defeated.emit()


func restore_full_health() -> void:
	current_health = maximum_health
	input_enabled = true
	health_changed.emit(current_health, maximum_health)


@private
func _camera_relative_direction(input_vector: Vector2) -> Vector3:
	if not is_instance_valid(_camera) or input_vector.length_squared() < 0.001:
		return Vector3.ZERO
	var forward := -_camera.global_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := _camera.global_basis.x
	right.y = 0.0
	right = right.normalized()
	return (right * input_vector.x + forward * -input_vector.y).normalized()


@private
func _animate_avatar(input_strength: float, current_speed: float, delta: float) -> void:
	if not is_instance_valid(_avatar):
		return
	var movement_amount := clampf(input_strength, 0.0, 1.0)
	var cycle_speed := 7.5 if current_speed <= walk_speed + 0.1 else 11.0
	var swing := sin(_animation_time * cycle_speed) * 0.46 * movement_amount
	_set_limb_rotation(_thigh_left, Vector3(swing, 0.0, 0.0))
	_set_limb_rotation(_thigh_right, Vector3(-swing, 0.0, 0.0))
	_set_limb_rotation(_shin_left, Vector3(maxf(0.0, -swing) * 0.62, 0.0, 0.0))
	_set_limb_rotation(_shin_right, Vector3(maxf(0.0, swing) * 0.62, 0.0, 0.0))
	_set_limb_rotation(_upper_arm_left, Vector3(-swing * 0.72, 0.0, 0.0))
	if _attack_time <= 0.0:
		_set_limb_rotation(_upper_arm_right, Vector3(swing * 0.72, 0.0, 0.0))
		_set_limb_rotation(_forearm_right, Vector3.ZERO)
	else:
		var attack_progress := 1.0 - _attack_time / ATTACK_DURATION
		var anticipation := smoothstep(0.0, 0.24, attack_progress)
		var release := smoothstep(0.22, 0.7, attack_progress)
		var recovery := smoothstep(0.7, 1.0, attack_progress)
		var sweep := anticipation * (1.0 - recovery)
		var side_twist := lerpf(0.9 * _combo_side, -1.05 * _combo_side, release)
		_set_limb_rotation(_upper_arm_right, Vector3(-0.55 - 1.05 * sweep, side_twist * 0.25, side_twist))
		_set_limb_rotation(_forearm_right, Vector3(-0.35 - 0.85 * sweep, 0.0, -side_twist * 0.22))
	_avatar.position.y = sin(_animation_time * cycle_speed * 2.0) * 0.025 * movement_amount
	_avatar.rotation.z = lerp_angle(_avatar.rotation.z, -velocity.x * 0.006, 1.0 - exp(-delta * 9.0))


@private
func _set_limb_rotation(limb: Node3D, target_rotation: Vector3) -> void:
	if is_instance_valid(limb):
		limb.rotation = target_rotation
