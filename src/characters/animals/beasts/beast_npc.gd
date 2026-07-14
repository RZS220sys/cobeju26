class_name BeastNpc
extends AnimalNpc

var target: WayfarerController
var health: float = 100.0
var active: bool = true


func configure_target(target_value: WayfarerController) -> void:
	target = target_value


func take_damage(amount: float) -> void:
	if not active or amount <= 0.0:
		return
	health -= amount
	on_damaged(amount)
	if health <= 0.0:
		active = false
		on_defeated()


func on_damaged(_amount: float) -> void:
	pass


func on_defeated() -> void:
	pass
