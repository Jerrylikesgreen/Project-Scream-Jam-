class_name FrontDoorEscape extends Door

func action_incomplete() ->void:
	print("Incomplete")
	interactible_object_progress_bar.visible = false
	action_count = 0.0
	Events.display_player_message("Door is locked!")
	
	
func action() -> void:
	if not is_acting:
		is_acting = true
		interactible_object_progress_bar.visible = true
		if !active:
			print("Action started (frame-based increment)")





func action_complete() -> void:
	print("Action complete!")
	interactible_object_progress_bar.visible = false
	action_count = 0.0
	emit_signal("point_gain", points)
