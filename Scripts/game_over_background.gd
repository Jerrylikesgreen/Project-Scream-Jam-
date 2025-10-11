class_name GameOverBackground extends ColorRect

@onready var restart: Button = %Restart


func _ready() -> void:
	Events.player_hit_signal.connect(_on_player_hit) ## Will change this to connecting to a Game over signal later.
	restart.pressed.connect(restart_game) 
	

func _on_player_hit()->void:
	set_visible(true)



func restart_game():
	get_tree().reload_current_scene()
