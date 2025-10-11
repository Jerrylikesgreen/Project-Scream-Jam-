class_name Player extends CharacterBody2D


func _ready() -> void:
	Events.player_hit_signal.connect(_on_player_hit)
	
	
func _on_player_hit():
	## Will flesh pout later 
	
	pass
