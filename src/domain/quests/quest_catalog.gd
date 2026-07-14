class_name QuestCatalog
extends RefCounted


enum Stage {
	SUMMONED,
	WAKE_WAYSTONE,
	MEET_MARA,
	GATHER_RIFTGLASS,
	RETURN_SHARDS_TO_BRAM,
	CRAFT_LANTERN_LENS,
	SHOW_LENS_TO_MARA,
	REACH_EASTERN_CROSSING,
	DEFEND_LANTERN_ROAD,
	LISTEN_TO_ASTER,
	REPORT_ASTER,
	CHOOSE_REGION,
	DISCOVER_REGION_INSTRUMENT,
	MARK_REGION_DISCOVERY,
	REPORT_THREE_INSTRUMENTS,
	RESCUE_MISSING_VILLAGERS,
	RETURN_THREE_NAMES,
	CRAFT_MEMORY_COMPASS,
	BRING_COMPASS_TO_WAYSTONE,
	AWAKEN_CAUSEWAY_VOICES,
	ANSWER_CAUSEWAY_GATE,
	REPORT_CROSSING_ANSWER,
	EXAMINE_CROSSING_AFTERMATH,
	FOLLOW_GLASS_ROAD,
}

enum Id {
	THE_WRONG_STAR,
	WAKE_THE_WAYSTONE,
	THE_ANSWERING_SKY,
	THE_SINGING_SHARDS,
	RIFTGLASS_IS_NOT_COIN,
	A_LENS_FOR_THE_ROAD,
	THE_GUARDIANS_MEASURE,
	BEYOND_THE_LANTERNS,
	THE_HOUND_CALLED_ASTER,
	A_NAME_INSIDE_THE_NOISE,
	THE_NAME_ASTER,
	HEARTHMERE_WAGES,
	THE_FIRST_CROSSING,
	GLASSWOOD_CALL,
	AMBERFEN_ORBIT,
	BELLSCAR_WAKE,
	THREE_INSTRUMENTS_ANSWERED,
	THE_THREE_INSTRUMENTS,
	THE_CROSSING_OF_THREE_VOICES,
	THREE_NAMES_RETURNED,
	FORGE_THE_MEMORY_COMPASS,
	NAMES_IN_THE_WIND,
	COMPASS_TO_THE_WAYSTONE,
	CROSSING_OF_THREE_VOICES,
	THE_ROAD_ASKS,
	ANSWER_CARRIED_HOME,
	HEARTHMERE_AFTER_THE_ANSWER,
	THE_GLASS_ROAD,
}

enum NavigationKind {
	NONE,
	NPC,
	INTERACTION,
	ACTIVE_RIFTGLASS,
	MISSING_VILLAGER,
	SLEEPING_VOICE,
	REGIONAL_INSTRUMENT,
}


static func navigation_label(stage: Stage, quest_id: Id) -> String:
	match stage:
		Stage.SUMMONED, Stage.REPORT_ASTER, Stage.REPORT_THREE_INSTRUMENTS, Stage.RETURN_THREE_NAMES, Stage.REPORT_CROSSING_ANSWER:
			return "Nia"
		Stage.WAKE_WAYSTONE, Stage.BRING_COMPASS_TO_WAYSTONE:
			return "Waystone"
		Stage.MEET_MARA, Stage.SHOW_LENS_TO_MARA:
			return "Mara"
		Stage.GATHER_RIFTGLASS:
			return "Singing shard"
		Stage.RETURN_SHARDS_TO_BRAM:
			return "Bram"
		Stage.CRAFT_LANTERN_LENS, Stage.CRAFT_MEMORY_COMPASS:
			return "Lantern bench"
		Stage.REACH_EASTERN_CROSSING:
			return "Eastern lanterns"
		Stage.DEFEND_LANTERN_ROAD:
			return "Rift hound"
		Stage.LISTEN_TO_ASTER:
			return "Hound memory"
		Stage.CHOOSE_REGION, Stage.MARK_REGION_DISCOVERY:
			return "Field map"
		Stage.DISCOVER_REGION_INSTRUMENT:
			return _regional_label(quest_id)
		Stage.RESCUE_MISSING_VILLAGERS:
			return "Missing villager"
		Stage.AWAKEN_CAUSEWAY_VOICES:
			return "Sleeping voice"
		Stage.ANSWER_CAUSEWAY_GATE:
			return "Central gate"
		Stage.EXAMINE_CROSSING_AFTERMATH:
			return "Changed Waystone"
		Stage.FOLLOW_GLASS_ROAD:
			return "Western light"
	return ""


static func navigation_kind(stage: Stage) -> NavigationKind:
	match stage:
		Stage.SUMMONED, Stage.MEET_MARA, Stage.RETURN_SHARDS_TO_BRAM, Stage.SHOW_LENS_TO_MARA, Stage.REPORT_ASTER, Stage.REPORT_THREE_INSTRUMENTS, Stage.RETURN_THREE_NAMES, Stage.REPORT_CROSSING_ANSWER:
			return NavigationKind.NPC
		Stage.WAKE_WAYSTONE, Stage.CRAFT_LANTERN_LENS, Stage.REACH_EASTERN_CROSSING, Stage.LISTEN_TO_ASTER, Stage.CHOOSE_REGION, Stage.MARK_REGION_DISCOVERY, Stage.CRAFT_MEMORY_COMPASS, Stage.BRING_COMPASS_TO_WAYSTONE, Stage.ANSWER_CAUSEWAY_GATE, Stage.EXAMINE_CROSSING_AFTERMATH, Stage.FOLLOW_GLASS_ROAD:
			return NavigationKind.INTERACTION
		Stage.GATHER_RIFTGLASS:
			return NavigationKind.ACTIVE_RIFTGLASS
		Stage.DISCOVER_REGION_INSTRUMENT:
			return NavigationKind.REGIONAL_INSTRUMENT
		Stage.RESCUE_MISSING_VILLAGERS:
			return NavigationKind.MISSING_VILLAGER
		Stage.AWAKEN_CAUSEWAY_VOICES:
			return NavigationKind.SLEEPING_VOICE
	return NavigationKind.NONE


static func navigation_npc(stage: Stage) -> NpcCatalog.Id:
	match stage:
		Stage.MEET_MARA, Stage.SHOW_LENS_TO_MARA:
			return NpcCatalog.Id.MARA
		Stage.RETURN_SHARDS_TO_BRAM:
			return NpcCatalog.Id.BRAM
	return NpcCatalog.Id.NIA


static func navigation_interaction(stage: Stage) -> InteractionCatalog.Id:
	match stage:
		Stage.WAKE_WAYSTONE, Stage.BRING_COMPASS_TO_WAYSTONE:
			return InteractionCatalog.Id.WAYSTONE
		Stage.CRAFT_LANTERN_LENS, Stage.CRAFT_MEMORY_COMPASS:
			return InteractionCatalog.Id.BRAM_WORKBENCH
		Stage.REACH_EASTERN_CROSSING:
			return InteractionCatalog.Id.EASTERN_CROSSING
		Stage.LISTEN_TO_ASTER:
			return InteractionCatalog.Id.HOUND_MEMORY
		Stage.CHOOSE_REGION, Stage.MARK_REGION_DISCOVERY:
			return InteractionCatalog.Id.FIELD_MAP
		Stage.ANSWER_CAUSEWAY_GATE:
			return InteractionCatalog.Id.THREE_VOICES_GATE
		Stage.EXAMINE_CROSSING_AFTERMATH:
			return InteractionCatalog.Id.CROSSING_AFTERMATH
		Stage.FOLLOW_GLASS_ROAD:
			return InteractionCatalog.Id.GLASS_ROAD_BEACON
	return InteractionCatalog.Id.WAYSTONE


static func regional_interaction(quest_id: Id) -> InteractionCatalog.Id:
	match quest_id:
		Id.GLASSWOOD_CALL:
			return InteractionCatalog.Id.GLASSWOOD_SHRINE
		Id.AMBERFEN_ORBIT:
			return InteractionCatalog.Id.AMBERFEN_ORRERY
		Id.BELLSCAR_WAKE:
			return InteractionCatalog.Id.BELLSCAR_BELL
	return InteractionCatalog.Id.GLASSWOOD_SHRINE


@private
static func _regional_label(quest_id: Id) -> String:
	match quest_id:
		Id.GLASSWOOD_CALL:
			return "Glasswood Shrine"
		Id.AMBERFEN_ORBIT:
			return "Amberfen Orrery"
		Id.BELLSCAR_WAKE:
			return "Bellscar Bell"
	return "Regional instrument"
