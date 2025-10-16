class_name Retry extends Button


func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed()->void:
	Events.game_restart()
