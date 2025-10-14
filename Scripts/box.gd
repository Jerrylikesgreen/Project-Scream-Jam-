@tool
## Base class for anything that can hold objects
class_name Box extends InteractibleObject

## Holds an array of items that can bve deposited and withdrawn
@export var storage: Array[ItemResource]


func add_to_storage(item:ItemResource)->void:
	storage.append(item)
	
	
func remove_from_storage(item:ItemResource)->void:
	storage.erase(item)
