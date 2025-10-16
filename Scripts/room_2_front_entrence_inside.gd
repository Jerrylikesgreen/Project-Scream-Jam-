class_name Room2 extends Room



func _ready() -> void:
	
	if get_tree().get_nodes_in_group("Player").is_empty():
		var player = Globals.player
		player.global_position = spawn_point.global_position
		add_child(player)
	if KillerManager.killer_in_other_room:
		killer_spawn_countdown = Timer.new()
		add_child(killer_spawn_countdown)
		killer_spawn_countdown.set_wait_time(10.0)
		killer_spawn_countdown.timeout.connect(_on_killer_countdown_timeout)
		killer_spawn_countdown.start()
