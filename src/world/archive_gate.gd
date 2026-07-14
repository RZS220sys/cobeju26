class_name ArchiveGate
extends Area3D

signal entered

var active: bool = false
var _time: float = 0.0
var _rings: Array[MeshInstance3D] = []
var _light: OmniLight3D


@override
func _ready() -> void:
	collision_layer = 16
	collision_mask = 1
	monitoring = false
	body_entered.connect(_on_body_entered)
	_build_visual()


@private
func _build_visual() -> void:
	var collision := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = 1.35
	cylinder.height = 2.5
	collision.shape = cylinder
	collision.position.y = 1.2
	add_child(collision)

	for index: int in range(3):
		var ring := MeshInstance3D.new()
		var mesh := TorusMesh.new()
		mesh.inner_radius = 1.0 + float(index) * 0.22
		mesh.outer_radius = 1.08 + float(index) * 0.22
		mesh.rings = 10
		mesh.ring_segments = 32
		ring.mesh = mesh
		ring.position.y = 1.25
		ring.rotation_degrees.x = 90.0 if index == 0 else 0.0
		ring.material_override = ArchivePalette.make_material(Color("334b51"), 0.1, 0.55)
		add_child(ring)
		_rings.append(ring)

	_light = OmniLight3D.new()
	_light.position.y = 1.2
	_light.light_color = ArchivePalette.cyan()
	_light.light_energy = 0.0
	_light.omni_range = 7.0
	add_child(_light)


func activate() -> void:
	if active:
		return
	active = true
	set_deferred(&"monitoring", true)
	_light.light_energy = 4.5
	for ring: MeshInstance3D in _rings:
		ring.material_override = ArchivePalette.make_material(ArchivePalette.cyan(), 3.0, 0.22)


@override
func _process(delta: float) -> void:
	_time += delta
	for index: int in range(_rings.size()):
		var direction := 1.0 if index % 2 == 0 else -1.0
		_rings[index].rotate_y(delta * direction * (0.4 + float(index) * 0.22))
		if active:
			_rings[index].scale = Vector3.ONE * (1.0 + sin(_time * 2.0 + float(index)) * 0.035)


@private
func _on_body_entered(body: Node3D) -> void:
	if active and body is ArchivistController:
		entered.emit()
