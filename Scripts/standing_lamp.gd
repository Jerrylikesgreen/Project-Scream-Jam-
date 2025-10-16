@tool 
class_name StandingLamp extends InteractibleObject

@onready var lamp_point_light: Pointlight = %LampPointLight
@export var outside:bool = false


func _ready() -> void:
	if outside:
		lamp_point_light.light_bright_max = 0.8

func _process(_delta: float) -> void:
	if outside:
		
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


func action_complete() -> void:
	
	print("Action complete!")
	interactible_object_progress_bar.visible = false
	action_count = 0.0
	emit_signal("point_gain", points)
	lamp_point_light.set_enabled(true)
