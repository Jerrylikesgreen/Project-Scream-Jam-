class_name Room extends Node2D


@onready var spawn_point: Node2D = %SpawnPoint
var killer_spawn_countdown: Timer
@export var no_killer:bool = false 
@onready var bgm_node: BGM = $BgmNode


func _ready() -> void:
	print(self.name)
	if Globals.player == null or not is_instance_valid(Globals.player):
		Globals.player = Globals.PLAYER.instantiate()
	add_child(Globals.player)
	Globals.player.global_position = spawn_point.global_position
	KillerManager.active_room = self
	Events.room_changed_signal.connect(_on_room_change_signal)
	if no_killer:
		return
	KillerManager.start_countdown()



func _on_room_change_signal()->void:
	if KillerManager.active_room == self:
		return
	KillerManager.active_room = self
