class_name Shelves extends InteractibleObject





func action_complete() -> void:
	print("Action complete!")
	interactible_object_progress_bar.visible = false
	action_count = 0.0
	emit_signal("point_gain", points)
	interactible_object_sprite_2d.set_frame(0)
	if resource.player_dialog:
		Events.display_player_message(resource.player_dialog)
