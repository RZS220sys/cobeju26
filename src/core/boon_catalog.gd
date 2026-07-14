class_name BoonCatalog
extends RefCounted


static func base_ids() -> Array[StringName]:
	return [&"steady_wick", &"amber_edge", &"fleet_footnote", &"deep_breath", &"nearer_echo", &"borrowed_hour", &"open_hand", &"salt_insulation"] as Array[StringName]


static func definition(boon_id: StringName) -> BoonDefinition:
	match boon_id:
		&"steady_wick":
			return BoonDefinition.new(boon_id, "STEADY WICK", "+25 maximum health; restore 25.", "A flame needs a vessel willing to crack.", ArchivePalette.amber())
		&"amber_edge":
			return BoonDefinition.new(boon_id, "AMBER EDGE", "+8 pulse damage.", "Warm light still knows how to cut.", ArchivePalette.amber())
		&"fleet_footnote":
			return BoonDefinition.new(boon_id, "FLEET FOOTNOTE", "+15% movement speed.", "History loses track of those who move between its lines.", ArchivePalette.cyan())
		&"deep_breath":
			return BoonDefinition.new(boon_id, "DEEP BREATH", "+30 focus and faster regeneration.", "The drowned do not hurry their answers.", ArchivePalette.cyan())
		&"nearer_echo":
			return BoonDefinition.new(boon_id, "NEARER ECHO", "Resonance grows 25% wider and stronger.", "Distance is a habit memory can break.", ArchivePalette.magenta())
		&"borrowed_hour":
			return BoonDefinition.new(boon_id, "BORROWED HOUR", "Cast pulses 18% faster.", "The Curator kept several seconds off the books.", ArchivePalette.brass())
		&"open_hand":
			return BoonDefinition.new(boon_id, "OPEN HAND", "Dispersing a Hollow restores 4 health.", "Release is sometimes returned in kind.", ArchivePalette.bone())
		&"salt_insulation":
			return BoonDefinition.new(boon_id, "SALT INSULATION", "Take 15% less damage.", "Every survivor eventually learns what not to feel.", Color("9ab5bc"))
		&"unbroken_testimony":
			return BoonDefinition.new(boon_id, "UNBROKEN TESTIMONY", "+12 pulse damage, but lose 12 maximum health.", "Truth arrives sharp because it refused to bend.", ArchivePalette.cyan())
		&"kind_ending":
			return BoonDefinition.new(boon_id, "KIND ENDING", "Dispersals restore 8 health and 5 focus.", "Mercy is not forgetting. It is ending the sentence.", ArchivePalette.amber())
		&"golden_revision":
			return BoonDefinition.new(boon_id, "GOLDEN REVISION", "+20% speed and casting rate; pulses deal 10% less damage.", "A useful lie must move before doubt catches it.", ArchivePalette.magenta())
	return BoonDefinition.new(boon_id, "UNNAMED MARGIN", "A quiet, undocumented change.", "The Archive has misplaced this annotation.", ArchivePalette.bone())
