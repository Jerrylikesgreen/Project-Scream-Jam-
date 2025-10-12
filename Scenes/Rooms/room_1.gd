class_name Room1 extends Node2D


@onready var spawn_point: Node2D = %SpawnPoint

func _ready() -> void:
	if get_tree().get_nodes_in_group("Player").is_empty():
		var player = Globals.PLAYER.instantiate()
		add_child(player)
		player.global_position = spawn_point.global_position
	if get_tree().get_nodes_in_group("Killer").is_empty():
		KillerManager.spawn_enemies_for_scene(self)
