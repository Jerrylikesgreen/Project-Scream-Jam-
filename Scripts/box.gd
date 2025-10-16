@tool
## Base class for anything that can hold objects
class_name Box extends InteractibleObject

## Holds an array of items that can bve deposited and withdrawn
@export var storage: Array[ItemResource]


func add_to_storage(item:ItemResource)->void:
	storage.append(item)
	
	
func remove_from_storage(item:ItemResource)->void:
	storage.erase(item)



func action_complete() -> void:
	active = false
	interactible_object_progress_bar.visible = false
	action_count = 0.0
	emit_signal("point_gain", points)
	if !storage.is_empty():
		for items in storage:
			InventoryManager.on_acquire_item(items)
			print(items)
			storage.clear()
			var item_name := items.name
			Events.display_player_message("Found a {id} in here".format({"id": item_name}))

	
