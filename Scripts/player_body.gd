class_name PlayerBody extends CharacterBody2D

@onready var action_area: Area2D = %ActionArea
@onready var player_controller: PlayerController = %PlayerController

func _ready() -> void:
	Events.player_hit_signal.connect(_on_player_hit)
	
	
	
func _on_player_hit():
	get_parent().queue_free()
	
	pass
