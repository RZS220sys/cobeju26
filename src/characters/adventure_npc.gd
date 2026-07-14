class_name AdventureNpc
extends StaticBody3D

var npc_id: LumenfallTypes.NpcId
var display_name: String
var asset_id: LumenfallTypes.AssetId
var interaction_prompt: String

var _model: Node3D
var _marker: Label3D
var _upper_arm_right: Node3D
var _upper_arm_left: Node3D
var _thigh_right: Node3D
var _thigh_left: Node3D
var _animation_time: float = 0.0
var _wave_time: float = 0.0
var _schedule_points: Array[Vector3] = []
var _schedule_index: int = 0
var _schedule_wait: float = 0.0
var _schedule_speed: float = 1.35


func configure(id_value: LumenfallTypes.NpcId, name_value: String) -> void:
	npc_id = id_value
	display_name = name_value
	asset_id = LumenfallTypes.npc_asset(npc_id)
	interaction_prompt = "Talk to %s" % display_name


func configure_schedule(points: Array[Vector3], speed: float = 1.35) -> void:
	_schedule_points = points.duplicate()
	_schedule_speed = speed


@override
func _ready() -> void:
	add_to_group(&"adventure_interactables")
	add_to_group(&"adventure_npcs")
	collision_layer = LumenfallTypes.PhysicsLayer.WORLD
	collision_mask = LumenfallTypes.PhysicsLayer.NONE
	_build_actor()


@private
func _build_actor() -> void:
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.38
	shape.height = 1.3 if npc_id == LumenfallTypes.NpcId.PIP else 1.78
	collision.shape = shape
	collision.position.y = shape.height * 0.5
	add_child(collision)
	_model = AdventureAssetLibrary.instantiate_model(asset_id)
	if is_instance_valid(_model):
		_model.name = "%sModel" % display_name
		add_child(_model)
		AdventureRigBinder.bind_humanoid(_model)
		_upper_arm_right = _model.find_child("UpperArmR", true, false) as Node3D
		_upper_arm_left = _model.find_child("UpperArmL", true, false) as Node3D
		_thigh_right = _model.find_child("ThighR", true, false) as Node3D
		_thigh_left = _model.find_child("ThighL", true, false) as Node3D
	_marker = Label3D.new()
	_marker.name = "InteractionMarker"
	_marker.text = "◇\n%s" % display_name
	_marker.position.y = shape.height + 0.45
	_marker.font_size = 26
	_marker.outline_size = 8
	_marker.modulate = Color(1.0, 0.82, 0.34, 0.95)
	_marker.no_depth_test = true
	_marker.visible = false
	add_child(_marker)


@override
func _process(delta: float) -> void:
	_animation_time += delta
	_wave_time = maxf(0.0, _wave_time - delta)
	_schedule_wait = maxf(0.0, _schedule_wait - delta)
	var walking := _update_schedule(delta)
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


@private
func _update_schedule(delta: float) -> bool:
	if _schedule_points.size() < 2 or _schedule_wait > 0.0 or _wave_time > 0.0:
		return false
	var target_point := _schedule_points[_schedule_index]
	var offset := target_point - global_position
	offset.y = 0.0
	if offset.length() < 0.18:
		_schedule_index = (_schedule_index + 1) % _schedule_points.size()
		_schedule_wait = 1.8 + float((_schedule_index + npc_id) % 4) * 0.7
		return false
	var direction := offset.normalized()
	global_position += direction * minf(_schedule_speed * delta, offset.length())
	rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z) + PI, 1.0 - exp(-delta * 8.0))
	return true


func set_interaction_focus(focused: bool) -> void:
	_marker.visible = focused


func greet(player_position: Vector3) -> void:
	var direction := player_position - global_position
	direction.y = 0.0
	if direction.length_squared() > 0.01:
		rotation.y = atan2(-direction.x, -direction.z) + PI
	_wave_time = 1.8
	_schedule_wait = maxf(_schedule_wait, 2.5)


func get_interaction_prompt() -> String:
	return interaction_prompt
