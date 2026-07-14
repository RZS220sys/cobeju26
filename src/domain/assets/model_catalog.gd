class_name ModelCatalog
extends RefCounted


enum Id {
	BRAM,
	COTTAGE_BLUE,
	COTTAGE_RED,
	IVEN,
	LANTERN_POST,
	MARA,
	NIA,
	OAK,
	ORIN,
	PINE,
	PIP,
	RIFT_HOUND,
	SOLA,
	VILLAGE_PROPS,
	WAYFARER,
	WAYSTONE,
}


static func file_name(model_id: Id) -> String:
	return String(Id.find_key(model_id)).to_snake_case()


static func for_npc(npc_id: NpcCatalog.Id) -> Id:
	match npc_id:
		NpcCatalog.Id.NIA:
			return Id.NIA
		NpcCatalog.Id.BRAM:
			return Id.BRAM
		NpcCatalog.Id.MARA:
			return Id.MARA
		NpcCatalog.Id.PIP:
			return Id.PIP
		NpcCatalog.Id.IVEN:
			return Id.IVEN
		NpcCatalog.Id.SOLA:
			return Id.SOLA
		NpcCatalog.Id.ORIN:
			return Id.ORIN
		NpcCatalog.Id.RIFT_HOUND:
			return Id.RIFT_HOUND
	return Id.WAYFARER
