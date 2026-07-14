class_name PipNpc
extends HumanoidNpc


@override
func identity_id() -> NpcCatalog.Id:
	return NpcCatalog.Id.PIP


@override
func identity_name() -> String:
	return "Pip"


@override
func identity_model() -> ModelCatalog.Id:
	return ModelCatalog.Id.PIP


@override
func body_height() -> float:
	return 1.3


@override
func routine_points() -> Array[Vector3]:
	return [Vector3(2.0, 0.0, 4.0), Vector3(-4.0, 0.0, 3.5), Vector3(-3.0, 0.0, -3.0), Vector3(4.0, 0.0, -3.0)] as Array[Vector3]


@override
func routine_speed() -> float:
	return 2.0


@override
func react_to_event(event_id: NpcCatalog.Event) -> void:
	if event_id == NpcCatalog.Event.MET_WAYFARER:
		persistent_state.mood = NpcCatalog.Mood.CURIOUS
		persistent_state.hope += 0.1
