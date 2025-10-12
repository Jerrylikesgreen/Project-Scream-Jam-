class_name SceneManager extends Node2D
@onready var spawn_point: Marker2D = %SpawnPoint

func _ready() -> void:
	var player = Globals.player
	add_child(player)
	player.position = spawn_point.global_position
	
