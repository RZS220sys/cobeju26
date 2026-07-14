class_name ColliderFactory
extends RefCounted


static func add_box(parent: Node3D, body_name: String, at: Vector3, size: Vector3, yaw: float = 0.0) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = body_name
	body.collision_layer = PhysicsLayers.Id.WORLD
	body.collision_mask = PhysicsLayers.Id.NONE
	body.position = at
	body.rotation.y = yaw
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	parent.add_child(body)
	return body


static func add_cylinder(parent: Node3D, body_name: String, at: Vector3, radius: float, height: float) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = body_name
	body.collision_layer = PhysicsLayers.Id.WORLD
	body.collision_mask = PhysicsLayers.Id.NONE
	body.position = at
	var collision := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	collision.shape = shape
	body.add_child(collision)
	parent.add_child(body)
	return body
