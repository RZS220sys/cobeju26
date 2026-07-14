class_name HollowEnemy
extends CharacterBody3D

signal defeated(position_now: Vector3)
signal health_changed(current: float, maximum: float)

var target: ArchivistController
var max_health: float = 58.0
var health: float = 58.0
var move_speed: float = 3.2
var touch_damage: float = 8.0
var is_elite: bool = false
var enemy_kind: int = 0
var is_boss: bool = false

var _attack_cooldown: float = 0.0
var _stagger_velocity: Vector3 = Vector3.ZERO
var _special_cooldown: float = 2.2
var _visual: MeshInstance3D
var _model_visual: Node3D


@override
func _ready() -> void:
	add_to_group(&"enemies")
	collision_layer = 2
	collision_mask = 32
	_build_body()


func configure(chase_target: ArchivistController, kind: int = 0, elite: bool = false, boss: bool = false) -> void:
	target = chase_target
	enemy_kind = kind
	is_elite = elite
	is_boss = boss
	if elite:
		max_health = 125.0
		health = max_health
		move_speed = 2.75
		touch_damage = 15.0
	if enemy_kind == 1:
		max_health = 42.0 if not elite else 92.0
		health = max_health
		move_speed = 2.8
		touch_damage = 6.0
	if enemy_kind == 2:
		max_health = 105.0 if not elite else 175.0
		health = max_health
		move_speed = 2.15
		touch_damage = 14.0
	if is_boss:
		max_health = 360.0
		health = max_health
		move_speed = 2.45
		touch_damage = 18.0


@private
func _build_body() -> void:
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.46 if not is_elite else 0.67
	capsule.height = 1.5 if not is_elite else 2.05
	if is_boss:
		capsule.radius = 0.88
		capsule.height = 2.65
	collision.shape = capsule
	collision.position.y = capsule.height * 0.5
	add_child(collision)

	_visual = MeshInstance3D.new()
	var mesh := PrismMesh.new()
	mesh.size = Vector3(0.95, 1.45, 0.78) if not is_elite else Vector3(1.38, 2.0, 1.12)
	if enemy_kind == 1:
		mesh.size = Vector3(0.72, 1.22, 0.66) if not is_elite else Vector3(1.0, 1.62, 0.85)
	elif enemy_kind == 2:
		mesh.size = Vector3(1.15, 1.7, 1.0) if not is_elite else Vector3(1.52, 2.18, 1.28)
	if is_boss:
		mesh.size = Vector3(1.78, 2.62, 1.48)
	_visual.mesh = mesh
	_visual.position.y = capsule.height * 0.52
	var color := ArchivePalette.magenta() if is_elite else Color("36556b")
	if enemy_kind == 1:
		color = Color("76577f") if not is_elite else ArchivePalette.magenta()
	elif enemy_kind == 2:
		color = Color("59624b") if not is_elite else ArchivePalette.brass().darkened(0.2)
	if is_boss:
		color = Color("a74c78")
	_visual.material_override = ArchivePalette.make_material(color, 0.8 if is_elite else 0.16, 0.42)
	add_child(_visual)

	var eye := MeshInstance3D.new()
	var eye_mesh := SphereMesh.new()
	eye_mesh.radius = 0.12 if not is_elite else 0.19
	eye_mesh.height = eye_mesh.radius * 2.0
	eye_mesh.radial_segments = 10
	eye_mesh.rings = 5
	eye.mesh = eye_mesh
	eye.position = Vector3(0.0, capsule.height * 0.72, -0.43 if not is_elite else -0.61)
	eye.material_override = ArchivePalette.make_material(ArchivePalette.magenta(), 4.0, 0.1)
	add_child(eye)

	_model_visual = ArchiveModelLibrary.instantiate_model(ArchiveModelLibrary.enemy_path(enemy_kind, is_boss))
	if is_instance_valid(_model_visual):
		_model_visual.name = "HollowModel"
		_model_visual.rotation.y = PI
		if is_elite and not is_boss:
			_model_visual.scale = Vector3.ONE * 1.15
		add_child(_model_visual)
		_visual.visible = false
		eye.visible = false


@override
func _physics_process(delta: float) -> void:
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	_special_cooldown = maxf(0.0, _special_cooldown - delta)
	_stagger_velocity = _stagger_velocity.move_toward(Vector3.ZERO, delta * 18.0)
	if not is_instance_valid(target) or target.health <= 0.0:
		velocity = Vector3.ZERO
		return
	var direction := target.global_position - global_position
	direction.y = 0.0
	var distance := direction.length()
	if is_boss and _special_cooldown <= 0.0:
		_special_cooldown = 3.2 if health < max_health * 0.5 else 4.25
		_fire_mandate()
	if distance > 0.05:
		direction /= distance
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), minf(1.0, delta * 8.0))
	if enemy_kind == 1:
		if distance < 4.25:
			direction = -direction
		elif distance < 7.0:
			direction = Vector3.ZERO
		velocity = direction * move_speed + _stagger_velocity
		if distance < 10.5 and _attack_cooldown <= 0.0:
			_attack_cooldown = 2.3 if not is_elite else 1.65
			_fire_orb()
	else:
		velocity = direction * move_speed + _stagger_velocity
	move_and_slide()
	if enemy_kind != 1 and distance < (1.25 if is_elite else 0.95) and _attack_cooldown <= 0.0:
		_attack_cooldown = 1.3 if is_elite else 1.65
		target.take_damage(touch_damage)


func take_damage(amount: float, push: Vector3 = Vector3.ZERO) -> void:
	if health <= 0.0:
		return
	health -= amount
	health_changed.emit(maxf(0.0, health), max_health)
	_stagger_velocity += push * (2.1 if not is_elite else 0.8)
	if is_instance_valid(_model_visual):
		var hit_tween := create_tween()
		var original_scale := _model_visual.scale
		hit_tween.tween_property(_model_visual, "scale", original_scale * 1.16, 0.055)
		hit_tween.tween_property(_model_visual, "scale", original_scale, 0.11)
	elif is_instance_valid(_visual):
		var original_material := _visual.material_override
		_visual.material_override = ArchivePalette.make_material(ArchivePalette.bone(), 2.8, 0.2)
		var tween := create_tween()
		tween.tween_interval(0.075)
		tween.tween_callback(func() -> void:
			if is_instance_valid(_visual):
				_visual.material_override = original_material
		)
	if health <= 0.0:
		defeated.emit(global_position)
		queue_free()


@private
func _fire_orb() -> void:
	if not is_instance_valid(target):
		return
	var shot_direction := target.global_position - global_position
	shot_direction.y = 0.0
	var orb := HollowOrb.new()
	orb.configure(shot_direction, 14.0 if is_elite else 9.0)
	get_parent().add_child(orb)
	orb.global_position = global_position + Vector3.UP * 1.0 + shot_direction.normalized() * 0.7


@private
func _fire_mandate() -> void:
	var projectile_count := 12 if health < max_health * 0.5 else 8
	for index: int in range(projectile_count):
		var angle := float(index) / float(projectile_count) * TAU
		var shot_direction := Vector3(cos(angle), 0.0, sin(angle))
		var orb := HollowOrb.new()
		orb.configure(shot_direction, 10.0)
		orb.speed = 6.2 if health >= max_health * 0.5 else 7.4
		get_parent().add_child(orb)
		orb.global_position = global_position + Vector3.UP * 1.0 + shot_direction * 1.0
