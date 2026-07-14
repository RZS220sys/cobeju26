class_name BramNpc
extends HumanoidNpc


@override
func identity_id() -> NpcCatalog.Id:
	return NpcCatalog.Id.BRAM


@override
func identity_name() -> String:
	return "Bram"


@override
func identity_model() -> ModelCatalog.Id:
	return ModelCatalog.Id.BRAM


@override
func routine_points() -> Array[Vector3]:
	return [Vector3(8.0, 0.0, -2.0), Vector3(10.2, 0.0, -1.0), Vector3(8.8, 0.0, -4.0)] as Array[Vector3]


@override
func routine_speed() -> float:
	return 1.05


@override
func react_to_event(event_id: NpcCatalog.Event) -> void:
	match event_id:
		NpcCatalog.Event.MET_WAYFARER:
			persistent_state.mood = NpcCatalog.Mood.CALM
			persistent_state.trust_player += 0.08
		NpcCatalog.Event.MEMORY_COMPASS_FORGED:
			persistent_state.mood = NpcCatalog.Mood.HOPEFUL
			persistent_state.trust_player += 0.22
