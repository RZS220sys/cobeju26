class_name IvenNpc
extends HumanoidNpc


@override
func identity_id() -> NpcCatalog.Id:
	return NpcCatalog.Id.IVEN


@override
func identity_name() -> String:
	return "Iven"


@override
func identity_model() -> ModelCatalog.Id:
	return ModelCatalog.Id.IVEN


@override
func routine_points() -> Array[Vector3]:
	return [global_position, global_position + Vector3(-2.0, 0.0, 1.0), global_position + Vector3(1.0, 0.0, 2.0)] as Array[Vector3]


@override
func react_to_event(event_id: NpcCatalog.Event) -> void:
	if event_id == NpcCatalog.Event.RESCUED_FROM_MEMORY:
		persistent_state.mood = NpcCatalog.Mood.RELIEVED
		persistent_state.trust_player += 0.35
		persistent_state.fear = maxf(0.0, persistent_state.fear - 0.4)
