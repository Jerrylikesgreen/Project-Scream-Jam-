class_name Player extends Node2D


@export var save_data:DataResource 

func reset_pos():
	$PlayerBody.position = Vector2(0,0);
	return

func _ready() -> void:
	Events.display_player_message("Where am I ?")
	Events.display_player_message("Should I go in?")
	
