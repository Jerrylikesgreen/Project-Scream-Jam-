@tool 
class_name StandingLamp extends InteractibleObject

@onready var lamp_point_light: Pointlight = %LampPointLight


func action_complete() -> void:
	print("Action complete!")
	interactible_object_progress_bar.visible = false
	action_count = 0.0
	emit_signal("point_gain", points)
	lamp_point_light.set_enabled(true)
