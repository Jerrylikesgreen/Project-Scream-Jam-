## Movement / Action logic.
class_name Killerbody extends CharacterBody2D

@onready var killer_sprite: AnimatedSprite2D = $KillerSprite
@onready var patrol_area: Area2D = %PatrolArea
@onready var vision: Area2D = %Vision
@onready var hit_box: Area2D = %HitBox

@export var speed: int = 100
@export var idle_duration: float = 1.0  # seconds
@export var attack_range: float = 25.60
@export var packed_scene: PackedScene   



## Killer's Body State Machine
enum KillerState { IDLE, STUNNED, PATROL, CHASING, ATTACK, ACTION }
var killer_state: KillerState = KillerState.IDLE
var _leaving_area:bool = false
var player_ref: CharacterBody2D
var _idle_timer: float = 0.0
var _chosen_node: Node2D = null
var _target_position: Vector2 = Vector2.ZERO
var _count: int = 3


func _ready():
	randomize()
	_pick_area()
	_pick_patrol_target_position()
	vision.body_entered.connect(_on_body_entered)
	vision.body_exited.connect(_on_body_exited)

func _physics_process(_delta: float) -> void:
	match killer_state:
		KillerState.IDLE:
			_idle_logic(_delta)
		KillerState.PATROL:
			_patrol_logic(_delta)
		KillerState.CHASING:
			_chase_logic(_delta)
		KillerState.ATTACK:
			_attack_logic(_delta)

func handle_transition_area(area: Area2D) -> void:
	# optional: check area group/type
	if not area.is_in_group("TransitionArea"):
		return

	# If you want the Killer to be queued for that scene:
	var target_scene: PackedScene = area.transition_to_scene
	if target_scene == null:
		push_warning("Transition area missing target scene")
		return

	# prepare state dictionary (whatever you need later)
	var state := {
		"scene_packed": preload("res://Scenes/killer.tscn"),
		"patrol_count": _count,
		"facing_left": killer_sprite.flip_h,
		# other fields you want to preserve...
	}

	# queue & remove this instance
	KillerManager.queue_killer_for_scene(target_scene, state)
	queue_free()



func _on_body_entered(body: Node2D)->void:
	if body.is_in_group("Player"):
		_target_position = body.global_position
		player_ref = body
		
		if killer_state == KillerState.STUNNED:
			return
		
		killer_state = KillerState.CHASING
		pass

func _on_body_exited(body: Node2D)->void:
	if body.is_in_group("Player"):
		player_ref = null

func _idle_logic(_delta: float) -> void:
	killer_sprite.play("Idle")
	_idle_timer += _delta
	if _idle_timer >= idle_duration:
		_idle_timer = 0.0
		## Picks a new point in the same area
		_count -= 1
		if _count <= 1:
			_pick_area()
			_count = 3
		_pick_patrol_target_position()
		killer_state = KillerState.PATROL

func _attack_logic(_delta: float) -> void:
	## Checks for player refrence. 
	if player_ref == null:
		killer_state = KillerState.PATROL
		return 
	killer_sprite.play("Attack")
	hit_box.set_visible(true)
	var body_hit =  hit_box.get_overlapping_bodies()
	for bodies in body_hit:
		if bodies.is_in_group("Player"):
			Events.player_hit_signal.emit()

	print("Attack")

func _chase_logic(_delta: float) -> void:
	## Checks for player refrence. 
	if player_ref == null:
		killer_state = KillerState.PATROL
		return 
		
	## Keeps track of target position
	_target_position = player_ref.global_position
	
	## Sq Distance for faster Calculations
	var dist_sq = global_position.distance_squared_to(player_ref.global_position)
	var attack_range_sq = attack_range * attack_range
	
	##Checking if player is in attack range. 
	if dist_sq <= attack_range_sq:
		killer_sprite.flip_h = (player_ref.global_position.x < global_position.x)
		killer_state = KillerState.ATTACK
		return
	
	## Movement to player logic. 
	var to_target = _target_position - global_position
	if to_target.length() > 2.0:
		velocity = to_target.normalized() * speed
		var facing_left = velocity.x < 0
		if velocity.x !=0:
			killer_sprite.flip_h = facing_left
		
		if facing_left:
			vision.set_rotation_degrees(180.0)
		else:
			vision.set_rotation_degrees(0.0)
		move_and_slide()
	else:
		
		velocity = Vector2.ZERO
		

func _pick_area() -> void:
	var rect_shapes := []
	var trans_area := []
	for area in patrol_area.get_children():
		if area is CollisionShape2D and area.shape is RectangleShape2D and !is_in_group("TransitionArea"):
			rect_shapes.append(area)
		if area.is_in_group("TransitionArea"):
			trans_area.append(area)
			
	## Runtime check to ensure Collision Shape is there. 
	if rect_shapes.is_empty():
		push_warning("No RectangleShape2D found in patrol_area")
		_chosen_node = null
		_target_position = patrol_area.global_position
		return
	## Currently its just a 25% chance of the Killer to pick to go to another Scene, will make this logic 
	## More fleshed out later. 
	var chance_to_leave_scene = randi_range(1, 4)
	if chance_to_leave_scene == 1 and trans_area.size() > 0:
		_chosen_node = trans_area[randi() % trans_area.size()]
		return

	# Otherwise pick a random normal rectangle
	_chosen_node = rect_shapes[randi() % rect_shapes.size()]

func _patrol_logic(_delta: float) -> void:
	killer_sprite.play("Moving")
	var to_target = _target_position - global_position
	if to_target.length() > 2.0:
		velocity = to_target.normalized() * speed

		# Flip sprite based on movement direction
		if velocity.x != 0:
			var facing_left = velocity.x < 0
			
			killer_sprite.flip_h = facing_left
			
			if facing_left:
				vision.set_rotation_degrees(180.0)
			else:
				vision.set_rotation_degrees(0.0)
			

		move_and_slide()
	else:
		# Reached patrol point → switch to IDLE
		velocity = Vector2.ZERO
		killer_state = KillerState.IDLE
		_idle_timer = 0.0

func get_state_dict() -> Dictionary:
	var state := {
		"scene_packed": packed_scene,             # resource to instantiate later
		"position": global_position,              # optional if you want exact pos
	}
	return state

# Restore state on a newly created instance (call after instantiate + add_child)
func restore_state(state: Dictionary) -> void:
	if state.has("position"):
		global_position = state["position"]




func _pick_patrol_target_position() -> void:
	if _chosen_node == null:
		_target_position = patrol_area.global_position - position
		return
	
	if _chosen_node is Area2D:
		_target_position = _chosen_node.global_position
		print("Area selectged")
		return
		
	var shape = _chosen_node.shape as RectangleShape2D
	var ext = shape.extents

	## Picks random point inside collision shape
	var random_point = Vector2(
		randf_range(-ext.x, ext.x),
		randf_range(-ext.y, ext.y)
	)

	## Converts local point to a global position
	_target_position = patrol_area.global_position + _chosen_node.position + random_point
