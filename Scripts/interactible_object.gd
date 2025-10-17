@tool 
class_name InteractibleObject
extends StaticBody2D

signal point_gain
@onready var interactible_object_collision_shape_2d: CollisionShape2D = %InteractibleObjectCollisionShape2D
@onready var interactible_object_sprite_2d: Sprite2D = %InteractibleObjectSprite2D
@onready var interactible_object_progress_bar: ProgressBar = %InteractibleObjectProgressBar


## If flip_h is true will flip Horizontal else will flip verticle 
@export var flip_h:bool = true
@export_tool_button("Flip Sprite") var flip_sprite_action = flip_sprite

@export var resource: ItemResource
## stores the current flip state on this node so it persists
@export var flip_state_h: bool = false
@export var flip_state_v: bool = false
@export var _outside:bool = false
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
var sprite_rect: Rect2


func _ready() -> void:
	interactible_object_sprite_2d.flip_h = flip_state_h
	interactible_object_sprite_2d.flip_v = flip_state_v
	interactible_object_progress_bar.max_value = 100.0
	interactible_object_progress_bar.value = 0.0
	interactible_object_progress_bar.visible = false
	var shape := RectangleShape2D.new()
	shape.size == resource.image.get_size()
	interactible_object_collision_shape_2d.set_shape(shape)

func _process(_delta: float) -> void:
	if _outside:
			return
	if is_acting:
		if !active and player_triggered:
			action_incomplete()


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
	is_acting = false;
	player_triggered = false;
	Events.display_player_message("（＞д＜）")
	
func action() -> void:
	if _outside:
			return
	if not is_acting:
		is_acting = true
		interactible_object_progress_bar.visible = true
		if !active:
			print("Action started (frame-based increment)")


func action_complete() -> void:
	print("Action complete!")
	interactible_object_progress_bar.visible = false
	action_count = 0.0
	Events.player_gains_points(points)
	print(InventoryManager.inventory)
	Events.display_player_message("(o_O) ?!")



func flip_sprite() -> void:
	if not interactible_object_sprite_2d:
		push_warning("object_sprite not assigned")
		return

	if flip_h:
		flip_state_h = not flip_state_h
		interactible_object_sprite_2d.flip_h = flip_state_h
	else:
		flip_state_v = not flip_state_v
		interactible_object_sprite_2d.flip_v = flip_state_v

	print("Sprite flipped", "H" if flip_h else "V")
