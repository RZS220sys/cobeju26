class_name PurpleDotParticles
extends GPUParticles2D

const DOT_AMOUNT := 50
const TEXTURE_PATH := "res://assets/ui/title_screen/purple_dot.png"
const DOT_HEIGHT_RATIO := 0.018
const MIN_SCALE_RATIO := 0.5
const MAX_SCALE_RATIO := 1.15
const MIN_SPEED_HEIGHT_RATIO := 0.012
const MAX_SPEED_HEIGHT_RATIO := 0.045

var _particle_material: ParticleProcessMaterial


@override
func _ready() -> void:
	name = "PurpleDotParticles"
	amount = DOT_AMOUNT
	lifetime = 11.0
	preprocess = lifetime
	randomness = 0.45
	fixed_fps = 30
	interpolate = true
	fract_delta = true
	texture = ResourceLoader.load(TEXTURE_PATH, "Texture2D") as Texture2D
	_particle_material = _create_particle_material()
	process_material = _particle_material
	get_viewport().size_changed.connect(_fit_to_viewport)
	_fit_to_viewport()
	emitting = true


@private
func _create_particle_material() -> ParticleProcessMaterial:
	var particle_material := ParticleProcessMaterial.new()
	particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	particle_material.direction = Vector3.UP
	particle_material.spread = 180.0
	particle_material.gravity = Vector3.ZERO
	particle_material.damping_min = 0.0
	particle_material.damping_max = 0.0
	particle_material.angle_min = -180.0
	particle_material.angle_max = 180.0
	var tint_range := Gradient.new()
	tint_range.offsets = PackedFloat32Array([0.0, 1.0])
	# White is zero tint reduction; the other end reduces the source's shine.
	tint_range.colors = PackedColorArray([
		Color.WHITE,
		Color(0.34, 0.22, 0.46, 0.82),
	])
	var tint_texture := GradientTexture1D.new()
	tint_texture.gradient = tint_range
	particle_material.color_initial_ramp = tint_texture
	return particle_material


@private
func _fit_to_viewport() -> void:
	if not is_instance_valid(_particle_material):
		return
	var viewport_size := get_viewport_rect().size
	position = viewport_size * 0.5
	_particle_material.emission_box_extents = Vector3(viewport_size.x * 0.5, viewport_size.y * 0.5, 1.0)
	_particle_material.initial_velocity_min = viewport_size.y * MIN_SPEED_HEIGHT_RATIO
	_particle_material.initial_velocity_max = viewport_size.y * MAX_SPEED_HEIGHT_RATIO
	var texture_height := texture.get_height() if is_instance_valid(texture) else 1
	var base_scale := viewport_size.y * DOT_HEIGHT_RATIO / maxf(1.0, float(texture_height))
	_particle_material.scale_min = base_scale * MIN_SCALE_RATIO
	_particle_material.scale_max = base_scale * MAX_SCALE_RATIO
	visibility_rect = Rect2(-viewport_size * 0.7, viewport_size * 1.4)
