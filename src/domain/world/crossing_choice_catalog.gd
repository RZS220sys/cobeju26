class_name CrossingChoiceCatalog
extends RefCounted


enum Id {
	NONE = -1,
	SHELTER,
	BRIDGE,
	WITNESS,
}


static func evidence_item(choice: CrossingChoiceCatalog.Id) -> ItemCatalog.Id:
	match choice:
		Id.SHELTER:
			return ItemCatalog.Id.CROSSING_CHOICE_SHELTER
		Id.BRIDGE:
			return ItemCatalog.Id.CROSSING_CHOICE_BRIDGE
		Id.WITNESS:
			return ItemCatalog.Id.CROSSING_CHOICE_WITNESS
	return ItemCatalog.Id.NONE
