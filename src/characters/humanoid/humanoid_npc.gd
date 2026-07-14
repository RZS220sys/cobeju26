class_name HumanoidNpc
extends NpcActor

var _model: Node3D
var _upper_arm_right: Node3D
var _upper_arm_left: Node3D
var _thigh_right: Node3D
var _thigh_left: Node3D
var _animation_time: float = 0.0
var _wave_time: float = 0.0
var _routine_index: int = 0
var _routine_wait: float = 0.0
var _routine_points: Array[Vector3] = []
var _gravity: float = 9.8


@override
func _ready() -> void:
	super()
	add_to_group(&"interactables")
	_gravity = float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))


@override
func shows_interaction_marker() -> bool:
	return true


@override
func build_visual() -> void:
	_model = ModelLibrary.instantiate_model(model_id)
	if not is_instance_valid(_model):
		return
	_model.name = "%sModel" % display_name
	add_child(_model)
	HumanoidRigBinder.bind(_model)
	_upper_arm_right = _model.find_child("UpperArmR", true, false) as Node3D
	_upper_arm_left = _model.find_child("UpperArmL", true, false) as Node3D
	_thigh_right = _model.find_child("ThighR", true, false) as Node3D
	_thigh_left = _model.find_child("ThighL", true, false) as Node3D


@override
func configure_behavior() -> void:
	_routine_points = routine_points()
	persistent_state.behavior = NpcCatalog.Behavior.ROUTINE if _routine_points.size() > 1 else NpcCatalog.Behavior.IDLE


func routine_points() -> Array[Vector3]:
	return [] as Array[Vector3]


func routine_speed() -> float:
	return 1.25


func routine_pause(index: int) -> float:
	return 1.8 + float((index + npc_id) % 4) * 0.7


@override
func _physics_process(delta: float) -> void:
	_animation_time += delta
	_wave_time = maxf(0.0, _wave_time - delta)
	_routine_wait = maxf(0.0, _routine_wait - delta)
	if not is_on_floor():
		velocity.y -= _gravity * delta
	var walking := _update_routine(delta)
	move_and_slide()
	_animate(walking)


@override
func greet(player_position: Vector3) -> void:
	var direction := player_position - global_position
	direction.y = 0.0
	if direction.length_squared() > 0.01:
		rotation.y = atan2(-direction.x, -direction.z) + PI
	_wave_time = 1.8
	_routine_wait = maxf(_routine_wait, 2.5)
	persistent_state.behavior = NpcCatalog.Behavior.CONVERSING
	remember_event(NpcCatalog.Event.MET_WAYFARER)


@private
func _update_routine(delta: float) -> bool:
	if _routine_points.size() < 2 or _routine_wait > 0.0 or _wave_time > 0.0:
		velocity.x = move_toward(velocity.x, 0.0, delta * 8.0)
		velocity.z = move_toward(velocity.z, 0.0, delta * 8.0)
		return false
	var offset := _routine_points[_routine_index] - global_position
	offset.y = 0.0
	if offset.length() < 0.18:
		_routine_index = (_routine_index + 1) % _routine_points.size()
		_routine_wait = routine_pause(_routine_index)
		return false
	var direction := offset.normalized()
	velocity.x = direction.x * routine_speed()
	velocity.z = direction.z * routine_speed()
	rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z) + PI, 1.0 - exp(-delta * 8.0))
	return true


@private
func _animate(walking: bool) -> void:
	if is_instance_valid(_model):
		var bob_speed := 8.5 if walking else 2.1
		var bob_amount := 0.035 if walking else 0.018
		_model.position.y = sin(_animation_time * bob_speed + float(get_instance_id() % 13)) * bob_amount
	if _wave_time > 0.0 and is_instance_valid(_upper_arm_right):
		_upper_arm_right.rotation = Vector3(-1.45, sin(_animation_time * 9.0) * 0.35, -0.55)
	elif is_instance_valid(_upper_arm_right):
		_upper_arm_right.rotation = Vector3(sin(_animation_time * 1.4) * 0.035, 0.0, 0.0)
	if is_instance_valid(_upper_arm_left):
		_upper_arm_left.rotation.x = sin(_animation_time * (8.5 if walking else 1.4) + 1.8) * (0.28 if walking else 0.035)
	if is_instance_valid(_thigh_left):
		_thigh_left.rotation.x = sin(_animation_time * 8.5) * 0.34 if walking else 0.0
	if is_instance_valid(_thigh_right):
		_thigh_right.rotation.x = -sin(_animation_time * 8.5) * 0.34 if walking else 0.0
