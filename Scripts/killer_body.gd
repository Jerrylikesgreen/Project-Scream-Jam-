## Movement / Action logic. 
class_name Killerbody extends CharacterBody2D

@onready var patrol_area: Area2D = %PatrolArea

@export var speed:int = 100

## Killer State Machine
enum KillerState{ IDLE, STUNNED, PATROL, CHASING, ATTACK, ACTION }
var killer_state: KillerState = KillerState.IDLE

var _target_position: Vector2


func _physics_process(delta: float) -> void:
	var to_target = _target_position - global_position
	if to_target.length() > 2.0:
		velocity = to_target.normalized() * speed
		move_and_slide()
	else:
		_pick_partol_target_position()


## Will pick a random Vector2 from the Patrol Area TODO -> Establish Patriol Areas on Player Objections, currently using a random area location. 
## Currently will only functions with Rectangle Collision shapes on area 2d Nodes.  
func _pick_partol_target_position()->void:
	var shape_node:= patrol_area.get_node("CollisionShape2D")
	var shape = shape_node.shape
	
	var ext = shape.extents
	var random_point = Vector2(randf_range(-ext.x, ext.x), randf_range(-ext.y, ext.y))
	
	_target_position = patrol_area.global_position + random_point
	
	
