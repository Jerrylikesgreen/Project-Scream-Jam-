class_name TitleScreen 
extends Control
@onready var start_button: Button = %StartButton


func _ready() -> void:
	start_button.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/test_level.tscn")
