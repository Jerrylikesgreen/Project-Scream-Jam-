@tool 
class_name Workbench extends ObjectNonInteractive



func _ready() -> void:
	var rnd = randi_range(0, 3)
	object_sprite.set_frame(rnd)
