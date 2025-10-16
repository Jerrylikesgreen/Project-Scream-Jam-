class_name Room extends Node2D


@onready var spawn_point: Node2D = %SpawnPoint
var killer_spawn_countdown: Timer
@onready var switch: Switch1 = $Switches/switch


func _ready() -> void:
	if get_tree().get_nodes_in_group("Player").is_empty():
		var player = Globals.player
		add_child(player) 
		player.global_position = spawn_point.global_position
	if KillerManager.killer_in_other_room:
		killer_spawn_countdown = Timer.new()
		add_child(killer_spawn_countdown)
		killer_spawn_countdown.set_wait_time(10.0)
		killer_spawn_countdown.timeout.connect(_on_killer_countdown_timeout)
		killer_spawn_countdown.start()
		

func _process(delta: float) -> void:
	if killer_spawn_countdown:
		var wt: String =   str(killer_spawn_countdown.get_time_left()) 
	

func _on_killer_countdown_timeout() ->void:
	if KillerManager.killer_count > 0:
		return
	var killer_instance =  KillerManager.KILLER.instantiate()
	add_child(killer_instance)
	KillerManager.killer_count += 1
	KillerManager.killer = killer_instance
	killer_instance.position = spawn_point.global_position
	KillerManager.killer_in_other_room = false
