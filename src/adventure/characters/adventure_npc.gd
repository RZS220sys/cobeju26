class_name AdventureNpc
extends StaticBody3D

var npc_id: StringName
var display_name: String
var asset_name: String
var interaction_prompt: String

var _model: Node3D
var _marker: Label3D
var _upper_arm_right: Node3D
var _upper_arm_left: Node3D
var _animation_time: float = 0.0
var _wave_time: float = 0.0


func configure(id_value: StringName, name_value: String, asset_value: String) -> void:
	npc_id = id_value
	display_name = name_value
	asset_name = asset_value
	interaction_prompt = "Talk to %s" % display_name


@override
func _ready() -> void:
	add_to_group(&"adventure_interactables")
	add_to_group(&"adventure_npcs")
	collision_layer = 1
	collision_mask = 0
	_build_actor()


@private
func _build_actor() -> void:
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.38
	shape.height = 1.3 if asset_name == "pip" else 1.78
	collision.shape = shape
	collision.position.y = shape.height * 0.5
	add_child(collision)
	_model = AdventureAssetLibrary.instantiate_model(asset_name)
	if is_instance_valid(_model):
		_model.name = "%sModel" % display_name
		add_child(_model)
		AdventureRigBinder.bind_humanoid(_model)
		_upper_arm_right = _model.find_child("UpperArmR", true, false) as Node3D
		_upper_arm_left = _model.find_child("UpperArmL", true, false) as Node3D
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
	if is_instance_valid(_model):
		_model.position.y = sin(_animation_time * 2.1 + float(get_instance_id() % 13)) * 0.018
	if _wave_time > 0.0 and is_instance_valid(_upper_arm_right):
		_upper_arm_right.rotation = Vector3(-1.45, sin(_animation_time * 9.0) * 0.35, -0.55)
	elif is_instance_valid(_upper_arm_right):
		_upper_arm_right.rotation = Vector3(sin(_animation_time * 1.4) * 0.035, 0.0, 0.0)
	if is_instance_valid(_upper_arm_left):
		_upper_arm_left.rotation.x = sin(_animation_time * 1.4 + 1.8) * 0.035


func set_interaction_focus(focused: bool) -> void:
	_marker.visible = focused


func greet(player_position: Vector3) -> void:
	var direction := player_position - global_position
	direction.y = 0.0
	if direction.length_squared() > 0.01:
		rotation.y = atan2(-direction.x, -direction.z) + PI
	_wave_time = 1.8


func get_interaction_prompt() -> String:
	return interaction_prompt
