class_name MaraNpc
extends HumanoidNpc


@override
func identity_id() -> NpcCatalog.Id:
	return NpcCatalog.Id.MARA


@override
func identity_name() -> String:
	return "Mara"


@override
func identity_model() -> ModelCatalog.Id:
	return ModelCatalog.Id.MARA


@override
func routine_points() -> Array[Vector3]:
	return [Vector3(-5.5, 0.0, 5.0), Vector3(4.0, 0.0, 6.0), Vector3(15.0, 0.0, 2.8), Vector3(4.0, 0.0, 2.5)] as Array[Vector3]


@override
func routine_speed() -> float:
	return 1.5


@override
func react_to_event(event_id: NpcCatalog.Event) -> void:
	match event_id:
		NpcCatalog.Event.MET_WAYFARER:
			persistent_state.mood = NpcCatalog.Mood.WORRIED
		NpcCatalog.Event.ASTER_REMEMBERED:
			persistent_state.mood = NpcCatalog.Mood.GRIEVING
			persistent_state.trust_player += 0.25
		NpcCatalog.Event.REGIONAL_TRUTH_SHARED:
			persistent_state.mood = NpcCatalog.Mood.HOPEFUL
			persistent_state.hope += 0.18
