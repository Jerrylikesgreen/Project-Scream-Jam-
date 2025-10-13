class_name Dresser extends InteractibleObject


@export var has_key:bool = false

func action_complete() -> void:
	if has_key:
		Events.display_player_message("Is this a key?")
		points = 600
		has_key = false
	else:
		points = 150
	interactible_object_progress_bar.visible = false
	action_count = 0.0
	emit_signal("point_gain", points)
