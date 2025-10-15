@tool 
class_name Switch1 extends InteractibleObject


signal action_incomplete_signal
signal action_complete_signal




func action() -> void:
	if not is_acting:
		is_acting = true
		interactible_object_progress_bar.visible = true
		if !active:
			print("Action started (frame-based increment)")


func action_complete() -> void:
	print("Action complete!")
	interactible_object_progress_bar.visible = false
	interactible_object_sprite_2d.set_frame(1)
	action_count = 0.0
	emit_signal("point_gain", points)
	emit_signal("action_complete_signal")
	
	

func action_incomplete() -> void:
	player_triggered = false;
	interactible_object_progress_bar.visible = false
	action_count = 0.0
	emit_signal("action_incomplete_signal")
	print("Signal being emitted from Switch")
