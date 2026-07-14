class_name TideCatalog
extends RefCounted


static func for_seed(seed_value: int) -> TideDefinition:
	match posmod(seed_value, 5):
		1:
			return TideDefinition.new(&"glass", "GLASS TIDE", "Hollows move faster, but each broken mandate leaves useful fragments.", 3)
		2:
			return TideDefinition.new(&"mercy", "MERCY CURRENT", "Dispersals restore health. The memories themselves are harder to release.", 2)
		3:
			return TideDefinition.new(&"low_lantern", "LOW LANTERN", "The vessel is fragile; its cast burns brighter. Precision earns fragments.", 3)
		4:
			return TideDefinition.new(&"black_index", "BLACK INDEX", "Murmurs dominate the catalogue and their projectiles cross the water faster.", 4)
	return TideDefinition.new(&"quiet", "QUIET WATER", "The Archive is listening more than it is resisting. No special distortion.", 1)
