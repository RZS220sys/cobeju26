class_name MemoryBurst
extends Node3D

var burst_color: Color = ArchivePalette.cyan()
var large: bool = false


func configure(color: Color, large_burst: bool) -> void:
	burst_color = color
	large = large_burst


@override
func _ready() -> void:
	var shard_count := 18 if large else 9
	var distance := 2.4 if large else 1.25
	for index: int in range(shard_count):
		var shard := MeshInstance3D.new()
		var mesh := PrismMesh.new()
		mesh.size = Vector3(0.08, 0.28, 0.07) * (1.5 if large else 1.0)
		shard.mesh = mesh
		shard.material_override = ArchivePalette.make_material(burst_color, 1.8, 0.2)
		shard.rotation = Vector3(float(index) * 0.73, float(index) * 1.37, float(index) * 0.41)
		add_child(shard)
		var angle := float(index) / float(shard_count) * TAU
		var vertical := 0.35 + sin(float(index) * 2.1) * 0.3
		var destination := Vector3(cos(angle) * distance, vertical, sin(angle) * distance)
		var tween := create_tween().set_parallel(true)
		tween.tween_property(shard, "position", destination, 0.48 if large else 0.34).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(shard, "scale", Vector3.ONE * 0.03, 0.52 if large else 0.38).set_delay(0.12)
	var cleanup := get_tree().create_timer(0.65 if large else 0.48)
	cleanup.timeout.connect(queue_free)
