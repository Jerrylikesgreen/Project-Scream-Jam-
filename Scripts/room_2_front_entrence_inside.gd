class_name Room2 extends Room


var killer_is_coming: Timer
var _killer: Killer = null 


func _ready() -> void:
	Events.room_changed_signal.connect(_on_room_change_signal)
	Globals.player.global_position = spawn_point.global_position
	if Globals.player == null or not is_instance_valid(Globals.player):
		Globals.player = Globals.PLAYER.instantiate()
	call_deferred("add_child", Globals.player)
	Globals.player.global_position = spawn_point.global_position
	KillerManager.start_countdown()
	print(KillerManager.killer_active, "ready Room 2")
	print(Globals.killer_has_not_appeared)
	
