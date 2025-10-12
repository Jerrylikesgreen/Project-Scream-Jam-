class_name GameOverBackground
extends Control

@onready var restart: Button = $Restart


func _ready() -> void:
	Events.player_hit_signal.connect(_on_player_hit_signal)
	restart.pressed.connect(restart_game)
	



func _on_player_hit_signal() -> void:
	visible = true

func restart_game() -> void:
	print("[GameOverBackground] Restart pressed")
	visible = false
	get_tree().change_scene_to_file("res://Scenes/test_level.tscn")
	
	
