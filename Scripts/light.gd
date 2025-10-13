class_name Light extends InteractibleObject



@onready var lamp_light: PointLight2D = $LampLight

func action_complete() -> void:
	interactible_object_progress_bar.visible = false
	action_count = 0.0
	emit_signal("point_gain", points)
	lamp_light.set_enabled(true)
