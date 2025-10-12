class_name InteractibleObject
extends StaticBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var progress_bar: ProgressBar = $ProgressBar

## Flag for when the player  intereacts with obj
@export var player_triggered:bool = false
## Flag for when the killer intereacts with obj
@export var killer_trigger: bool = false
## Flag for when the the object is active
@export var active:bool = false

## current value of progress dont on obj. 
var action_count: float = 0.0
## flag to determin if its being interacted with in real time. 
var is_acting: bool = false

## time per sec it will take to complete interaction. 
var action_speed: float = 2.0  

func _ready() -> void:
	# ensure bar is configured
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0
	progress_bar.visible = false

func _process(_delta: float) -> void:
	if is_acting:

		action_count += ( 100.0 / action_speed ) * _delta

		if action_count >= 100.0:
			action_count = 100.0
			is_acting = false
			action_complete()

	progress_bar.value = action_count


func action() -> void:
	if not is_acting:
		is_acting = true
		progress_bar.visible = true
		print("Action started (frame-based increment)")


func action_complete() -> void:
	print("Action complete!")
	progress_bar.visible = false
	action_count = 0.0
