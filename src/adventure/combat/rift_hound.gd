class_name AdventureRiftHound
extends CharacterBody3D

signal defeated(hound: AdventureRiftHound)

var target: WayfarerController
var health: float = 72.0
var active: bool = true

var _model: Node3D
var _front_left: Node3D
var _front_right: Node3D
var _back_left: Node3D
var _back_right: Node3D
var _gravity: float = 9.8
var _animation_time: float = 0.0
var _attack_cooldown: float = 1.0
var _windup: float = 0.0
var _has_struck: bool = false
var _home_position: Vector3


func configure(target_value: WayfarerController) -> void:
	target = target_value


@override
func _ready() -> void:
	name = "RiftHound"
	add_to_group(&"adventure_enemies")
	_home_position = global_position
	collision_layer = 4
	collision_mask = 1
	_gravity = float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.58
	shape.height = 1.45
	collision.shape = shape
	collision.position.y = 0.65
	add_child(collision)
	_model = AdventureAssetLibrary.instantiate_model("rift_hound")
	if is_instance_valid(_model):
		_model.name = "RiftHoundModel"
		add_child(_model)
		AdventureRigBinder.bind_hound(_model)
		_front_left = _model.find_child("FrontLegL", true, false) as Node3D
		_front_right = _model.find_child("FrontLegR", true, false) as Node3D
		_back_left = _model.find_child("BackLegL", true, false) as Node3D
		_back_right = _model.find_child("BackLegR", true, false) as Node3D
	_build_telegraph()


@private
func _build_telegraph() -> void:
	var ring := MeshInstance3D.new()
	ring.name = "AttackWarning"
	var mesh := TorusMesh.new()
	mesh.inner_radius = 1.35
	mesh.outer_radius = 1.48
	mesh.rings = 8
	mesh.ring_segments = 32
	ring.mesh = mesh
	ring.position.y = 0.06
	var material := AdventureAssetLibrary.material(Color("c92848"), 0.4, Color("e62f53"), 1.8)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 0.78
	ring.material_override = material
	ring.visible = false
	add_child(ring)


@override
func _physics_process(delta: float) -> void:
	_animation_time += delta
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	if not is_on_floor():
		velocity.y -= _gravity * delta
	if not active or not is_instance_valid(target):
		velocity.x = move_toward(velocity.x, 0.0, delta * 8.0)
		velocity.z = move_toward(velocity.z, 0.0, delta * 8.0)
		move_and_slide()
		_animate_legs(0.0)
		return
	var to_target := target.global_position - global_position
	to_target.y = 0.0
	var distance := to_target.length()
	if target.global_position.x < 28.0 or global_position.distance_to(_home_position) > 22.0:
		_return_home(delta)
		return
	if _windup > 0.0:
		_windup -= delta
		velocity.x = 0.0
		velocity.z = 0.0
		if _windup <= 0.18 and not _has_struck:
			_has_struck = true
			_strike_target()
		if _windup <= 0.0:
			_set_warning_visible(false)
			_attack_cooldown = 1.45
	else:
		if distance > 1.75:
			var direction := to_target.normalized()
			velocity.x = direction.x * 3.15
			velocity.z = direction.z * 3.15
			rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), 1.0 - exp(-delta * 8.0))
		elif _attack_cooldown <= 0.0:
			_begin_attack()
		else:
			velocity.x = move_toward(velocity.x, 0.0, delta * 9.0)
			velocity.z = move_toward(velocity.z, 0.0, delta * 9.0)
	move_and_slide()
	_animate_legs(Vector2(velocity.x, velocity.z).length())


@private
func _return_home(delta: float) -> void:
	var offset := _home_position - global_position
	offset.y = 0.0
	if offset.length() > 0.8:
		var direction := offset.normalized()
		velocity.x = direction.x * 4.2
		velocity.z = direction.z * 4.2
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), 1.0 - exp(-delta * 8.0))
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	move_and_slide()
	_animate_legs(Vector2(velocity.x, velocity.z).length())


@private
func _begin_attack() -> void:
	_windup = 0.7
	_has_struck = false
	_set_warning_visible(true)
	if is_instance_valid(_model):
		var tween := create_tween()
		tween.tween_property(_model, "scale", Vector3(1.12, 0.82, 1.12), 0.45).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(_model, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK)


@private
func _strike_target() -> void:
	if is_instance_valid(target) and global_position.distance_to(target.global_position) < 2.35:
		target.take_damage(16.0, global_position)


func take_damage(amount: float) -> void:
	if not active or amount <= 0.0:
		return
	health -= amount
	if is_instance_valid(_model):
		var tween := create_tween()
		tween.tween_property(_model, "scale", Vector3(1.18, 0.8, 1.18), 0.07)
		tween.tween_property(_model, "scale", Vector3.ONE, 0.13)
	if health <= 0.0:
		_defeat()


@private
func _defeat() -> void:
	active = false
	remove_from_group(&"adventure_enemies")
	_set_warning_visible(false)
	velocity = Vector3.ZERO
	if is_instance_valid(_model):
		var tween := create_tween()
		tween.tween_property(_model, "rotation:z", 1.15, 0.48).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	defeated.emit(self)


@private
func _set_warning_visible(visible_value: bool) -> void:
	var warning := get_node_or_null("AttackWarning") as MeshInstance3D
	if is_instance_valid(warning):
		warning.visible = visible_value


@private
func _animate_legs(speed: float) -> void:
	var amount := clampf(speed / 3.15, 0.0, 1.0)
	var swing := sin(_animation_time * 10.0) * 0.62 * amount
	_set_leg(_front_left, swing)
	_set_leg(_back_right, swing)
	_set_leg(_front_right, -swing)
	_set_leg(_back_left, -swing)


@private
func _set_leg(leg: Node3D, angle: float) -> void:
	if is_instance_valid(leg):
		leg.rotation.x = angle
