@tool 
class_name Door extends InteractibleObject


## Unsed to determin which key can unlock this door. 
@export var lock_uid: int

func action_complete() -> void:
	interactible_object_collision_shape_2d.queue_free()
	interactible_object_progress_bar.visible = false
	action_count = 0.0
	emit_signal("point_gain", points)
	interactible_object_sprite_2d.set_frame(0)
