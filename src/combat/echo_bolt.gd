class_name EchoBolt
extends Area3D

var direction: Vector3 = Vector3.FORWARD
var speed: float = 18.0
var damage: float = 24.0
var lifetime: float = 1.35
var source: ArchivistController


@override
func _ready() -> void:
	collision_layer = 4
	collision_mask = 2
	monitoring = true
	body_entered.connect(_on_body_entered)

	var shape := CollisionShape3D.new()
	var sphere_shape := SphereShape3D.new()
	sphere_shape.radius = 0.22
	shape.shape = sphere_shape
	add_child(shape)

	var core := MeshInstance3D.new()
	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.18
	core_mesh.height = 0.36
	core_mesh.radial_segments = 12
	core_mesh.rings = 6
	core.mesh = core_mesh
	core.material_override = ArchivePalette.make_material(ArchivePalette.amber(), 4.2, 0.15)
	add_child(core)

	var light := OmniLight3D.new()
	light.light_color = ArchivePalette.amber()
	light.light_energy = 2.2
	light.omni_range = 3.5
	light.shadow_enabled = false
	add_child(light)


func configure(caster: ArchivistController, travel_direction: Vector3, dealt_damage: float) -> void:
	source = caster
	direction = travel_direction.normalized()
	damage = dealt_damage


@override
func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	lifetime -= delta
	rotate_y(delta * 7.0)
	if lifetime <= 0.0:
		queue_free()


@private
func _on_body_entered(body: Node3D) -> void:
	if body is HollowEnemy:
		body.take_damage(damage, direction)
		queue_free()
