## Autoloads - Globals 
extends Node
const PLAYER = preload("uid://bja82w2ernttj")

var player = null
const ROOM_1_FRONT_ENTRENCE_OUTSIDE = preload("uid://cvl8kf1nyvo88")

const DATA = preload("uid://bh74vn115iw2k")

var player_data: DataResource

var is_new_start:bool = true

var killer_has_not_appeared :bool = false

func _ready() -> void:
	player_data = DATA.duplicate()
