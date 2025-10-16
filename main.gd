## Main Autoload 
extends Node

const ROOM_1_FRONT_ENTRENCE_OUTSIDE = preload("uid://cvl8kf1nyvo88")


var room1: Node2D = null
func _ready() -> void:

	# sanity check
	assert(ROOM_1_FRONT_ENTRENCE_OUTSIDE is PackedScene)
	
	if Globals.is_new_start:
		Globals.is_new_start = false
		call_deferred("_deferred_change_scene")

	# else: load an already-initiated Room 1 into the current scene (e.g. when
	# resuming or when you want the room as a child of the current scene)
	if room1 != null:
		# already created
		return

	if ROOM_1_FRONT_ENTRENCE_OUTSIDE == null:
		push_error("ROOM_1_FRONT_ENTRENCE_OUTSIDE not set!")
		return

	room1 = ROOM_1_FRONT_ENTRENCE_OUTSIDE.instantiate() as Node2D
	if room1 == null:
		push_error("Failed to instantiate ROOM_1_FRONT_ENTRENCE_OUTSIDE")
		return

	room1.name = "Room1"

	var current := get_tree().get_current_scene()
	if current == null:
		# fallback: add to root if there's no current scene
		get_tree().get_root().call_deferred("add_child", room1)
	else:
		current.call_deferred("add_child", room1)


func _deferred_change_scene():
	get_tree().change_scene_to_packed(ROOM_1_FRONT_ENTRENCE_OUTSIDE)
