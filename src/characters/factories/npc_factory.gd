class_name NpcFactory
extends RefCounted


static func create_humanoid(npc_id: NpcCatalog.Id) -> HumanoidNpc:
	match npc_id:
		NpcCatalog.Id.NIA:
			return NiaNpc.new()
		NpcCatalog.Id.BRAM:
			return BramNpc.new()
		NpcCatalog.Id.MARA:
			return MaraNpc.new()
		NpcCatalog.Id.PIP:
			return PipNpc.new()
		NpcCatalog.Id.IVEN:
			return IvenNpc.new()
		NpcCatalog.Id.SOLA:
			return SolaNpc.new()
		NpcCatalog.Id.ORIN:
			return OrinNpc.new()
	return null
