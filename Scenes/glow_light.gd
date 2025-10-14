class_name GlowLight extends Pointlight


func _ready() -> void:
	_light_bright_range = randf_range(0.1, 0.5)
	randomize()
	_pick_new_randoms()
	if flicker_enabled:
		call_deferred("light_flicker_logic")
		
		
