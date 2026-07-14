class_name WolfNpc
extends BeastNpc


@override
func configure_behavior() -> void:
	persistent_state.behavior = NpcCatalog.Behavior.HUNTING


func pack_pressure(pack_size: int) -> float:
	return clampf(0.35 + float(pack_size) * 0.12, 0.35, 1.0)
