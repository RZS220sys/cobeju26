class_name ArchiveBackdrop
extends Control

var _time: float = 0.0


@override
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)


@override
func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


@override
func _draw() -> void:
	var size_now := size
	draw_rect(Rect2(Vector2.ZERO, size_now), ArchivePalette.ink())
	var horizon_y := size_now.y * 0.68
	for index: int in range(8):
		var factor := float(index) / 7.0
		var band_color := ArchivePalette.deep_blue().lerp(ArchivePalette.ink(), factor)
		band_color.a = 0.28 - factor * 0.02
		draw_rect(Rect2(0.0, horizon_y + factor * size_now.y * 0.32, size_now.x, size_now.y * 0.05), band_color)
	var center := Vector2(size_now.x * 0.72, size_now.y * 0.36)
	for ring: int in range(6):
		var radius := 52.0 + float(ring) * 34.0 + sin(_time * 0.45 + float(ring)) * 4.0
		var ring_color := ArchivePalette.amber()
		ring_color.a = 0.16 - float(ring) * 0.018
		draw_arc(center, radius, 0.0, TAU, 96, ring_color, 2.0, true)
	for ray: int in range(14):
		var angle := float(ray) / 14.0 * TAU + _time * 0.018
		var inner := center + Vector2.from_angle(angle) * 44.0
		var outer := center + Vector2.from_angle(angle) * 230.0
		var ray_color := ArchivePalette.cyan()
		ray_color.a = 0.055
		draw_line(inner, outer, ray_color, 1.0, true)
	var water_color := ArchivePalette.cyan()
	water_color.a = 0.08
	for wave: int in range(7):
		var points := PackedVector2Array()
		var y := horizon_y + 22.0 + float(wave) * 28.0
		for step: int in range(33):
			var x := float(step) / 32.0 * size_now.x
			points.append(Vector2(x, y + sin(x * 0.012 + _time * 0.7 + float(wave)) * 4.0))
		draw_polyline(points, water_color, 1.0, true)
