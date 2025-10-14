@tool 
class_name OldToolbox extends Box





func action_complete() -> void:
	active = false
	interactible_object_progress_bar.visible = false
	action_count = 0.0
	interactible_object_sprite_2d.set_frame(1)
	emit_signal("point_gain", points)
	if !storage.is_empty():
		for items in storage:
			InventoryManager.on_acquire_item(items)
			print(items)
			storage.clear()
	
