@tool
class_name DoorLocked extends Door



func _process(_delta: float) -> void:
	if is_acting:

		action_count += ( 100.0 / action_speed ) * _delta

		if action_count >= 100.0:
			action_count = 100.0
			is_acting = false
			var unlock_door = InventoryManager.use_key(lock_uid)
			active = unlock_door
			if active:
				action_complete()
			else:
				action_incomplete()

	interactible_object_progress_bar.value = action_count

func action_incomplete() ->void:
	print("Incomplete")
	interactible_object_progress_bar.visible = false
	action_count = 0.0
	Events.display_player_message("I need to find a key...")
	
	
func action() -> void:
	
	if not is_acting:
		is_acting = true
		interactible_object_progress_bar.visible = true
		if !active:
			print("Action started (frame-based increment)")




func action_complete() -> void:
	interactible_object_collision_shape_2d.set_disabled(true)
	interactible_object_progress_bar.visible = false
	action_count = 0.0
	interactible_object_sprite_2d.set_frame(1)
	emit_signal("point_gain", points)
