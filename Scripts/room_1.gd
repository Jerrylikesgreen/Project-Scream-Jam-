class_name Room1 extends Room




func _ready() -> void:
	
	if get_tree().get_nodes_in_group("Player").is_empty():
		var player = Globals.PLAYER.instantiate()
		add_child(player)
		player.global_position = spawn_point.global_position
	if KillerManager.killer_in_other_room:
		killer_spawn_countdown = Timer.new()
		add_child(killer_spawn_countdown)
		killer_spawn_countdown.set_wait_time(10.0)
		killer_spawn_countdown.timeout.connect(_on_killer_countdown_timeout)
		killer_spawn_countdown.start()
		
	if Events.game_start:
		Events.display_player_message("Where am I?")
		_game_start()


func _game_start()->void:
	Events.game_start= false 
