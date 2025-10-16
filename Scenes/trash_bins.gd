@tool
class_name TrashBins extends InteractibleObject


func _ready() -> void:
	
	
	randomize();
	var rdm = randi_range(0, 4)
	interactible_object_sprite_2d.set_frame(rdm)


func action_complete() -> void:
	var rdm = randi_range(0, 4)
	print("Action complete!")
	interactible_object_progress_bar.visible = false
	action_count = 0.0
	emit_signal("point_gain", points)
	Events.display_player_message(Events.negative_player_dialog[rdm])
