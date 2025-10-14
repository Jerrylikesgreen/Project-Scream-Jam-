# KillerManager.gd
extends Node
const KILLER = preload("uid://cu6b24mvag412")

var killer_in_other_room:bool = false:
	set(val):
		killer_in_other_room = val;
		if val:
			killer = null;
var killer_body:Killerbody = null;
var killer:Killer = null:
	set(k):
		if k == null:
			killer_body = null;
			return;
		killer_body = k.find_child("Killer Body",false);
		return;
		

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
	
func player_in_line_of_sight(player_body:PlayerBody):
	if(killer != null):
		var ray:RayCast2D = RayCast2D.new();
		killer_body.add_child(ray)
		ray.global_position = killer_body.global_position;
		ray.target_position = killer_body.to_local(player_body.global_position);
		ray.collide_with_bodies = true;
		ray.collide_with_areas = false;
		ray.set_collision_mask_value(6,true);
		ray.set_collision_mask_value(1,true);
		if(ray.is_colliding()):
			if ray.get_collider() == player_body:
				ray.queue_free();
				return true
		ray.queue_free();
		return false;
		
		
