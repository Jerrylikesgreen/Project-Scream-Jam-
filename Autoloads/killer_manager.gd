# KillerManager.gd
extends Node
const  KILLER = preload("res://Scenes/killer.tscn")

var killer_in_other_room:bool = false:
	set(val):
		killer_in_other_room = val;
		if val:
			killer = null;
		return;

var killer_active:bool = false

var killer_body:Killerbody = null;

var killer:Killer = null:
	set(k):
		killer = k;
		if k == null:
			killer_body = null;
			return;
		killer_body = k.find_child("Killer Body",false);
		return;

var killer_count:int = 0


func player_in_line_of_sight(player_body:PlayerBody):
	print("line_of_sight called")
	if(killer != null):
		print("killer not null")
		var ray:RayCast2D = RayCast2D.new();
		killer_body.add_child(ray)
		ray.global_position = killer_body.global_position;
		ray.target_position = killer_body.global_position.direction_to(player_body.global_position)*100
		#(killer_body.to_local(player_body.global_position))*1.5;
		ray.collide_with_bodies = true;
		ray.collide_with_areas = false;
		ray.set_collision_mask_value(6,true);
		ray.set_collision_mask_value(1,true);
		ray.collision_mask = 33; #1 + 32 = 2^0 + 2^5 = layers 1 and 6(players and walls)
		#need to wait for physics frames to elapse
		#before seeing collisions
		await get_tree().physics_frame;
		ray.global_position = killer_body.global_position;
		ray.target_position = killer_body.global_position.direction_to(player_body.global_position)*100;
		await get_tree().physics_frame;
		if(ray.is_colliding()):
			print(ray.get_collider().name);
			if ray.get_collider() == player_body:
				ray.queue_free();
				return true
		ray.queue_free();
	return false;
