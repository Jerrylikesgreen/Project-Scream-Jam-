class_name Killerbody
extends CharacterBody2D

@onready var debug: Label = %Debug
@onready var killer_sprite: AnimatedSprite2D = $KillerSprite
@onready var patrol_area: Area2D = %PatrolArea
@onready var vision: Area2D = %Vision
@onready var hit_box: Area2D = %HitBox
@onready var pathfinder:NavigationAgent2D = %PathfinderToPlayer

@export var speed: int = 100
@export var idle_duration: float = 1.0  # seconds
@export var attack_range: float = 25.60
@export var packed_scene: PackedScene
@onready var label: Label = %Label

## Killer's Body State Machine
enum KillerState { IDLE, STUNNED, PATROL, CHASING, ATTACK, ACTION }
var killer_state: KillerState = KillerState.IDLE
var _leaving_area:bool = false
var player_ref: CharacterBody2D
var _idle_timer: float = 0.0
var _chosen_node: Node2D = null
var _target_position: Vector2 = Vector2.ZERO
var _count: int = 3
var _action_target: InteractibleObject = null
var _current_area: Area2D = null

func _ready():
	randomize()
	_pick_area()
	_pick_patrol_target_position()
	vision.body_entered.connect(_on_body_entered)
	vision.body_exited.connect(_on_body_exited)

func _physics_process(_delta: float) -> void:
	debug.set_text(str(killer_state))
	match killer_state:
		KillerState.IDLE:
			_idle_logic(_delta)
		KillerState.PATROL:
			_patrol_logic(_delta)
		KillerState.CHASING:
			_chase_logic(_delta)
		KillerState.ATTACK:
			_attack_logic(_delta)
		KillerState.ACTION:
			_action_logic(_delta)  # <-- ADDED: handle ACTION each physics frame
	
func handle_transition_area(area: Area2D) -> void:
	if not area.is_in_group("TransitionArea"):
		return
	var target_scene: PackedScene = area.transition_to_scene
	if target_scene == null:
		push_warning("Transition area missing target scene")
		return
	var state := {
		"scene_packed": preload("res://Scenes/killer.tscn"),
		"patrol_count": _count,
	}
	KillerManager.queue_killer_for_scene(target_scene, state)
	queue_free()

func _on_body_entered(body: Node2D)->void:
	if body.is_in_group("Player"):
		_target_position = body.global_position
		player_ref = body
		if killer_state == KillerState.STUNNED:
			return
		killer_state = KillerState.CHASING

func _on_body_exited(body: Node2D)->void:
	if body.is_in_group("Player"):
		player_ref = null

func _idle_logic(delta: float) -> void:
	killer_sprite.play("Idle")
	_idle_timer += delta
	if _idle_timer >= idle_duration:
		_idle_timer = 0.0
		label.visible = false
		_count -= 1
		if _count <= 1:
			if _current_area:
				var objs = _current_area.get_overlapping_bodies()
				if objs.size() > 0:
					var obj = objs[0]
					# avoid crash if obj doesn't have killer_trigger
					if obj.has_method("has_meta") or obj.has_meta("killer_trigger") or ("killer_trigger" in obj): # defensive; adjust to your object
						if obj.killer_trigger == false:
							_action_target = obj
							_target_position = obj.global_position
							# set the state and let physics_process call _action_logic each frame
							killer_state = KillerState.ACTION
							return
					else:
						# If obj doesn't have killer_trigger property, still safe to set target
						_action_target = obj
						_target_position = obj.global_position
						killer_state = KillerState.ACTION
						return
			_pick_area()
			_count = 3
		_pick_patrol_target_position()
		killer_state = KillerState.PATROL

func _action_logic(_delta: float) ->void:
	# Keep running every physics frame while in ACTION state
	killer_sprite.play("Moving")
	var to_target = _target_position - global_position
	if to_target.length() > 2.0:
		velocity = to_target.normalized() * speed

		# Flip sprite based on movement direction
		if velocity.x != 0:
			var facing_left = velocity.x < 0
			killer_sprite.flip_h = facing_left
			if facing_left:
				vision.rotation_degrees = 180.0
			else:
				vision.rotation_degrees = 0.0

		move_and_slide()
	else:
		velocity = Vector2.ZERO
		# if action target exists and has action_speed, use it safely
		if _action_target != null:
			idle_duration = _action_target.action_speed
		elif _action_target != null and ("action_speed" in _action_target):
			idle_duration = _action_target.action_speed
		# show label if relevant
		label.visible = true
		await get_tree().create_timer(idle_duration)
		_action_target.killer_trigger = true
		killer_state = KillerState.PATROL
		

func _attack_logic(_delta: float) -> void:
	if player_ref == null:
		killer_state = KillerState.PATROL
		return
	killer_sprite.play("Attack")
	hit_box.visible = true
	var body_hit =  hit_box.get_overlapping_bodies()
	for bodies in body_hit:
		if bodies.is_in_group("Player"):
			Events.player_hit_event()
	print("Attack")

func _chase_logic(_delta: float) -> void:
	if player_ref == null:
		killer_state = KillerState.PATROL
		return
	if player_ref.player_controller.hiding:
		killer_state = KillerState.PATROL
		return
	_target_position = player_ref.global_position
	var dist_sq = global_position.distance_squared_to(player_ref.global_position)
	var attack_range_sq = attack_range * attack_range
	#Attack if in the attack range
	if dist_sq <= attack_range_sq:
		killer_sprite.flip_h = (player_ref.global_position.x < global_position.x)
		killer_state = KillerState.ATTACK
		return
	pathfinder.target_position = player_ref.global_position;
	var current_position = global_position;
	var next_path_point:Vector2 = pathfinder.get_next_path_position();
	var target_vel:Vector2 = current_position.direction_to(next_path_point)*speed;
	velocity = target_vel;
	move_and_slide();
	#var to_target = _target_position - global_position
	#if to_target.length() > 2.0:
		#velocity = to_target.normalized() * speed
		#if velocity.x != 0:
			#var facing_left = velocity.x < 0
			#killer_sprite.flip_h = facing_left
			#if facing_left:
				#vision.rotation_degrees = 180.0
			#else:
				#vision.rotation_degrees = 0.0
		#move_and_slide()
	#else:
		#velocity = Vector2.ZERO

func _pick_area() -> void:
	var rect_shapes := []
	var trans_area := []
	_current_area = null
	for child in patrol_area.get_children():
		# we expect CollisionShape2D nodes under patrol_area
		if child is CollisionShape2D:
			# skip transition areas (groups are on the parent Area2D typically)
			var parent_area = child.get_parent()
			if parent_area != null and parent_area.is_in_group("TransitionArea"):
				trans_area.append(child)
				continue
			# only RectangleShape2D shapes are valid for random points
			if child.shape is RectangleShape2D:
				rect_shapes.append(child)
				# set _current_area to parent area (if desired)
				_current_area = child.get_parent()
		# if child itself is an Area2D that holds an interactable object
		elif child is Area2D:
			# attempt to find action target stored on that area
			var obj_candidate = child.get_parent()
			if obj_candidate != null and obj_candidate.has_method("action_speed"):
				_action_target = obj_candidate

	if rect_shapes.is_empty():
		push_warning("No RectangleShape2D found in patrol_area")
		_chosen_node = null
		_target_position = patrol_area.global_position
		return

	var chance_to_leave_scene = randi_range(1, 4)
	if chance_to_leave_scene == 1 and trans_area.size() > 0:
		_chosen_node = trans_area[randi() % trans_area.size()]
		return

	_chosen_node = rect_shapes[randi() % rect_shapes.size()]

func _patrol_logic(_delta: float) -> void:
	killer_sprite.play("Moving")
	var to_target = _target_position - global_position
	if to_target.length() > 2.0:
		velocity = to_target.normalized() * speed
		if velocity.x != 0:
			var facing_left = velocity.x < 0
			killer_sprite.flip_h = facing_left
			if facing_left:
				vision.rotation_degrees = 180.0
			else:
				vision.rotation_degrees = 0.0
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		killer_state = KillerState.IDLE
		_idle_timer = 0.0

func get_state_dict() -> Dictionary:
	var state := {
		"scene_packed": packed_scene,
		"position": global_position,
	}
	return state

func restore_state(state: Dictionary) -> void:
	if state.has("position"):
		global_position = state["position"]

func _pick_patrol_target_position() -> void:
	if _chosen_node == null:
		_target_position = patrol_area.global_position - position
		return
	if _chosen_node is Area2D:
		_target_position = _chosen_node.global_position
		print("Area selected")
		return
	var shape = _chosen_node.shape as RectangleShape2D
	var ext = shape.extents
	var random_point = Vector2(
		randf_range(-ext.x, ext.x),
		randf_range(-ext.y, ext.y)
	)
	_target_position = patrol_area.global_position + _chosen_node.position + random_point
