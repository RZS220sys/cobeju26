class_name AdventureWorldStreamer
extends Node3D

var target: WayfarerController
var world_seed: int = 48271
var chunk_size: float = 64.0
var view_radius: int = 2

var _chunks: Dictionary[Vector2i, AdventureTerrainChunk] = {}
var _noise := FastNoiseLite.new()
var _terrain_material: ShaderMaterial
var _last_center := Vector2i(999999, 999999)
var _update_accumulator: float = 0.0


func configure(follow_target: WayfarerController, seed_value: int = 48271) -> void:
	target = follow_target
	world_seed = seed_value


@override
func _ready() -> void:
	name = "WorldStreamer"
	_configure_noise()
	_terrain_material = _create_terrain_material()
	_update_chunks(true)


@override
func _process(delta: float) -> void:
	_update_accumulator += delta
	if _update_accumulator < 0.25:
		return
	_update_accumulator = 0.0
	_update_chunks(false)


@private
func _configure_noise() -> void:
	_noise.seed = world_seed
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.frequency = 0.012
	_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	_noise.fractal_octaves = 4
	_noise.fractal_lacunarity = 2.05
	_noise.fractal_gain = 0.48


@private
func _update_chunks(force: bool) -> void:
	if not is_instance_valid(target):
		return
	var center := Vector2i(floori(target.global_position.x / chunk_size), floori(target.global_position.z / chunk_size))
	if not force and center == _last_center:
		return
	_last_center = center
	var required: Dictionary[Vector2i, bool] = {}
	for z_offset: int in range(-view_radius, view_radius + 1):
		for x_offset: int in range(-view_radius, view_radius + 1):
			var coordinate := center + Vector2i(x_offset, z_offset)
			required[coordinate] = true
			if not _chunks.has(coordinate):
				_create_chunk(coordinate)
	var existing_coordinates: Array[Vector2i] = _chunks.keys()
	for coordinate: Vector2i in existing_coordinates:
		if not required.has(coordinate):
			var old_chunk := _chunks[coordinate]
			_chunks.erase(coordinate)
			old_chunk.queue_free()


@private
func _create_chunk(coordinate: Vector2i) -> void:
	var chunk := AdventureTerrainChunk.new()
	chunk.configure(coordinate, chunk_size, _noise, _terrain_material)
	_chunks[coordinate] = chunk
	add_child(chunk)


@private
func _create_terrain_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;
uniform sampler2D grass_texture : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D forest_texture : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
varying vec3 world_position;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return fract(p.x * p.y);
}

float value_noise(vec2 p) {
	vec2 cell = floor(p);
	vec2 f = fract(p);
	vec2 blend = f * f * (3.0 - 2.0 * f);
	float a = hash21(cell);
	float b = hash21(cell + vec2(1.0, 0.0));
	float c = hash21(cell + vec2(0.0, 1.0));
	float d = hash21(cell + vec2(1.0, 1.0));
	return mix(mix(a, b, blend.x), mix(c, d, blend.x), blend.y);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float patch = value_noise(world_position.xz * 0.075);
	vec3 meadow = mix(vec3(0.10, 0.24, 0.105), vec3(0.22, 0.39, 0.15), patch);
	vec3 painted_grass = texture(grass_texture, world_position.xz * 0.018).rgb;
	painted_grass *= mix(vec3(0.44, 0.52, 0.40), vec3(0.62, 0.69, 0.52), patch);
	vec3 forest_floor = texture(forest_texture, world_position.xz * 0.02).rgb * vec3(0.72, 0.78, 0.76);
	vec3 dry_grass = vec3(0.34, 0.35, 0.16);
	vec3 stone = vec3(0.24, 0.25, 0.23);
	float steep = smoothstep(0.70, 0.93, 1.0 - NORMAL.y + 0.70);
	float altitude = smoothstep(5.0, 13.0, world_position.y);
	ALBEDO = mix(meadow, painted_grass, 0.46);
	float glasswood = smoothstep(85.0, 155.0, -world_position.z);
	float amberfen = smoothstep(105.0, 190.0, world_position.x);
	float bellscar = smoothstep(125.0, 220.0, world_position.z);
	ALBEDO = mix(ALBEDO, forest_floor, glasswood * 0.84);
	ALBEDO = mix(ALBEDO, ALBEDO * vec3(0.92, 0.68, 0.36) + vec3(0.08, 0.045, 0.01), amberfen * 0.62);
	ALBEDO = mix(ALBEDO, dry_grass, altitude * 0.42);
	ALBEDO = mix(ALBEDO, stone, steep * 0.72);
	ALBEDO = mix(ALBEDO, stone * vec3(1.05, 0.9, 0.86), bellscar * 0.55);
	ROUGHNESS = 0.94;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	var grass_texture := load("res://assets/textures/meadow_grass_v1.png") as Texture2D
	material.set_shader_parameter(&"grass_texture", grass_texture)
	var forest_texture := load("res://assets/textures/glasswood_floor_v1.png") as Texture2D
	material.set_shader_parameter(&"forest_texture", forest_texture)
	return material


func sample_height(world_x: float, world_z: float) -> float:
	var distance_from_village := Vector2(world_x, world_z).length()
	if distance_from_village < 30.0:
		return 0.0
	var village_blend := smoothstep(30.0, 58.0, distance_from_village)
	var broad := _noise.get_noise_2d(world_x * 0.38, world_z * 0.38) * 8.5
	var detail := _noise.get_noise_2d(world_x * 1.6 + 730.0, world_z * 1.6 - 410.0) * 1.25
	return (broad + detail) * village_blend


func loaded_chunk_count() -> int:
	return _chunks.size()
