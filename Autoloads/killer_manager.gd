# KillerManager.gd
extends Node
const  KILLER = preload("res://Scenes/killer.tscn")


var killer_in_other_room:bool = false:
	set(val):
		killer_in_other_room = val;
		if val:
			print("killer_in_other_room set to True");
			killer = null;
		return;

var killer_active:bool = false
var active_room: Room
var killer_body:Killerbody = null;
var timer:Timer
var killer:Killer = null:
	set(k):
		killer = k;
		if k == null:
			killer_body = null;
			return;
		killer_body = k.find_child("Killer Body",false);
		return;

var killer_count:int = 0


func _ready() -> void:
	print("Ready ->" , self.name)


func _spawn_killer()->void:
	var room = get_tree().get_first_node_in_group("Room")
	if killer:
		print("killer not instantiated.")
		killer.global_position = room.spawn_point.global_position
		killer_body.global_position = room.spawn_point.global_position
		print( self.name, 
		"-> Killers Positioin:  " ,killer.global_position,
		" Spawnpoint Position  :", room.spawn_point.global_position)
	else:
		killer = KILLER.instantiate()
		print("Killer instantiated")
		killer.global_position = room.spawn_point.global_position
		killer_body.global_position = room.spawn_point.global_position
		room.add_child(killer) 
		
		print( self.name, 
		"-> Killers Positioin:  " ,killer.global_position,
		" Spawnpoint Position  :", room.spawn_point.global_position)
	
func stun()->void:
	killer.stun()
	Events.play_bgm(1)
	pass
var _count: int =0

func _on_killer_countdown_timeout()->void:
	_count =+ 1
	if _count >2 and  _count < 4:
		Events.play_bgm(2)
	_spawn_killer()
	killer_active = true


func start_countdown() -> void:
	print("Coundown Start")
	if killer_active:
		return
	if timer:
		timer.start();
		return
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 20.0
	timer.one_shot = true
	timer.timeout.connect(_on_killer_countdown_timeout)
	var nodes = get_tree().get_nodes_in_group("Room")
	for node in nodes:
		if node is Room:
			node.add_child(timer)
	


func player_in_line_of_sight(player_body:PlayerBody):
	print("line_of_sight called")
	Events.sfx_play("Buildup", killer.global_position, false, false)
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
		ray.collision_mask = 33; #1 + 32 = 2^0 + 2^5 = layers 1 and 6(players and walls) I hate bit math. 
		#need to wait for physics frames to elapse
		#before seeing collisions
		await get_tree().physics_frame;
		ray.global_position = killer_body.global_position;
		ray.target_position = killer_body.global_position.direction_to(player_body.global_position)*100;
		await get_tree().physics_frame;
		if(ray.is_colliding()):
			print(ray.get_collider().name);
			if ray.get_collider() == player_body:
				Events.sfx_play("Spotted", killer.global_position, false, false)
				ray.queue_free();
				return true
		ray.queue_free();
	return false;
