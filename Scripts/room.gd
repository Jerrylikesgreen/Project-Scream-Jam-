class_name Room extends Node2D


@onready var spawn_point: Node2D = %SpawnPoint
var killer_spawn_countdown: Timer



func _ready() -> void:
	if Globals.player == null or not is_instance_valid(Globals.player):
		Globals.player = Globals.PLAYER.instantiate()
	add_child(Globals.player)
	Globals.player.global_position = spawn_point.global_position

	if KillerManager.killer_in_other_room and KillerManager.killer_active:
		killer_spawn_countdown = Timer.new()
		add_child(killer_spawn_countdown)
		killer_spawn_countdown.wait_time = 10.0
		killer_spawn_countdown.timeout.connect(_on_killer_countdown_timeout)
		killer_spawn_countdown.start()



		

	

func _on_killer_countdown_timeout() ->void:
	if KillerManager.killer_count > 0:
		return
	var killer_instance =  KillerManager.KILLER.instantiate()
	print(killer_instance)
	add_child(killer_instance)
	KillerManager.killer_count += 1
	KillerManager.killer = killer_instance
	killer_instance.position = spawn_point.global_position
	KillerManager.killer_in_other_room = false
