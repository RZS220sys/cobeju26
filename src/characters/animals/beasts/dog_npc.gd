class_name DogNpc
extends BeastNpc


@override
func configure_behavior() -> void:
	persistent_state.behavior = NpcCatalog.Behavior.FOLLOWING
	persistent_state.mood = NpcCatalog.Mood.CURIOUS


func affection() -> float:
	return clampf(persistent_state.trust_player, 0.0, 1.0)
