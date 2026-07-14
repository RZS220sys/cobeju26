class_name EnvironmentBuilder
extends RefCounted


static func build(parent: Node3D) -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("295a83")
	sky_material.sky_horizon_color = Color("d0a36f")
	sky_material.ground_bottom_color = Color("172820")
	sky_material.ground_horizon_color = Color("665c42")
	sky_material.sun_angle_max = 12.0
	sky_material.sun_curve = 0.08
	sky.sky_material = sky_material
	environment.background_mode = Environment.BG_SKY
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.42
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.fog_enabled = true
	environment.fog_light_color = Color("b4b5a1")
	environment.fog_density = 0.0025
	environment.fog_sky_affect = 0.3
	world_environment.environment = environment
	parent.add_child(world_environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-53.0, -34.0, 0.0)
	sun.light_color = Color("ffd1a0")
	sun.light_energy = 0.82
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 90.0
	parent.add_child(sun)
