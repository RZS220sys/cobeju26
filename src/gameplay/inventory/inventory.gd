class_name Inventory
extends RefCounted


static func count(state: LumenfallWorldState, item_id: ItemCatalog.Id) -> int:
	if not is_instance_valid(state) or item_id == ItemCatalog.Id.NONE:
		return 0
	for index: int in range(state.inventory_item_ids.size()):
		if state.inventory_item_ids[index] == item_id and index < state.inventory_item_counts.size():
			return state.inventory_item_counts[index]
	return 0


static func add(state: LumenfallWorldState, item_id: ItemCatalog.Id, amount: int = 1) -> void:
	if item_id == ItemCatalog.Id.NONE or amount <= 0:
		return
	for index: int in range(state.inventory_item_ids.size()):
		if state.inventory_item_ids[index] == item_id:
			while state.inventory_item_counts.size() <= index:
				state.inventory_item_counts.append(0)
			state.inventory_item_counts[index] += amount
			return
	state.inventory_item_ids.append(item_id)
	state.inventory_item_counts.append(amount)


static func remove(state: LumenfallWorldState, item_id: ItemCatalog.Id, amount: int = 1) -> bool:
	if amount <= 0 or count(state, item_id) < amount:
		return false
	for index: int in range(state.inventory_item_ids.size()):
		if state.inventory_item_ids[index] == item_id:
			state.inventory_item_counts[index] -= amount
			if state.inventory_item_counts[index] <= 0:
				state.inventory_item_ids.remove_at(index)
				state.inventory_item_counts.remove_at(index)
			return true
	return false


static func unlock_recipe(state: LumenfallWorldState, recipe_id: RecipeCatalog.Id) -> void:
	if recipe_id not in state.unlocked_recipe_ids:
		state.unlocked_recipe_ids.append(recipe_id)


static func has_recipe(state: LumenfallWorldState, recipe_id: RecipeCatalog.Id) -> bool:
	return recipe_id in state.unlocked_recipe_ids
