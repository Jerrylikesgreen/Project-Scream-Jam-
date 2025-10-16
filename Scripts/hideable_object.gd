class_name HideableObject extends StaticBody2D

@export var sprite_texture:Texture2D;
@onready var sprite:Sprite2D = %Sprite;
func _ready()->void:
	sprite.texture = sprite_texture;
