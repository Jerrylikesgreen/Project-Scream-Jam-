class_name Room2 extends Room


var killer_is_coming: Timer
var _killer: Killer = null 


func _ready() -> void:

	if Globals.player == null or not is_instance_valid(Globals.player):
		Globals.player = Globals.PLAYER.instantiate()
	call_deferred("add_child", Globals.player)
	Globals.player.global_position = spawn_point.global_position
	
	if Globals.killer_has_not_appeared == true:
		killer_is_coming = Timer.new()
		call_deferred("add_child", killer_is_coming)
		killer_is_coming.timeout.connect(_on_killer_is_coming)
		killer_is_coming.set_one_shot(true)
		call_deferred("start", 10.0)

	
	if KillerManager.killer_in_other_room and KillerManager.killer_active == true :
		killer_spawn_countdown = Timer.new()
		call_deferred("add_child", killer_spawn_countdown)
		killer_spawn_countdown.set_wait_time(10.0)
		killer_spawn_countdown.timeout.connect(_on_killer_is_coming)
		killer_spawn_countdown.start()
		print(KillerManager.killer_active)
		
	print(KillerManager.killer_active, "ready Room 2")
	print(Globals.killer_has_not_appeared)
	

func _on_killer_is_coming()->void:
	Globals.killer_has_not_appeared = false
	print("Killer Incomming")
	killer_is_coming.queue_free()
	if KillerManager.killer == null:
		KillerManager.killer = KillerManager.KILLER.instantiate()
	
	_killer = KillerManager.killer
	_killer.global_position = spawn_point.global_position
	call_deferred("add_child", _killer)
	print("Killer Spawned ", _killer.global_position)
