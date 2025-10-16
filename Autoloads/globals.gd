## Autoloads - Globals 
extends Node
const PLAYER = preload("uid://bja82w2ernttj")

var player = PLAYER.instantiate()

const DATA = preload("uid://bh74vn115iw2k")

var player_data: DataResource

func _ready() -> void:
	player_data = DATA.load() 
