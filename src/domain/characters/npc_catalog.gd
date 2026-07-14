class_name NpcCatalog
extends RefCounted


enum Id {
	NIA,
	BRAM,
	MARA,
	PIP,
	IVEN,
	SOLA,
	ORIN,
	RIFT_HOUND,
}

enum Mood {
	CALM,
	CURIOUS,
	HOPEFUL,
	WORRIED,
	AFRAID,
	ANGRY,
	GRIEVING,
	RELIEVED,
}

enum Behavior {
	IDLE,
	ROUTINE,
	CONVERSING,
	FOLLOWING,
	FLEEING,
	HUNTING,
	GUARDING,
	RECOVERING,
}

enum Event {
	MET_WAYFARER,
	WAYSTONE_AWAKENED,
	ASTER_REMEMBERED,
	REGIONAL_TRUTH_SHARED,
	RESCUED_FROM_MEMORY,
	MEMORY_COMPASS_FORGED,
	CAUSEWAY_ANSWERED,
}


static func file_stem(npc_id: Id) -> String:
	return String(Id.find_key(npc_id)).to_snake_case()


static func persistent_ids() -> Array[Id]:
	return [
		Id.NIA,
		Id.BRAM,
		Id.MARA,
		Id.PIP,
		Id.IVEN,
		Id.SOLA,
		Id.ORIN,
		Id.RIFT_HOUND,
	] as Array[Id]
