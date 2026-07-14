class_name NiaNpc
extends HumanoidNpc


@override
func identity_id() -> NpcCatalog.Id:
	return NpcCatalog.Id.NIA


@override
func identity_name() -> String:
	return "Nia"


@override
func identity_model() -> ModelCatalog.Id:
	return ModelCatalog.Id.NIA


@override
func routine_points() -> Array[Vector3]:
	return [Vector3(2.2, 0.0, -12.8), Vector3(-1.8, 0.0, -13.2), Vector3(1.0, 0.0, -10.8)] as Array[Vector3]


@override
func routine_speed() -> float:
	return 1.0


@override
func react_to_event(event_id: NpcCatalog.Event) -> void:
	match event_id:
		NpcCatalog.Event.MET_WAYFARER:
			persistent_state.mood = NpcCatalog.Mood.CURIOUS
			persistent_state.trust_player += 0.12
		NpcCatalog.Event.ASTER_REMEMBERED:
			persistent_state.mood = NpcCatalog.Mood.WORRIED
			persistent_state.trust_player += 0.18
		NpcCatalog.Event.REGIONAL_TRUTH_SHARED, NpcCatalog.Event.MEMORY_COMPASS_FORGED:
			persistent_state.mood = NpcCatalog.Mood.HOPEFUL
			persistent_state.hope += 0.15
		NpcCatalog.Event.CAUSEWAY_ANSWERED:
			persistent_state.mood = NpcCatalog.Mood.RELIEVED
			persistent_state.trust_player += 0.2
