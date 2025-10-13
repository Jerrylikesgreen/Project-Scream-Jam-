class_name InteractibleObject
extends StaticBody2D

signal point_gain
@onready var interactible_object_collision_shape_2d: CollisionShape2D = %InteractibleObjectCollisionShape2D
@onready var interactible_object_sprite_2d: Sprite2D = %InteractibleObjectSprite2D
@onready var interactible_object_progress_bar: ProgressBar = %InteractibleObjectProgressBar

## Flag for when the player  intereacts with obj
@export var player_triggered:bool = false
## Flag for when the killer intereacts with obj
@export var killer_trigger: bool = false
## Flag for when the the object is active
@export var active:bool = false
@export var action_speed: float = 2.0  
@export var points:int
## current value of progress dont on obj. 
var action_count: float = 0.0
## flag to determin if its being interacted with in real time. 
var is_acting: bool = false
## time per sec it will take to complete interaction. 


func _ready() -> void:
	# ensure bar is configured
	interactible_object_progress_bar.max_value = 100.0
	interactible_object_progress_bar.value = 0.0
	interactible_object_progress_bar.visible = false

func _process(_delta: float) -> void:
	if is_acting:

		action_count += ( 100.0 / action_speed ) * _delta

		if action_count >= 100.0:
			action_count = 100.0
			is_acting = false
			if active:
				action_complete()
			else:
				action_incomplete()

	interactible_object_progress_bar.value = action_count


func action_incomplete() ->void:
	print("Incomplete")
	interactible_object_progress_bar.visible = false
	action_count = 0.0
	
	
func action() -> void:
	if not is_acting:
		is_acting = true
		interactible_object_progress_bar.visible = true
		if !active:
			print("Action started (frame-based increment)")





func action_complete() -> void:
	print("Action complete!")
	interactible_object_progress_bar.visible = false
	action_count = 0.0
	emit_signal("point_gain", points)
