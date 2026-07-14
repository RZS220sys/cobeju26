class_name ThirdPersonCamera
extends Node3D

var target: WayfarerController
var mouse_sensitivity: float = 0.0024
var invert_vertical: bool = false
var minimum_zoom: float = 1.8
var maximum_zoom: float = 10.0
var zoom_step: float = 0.65
var reduce_motion: bool = false

var _yaw: float = 0.0
var _pitch: float = -0.22
var _desired_zoom: float = 5.2
var _pivot: Node3D
var _spring_arm: SpringArm3D
var _camera: Camera3D
var _capture_guard_frames: int = 3


func configure(follow_target: WayfarerController) -> void:
	target = follow_target


@override
func _ready() -> void:
	name = "ThirdPersonCameraRig"
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_camera()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if is_instance_valid(target):
		global_position = target.global_position + Vector3.UP * 1.45


@private
func _build_camera() -> void:
	_pivot = Node3D.new()
	_pivot.name = "OrbitPivot"
	add_child(_pivot)
	_spring_arm = SpringArm3D.new()
	_spring_arm.name = "CameraCollisionArm"
	_spring_arm.spring_length = _desired_zoom
	_spring_arm.margin = 0.18
	_spring_arm.collision_mask = PhysicsLayers.Id.WORLD
	_pivot.add_child(_spring_arm)
	_camera = Camera3D.new()
	_camera.name = "PlayerCamera"
	_camera.current = true
	_camera.fov = 68.0
	_spring_arm.add_child(_camera)
	if is_instance_valid(target):
		_spring_arm.add_excluded_object(target.get_rid())
	_apply_orbit()


@override
func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion := event as InputEventMouseMotion
		# Some window managers warp the hidden cursor before a click. Treat any
		# single-frame delta larger than a deliberate hand motion as a warp.
		if _capture_guard_frames > 0 or motion.relative.length() > 60.0:
			return
		_yaw -= motion.relative.x * mouse_sensitivity
		var vertical_sign := -1.0 if invert_vertical else 1.0
		_pitch -= motion.relative.y * mouse_sensitivity * vertical_sign
		_pitch = clampf(_pitch, -1.15, 0.58)
		_apply_orbit()
	elif event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if button.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			_capture_guard_frames = 3
		elif button.pressed and button.button_index == MOUSE_BUTTON_WHEEL_UP:
			adjust_zoom(-zoom_step)
		elif button.pressed and button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			adjust_zoom(zoom_step)
	elif event is InputEventKey:
		var key := event as InputEventKey
		if key.pressed and key.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif key.pressed and key.keycode != KEY_ESCAPE and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			_capture_guard_frames = 3


@override
func _process(delta: float) -> void:
	_capture_guard_frames = maxi(0, _capture_guard_frames - 1)
	if not is_instance_valid(target):
		return
	var target_position := target.global_position + Vector3.UP * 1.45
	var follow_speed := 28.0 if reduce_motion else 14.0
	global_position = global_position.lerp(target_position, 1.0 - exp(-delta * follow_speed))
	_spring_arm.spring_length = lerpf(_spring_arm.spring_length, _desired_zoom, 1.0 - exp(-delta * 12.0))


@private
func _apply_orbit() -> void:
	rotation.y = _yaw
	_pivot.rotation.x = _pitch


func get_player_camera() -> Camera3D:
	return _camera


func get_zoom_distance() -> float:
	return _desired_zoom


func adjust_zoom(amount: float) -> void:
	_desired_zoom = clampf(_desired_zoom + amount, minimum_zoom, maximum_zoom)


func apply_settings(settings: GameSettings) -> void:
	mouse_sensitivity = settings.mouse_sensitivity
	invert_vertical = settings.invert_vertical
	reduce_motion = settings.reduce_motion
	if is_instance_valid(_camera):
		_camera.fov = settings.field_of_view
