class_name MemoryShard
extends Area3D

signal collected(shard: MemoryShard)

var record_title: String = "Unnamed Echo"
var record_id: String = "unnamed_echo"
var _time: float = 0.0
var _base_y: float = 0.0
var _taken: bool = false


@override
func _ready() -> void:
	collision_layer = 8
	collision_mask = 1
	monitoring = true
	body_entered.connect(_on_body_entered)
	_base_y = position.y
	_build_visual()


@private
func _build_visual() -> void:
	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.65
	collision.shape = shape
	add_child(collision)

	var outer := MeshInstance3D.new()
	var outer_mesh := BoxMesh.new()
	outer_mesh.size = Vector3(0.55, 1.05, 0.55)
	outer.mesh = outer_mesh
	outer.rotation_degrees = Vector3(0.0, 45.0, 45.0)
	outer.material_override = ArchivePalette.make_material(ArchivePalette.cyan(), 3.2, 0.18)
	add_child(outer)

	var orbit := MeshInstance3D.new()
	var orbit_mesh := TorusMesh.new()
	orbit_mesh.inner_radius = 0.56
	orbit_mesh.outer_radius = 0.61
	orbit_mesh.rings = 8
	orbit_mesh.ring_segments = 18
	orbit.mesh = orbit_mesh
	orbit.rotation_degrees.x = 72.0
	orbit.material_override = ArchivePalette.make_material(ArchivePalette.brass(), 1.0, 0.35)
	add_child(orbit)

	var light := OmniLight3D.new()
	light.light_color = ArchivePalette.cyan()
	light.light_energy = 2.8
	light.omni_range = 5.0
	light.shadow_enabled = false
	add_child(light)


@override
func _process(delta: float) -> void:
	_time += delta
	position.y = _base_y + sin(_time * 2.1) * 0.16
	rotate_y(delta * 1.35)


@private
func _on_body_entered(body: Node3D) -> void:
	if _taken or not body is ArchivistController:
		return
	_taken = true
	set_deferred(&"monitoring", false)
	collected.emit(self)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector3.ONE * 0.02, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", position.y + 1.8, 0.22)
	tween.chain().tween_callback(queue_free)
