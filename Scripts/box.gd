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

	if storage.is_empty():
		return
	if storage.size() > 1:
		Events.display_player_message("Found multiple items in here!")


	for item in storage:
		if item and not item.name.is_empty():
			InventoryManager.on_acquire_item(item)
			print(item)
			var item_name := item.name
			Events.display_player_message("Found {id} in here".format({"id": item.name}))


	storage.clear()


	
