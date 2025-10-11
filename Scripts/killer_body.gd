## Movement / Action logic.
class_name Killerbody extends CharacterBody2D

@onready var killer_sprite: AnimatedSprite2D = $KillerSprite
@onready var patrol_area: Area2D = %PatrolArea
@export var speed: int = 100


## Killer's Body State Machine
enum KillerState { IDLE, STUNNED, PATROL, CHASING, ATTACK, ACTION }
var killer_state: KillerState = KillerState.IDLE
var _idle_timer: float = 0.0
var _chosen_node: CollisionShape2D = null
var _target_position: Vector2 = Vector2.ZERO
var _count: int = 3

func _ready():
	randomize()
	_pick_area()
	_pick_patrol_target_position()

func _physics_process(_delta: float) -> void:
	match killer_state:
		KillerState.IDLE:
			_idle_logic(_delta)
		KillerState.PATROL:
			_patrol_logic(_delta)


@export var idle_duration: float = 1.0  # seconds

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


func _pick_area() -> void:
	var rect_shapes := []
	for child in patrol_area.get_children():
		if child is CollisionShape2D and child.shape is RectangleShape2D:
			rect_shapes.append(child)
	## Runtime check to ensure Collision Shape is there. 
	if rect_shapes.is_empty():
		push_warning("No RectangleShape2D found in patrol_area")
		_chosen_node = null
		_target_position = patrol_area.global_position
		return

	## Picks a random collision shape
	_chosen_node = rect_shapes[randi() % rect_shapes.size()]


func _patrol_logic(_delta: float) -> void:
	killer_sprite.play("Moving")
	var to_target = _target_position - global_position
	if to_target.length() > 2.0:
		velocity = to_target.normalized() * speed

		# Flip sprite based on movement direction
		if velocity.x != 0:
			killer_sprite.flip_h = velocity.x < 0

		move_and_slide()
	else:
		# Reached patrol point → switch to IDLE
		velocity = Vector2.ZERO
		killer_state = KillerState.IDLE
		_idle_timer = 0.0




func _pick_patrol_target_position() -> void:
	if _chosen_node == null:
		_target_position = patrol_area.global_position
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
