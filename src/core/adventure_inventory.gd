class_name AdventureInventory
extends RefCounted


static func count(profile: LumenfallSaveData, item_id: LumenfallTypes.ItemId) -> int:
	if not is_instance_valid(profile):
		return 0
	for index: int in range(profile.inventory_item_ids.size()):
		if profile.inventory_item_ids[index] == item_id and index < profile.inventory_item_counts.size():
			return profile.inventory_item_counts[index]
	return 0


static func add(profile: LumenfallSaveData, item_id: LumenfallTypes.ItemId, amount: int = 1) -> void:
	if amount <= 0:
		return
	for index: int in range(profile.inventory_item_ids.size()):
		if profile.inventory_item_ids[index] == item_id:
			while profile.inventory_item_counts.size() <= index:
				profile.inventory_item_counts.append(0)
			profile.inventory_item_counts[index] += amount
			return
	profile.inventory_item_ids.append(item_id)
	profile.inventory_item_counts.append(amount)


static func remove(profile: LumenfallSaveData, item_id: LumenfallTypes.ItemId, amount: int = 1) -> bool:
	if amount <= 0 or count(profile, item_id) < amount:
		return false
	for index: int in range(profile.inventory_item_ids.size()):
		if profile.inventory_item_ids[index] == item_id:
			profile.inventory_item_counts[index] -= amount
			if profile.inventory_item_counts[index] <= 0:
				profile.inventory_item_ids.remove_at(index)
				profile.inventory_item_counts.remove_at(index)
			return true
	return false


static func unlock_recipe(profile: LumenfallSaveData, recipe_id: LumenfallTypes.RecipeId) -> void:
	if recipe_id not in profile.unlocked_recipe_ids:
		profile.unlocked_recipe_ids.append(recipe_id)


static func has_recipe(profile: LumenfallSaveData, recipe_id: LumenfallTypes.RecipeId) -> bool:
	return recipe_id in profile.unlocked_recipe_ids
