@tool 
class_name Door extends InteractibleObject

@onready var closed: Sprite2D = %Closed

## Unsed to determin which key can unlock this door. 
@export var lock_uid: int

func action_complete() -> void:
	closed.set_visible(false)
	interactible_object_collision_shape_2d.queue_free()
	interactible_object_progress_bar.visible = false
	action_count = 0.0
	emit_signal("point_gain", points)
