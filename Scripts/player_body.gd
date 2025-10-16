class_name PlayerBody extends CharacterBody2D

@onready var action_area: Area2D = %ActionArea
@onready var player_controller: PlayerController = %PlayerController

var hiding:bool = false;
@onready var player_sprite: AnimatedSprite2D = %PlayerSprite

func _ready() -> void:
	Events.player_hit_signal.connect(_on_player_hit)
	player_controller.sprite_change.connect(_on_sprite_change)
	

func _on_sprite_change(animation:String)->void:
	player_sprite.play(animation)
	Events.sfx_play(animation, global_position, false, false)

	
func _on_player_hit():
	Events.game_over()
	get_parent().queue_free()
	
	pass
