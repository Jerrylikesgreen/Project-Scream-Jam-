# KillerManager.gd
extends Node
const KILLER = preload("uid://cu6b24mvag412")

var killer_in_other_room:bool = false

## 	   the PackedScene contains target_scene: PackedScene = area.transition_to_scene 
## 	   the Dictionary is a var called state contains= {
##	   	"scene_packed": preload("res://Scenes/killer.tscn"),
##	   	"patrol_count": _count,Dictionary is  target_scene: PackedScene = area.transition_to_scene }
var _current: Dictionary[PackedScene, Dictionary]


## 	var target_scene: PackedScene = area.transition_to_scene
##	var state := {
##		"scene_packed": preload("res://Scenes/killer.tscn"),
##		"patrol_count": _count,
func queue_killer_for_scene(target_scene: PackedScene, state: Dictionary)->void:
	_current[target_scene] = state
