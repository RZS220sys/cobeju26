class_name HollowOrb
extends Area3D

var direction: Vector3 = Vector3.ZERO
var speed: float = 7.5
var damage: float = 11.0
var lifetime: float = 3.0


func configure(travel_direction: Vector3, dealt_damage: float) -> void:
	direction = travel_direction.normalized()
	damage = dealt_damage


@override
func _ready() -> void:
	add_to_group(&"enemy_projectiles")
	collision_layer = 64
	collision_mask = 1
	monitoring = true
	body_entered.connect(_on_body_entered)
	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.27
	collision.shape = shape
	add_child(collision)
	var visual := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.23
	mesh.height = 0.46
	mesh.radial_segments = 12
	mesh.rings = 6
	visual.mesh = mesh
	visual.material_override = ArchivePalette.make_material(ArchivePalette.magenta(), 3.6, 0.15)
	add_child(visual)


@override
func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


@private
func _on_body_entered(body: Node3D) -> void:
	if body is ArchivistController:
		body.take_damage(damage)
		queue_free()
