@tool 
class_name BrokenFurSide extends ObjectNonInteractive


var frames: Array[int] = [2,4,9]

func _ready() -> void:
	var r = randi_range(0, 2)
	object_sprite.set_frame(frames[r])
