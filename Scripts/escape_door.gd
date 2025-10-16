@tool 
class_name EscapeDoor extends Door

var attempt:int = 0

func action_incomplete() ->void:
	print("Incomplete")
	interactible_object_progress_bar.visible = false
	action_count = 0.0
	is_acting = false;
	player_triggered = false;
	if attempt < 1:
		Events.display_player_message("Door is locked!")
		Events.display_player_message("....need to find a key")
	attempt += 1
