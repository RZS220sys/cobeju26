class_name SolaNpc
extends HumanoidNpc


@override
func identity_id() -> NpcCatalog.Id:
	return NpcCatalog.Id.SOLA


@override
func identity_name() -> String:
	return "Sola"


@override
func identity_model() -> ModelCatalog.Id:
	return ModelCatalog.Id.SOLA


@override
func routine_points() -> Array[Vector3]:
	return [global_position, global_position + Vector3(1.5, 0.0, -1.5), global_position + Vector3(2.5, 0.0, 1.0)] as Array[Vector3]


@override
func react_to_event(event_id: NpcCatalog.Event) -> void:
	if event_id == NpcCatalog.Event.RESCUED_FROM_MEMORY:
		persistent_state.mood = NpcCatalog.Mood.HOPEFUL
		persistent_state.trust_player += 0.3
		persistent_state.hope += 0.25
