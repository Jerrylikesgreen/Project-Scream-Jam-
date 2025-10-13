@tool 
class_name ObjectNonInteractive
extends Node2D





## If flip_h is true will flip Horizontal else will flip verticle 
@export var flip_h:bool = true
@export_tool_button("Flip Sprite") var flip_sprite_action = flip_sprite
@export var flip_state_h: bool = false
@export var flip_state_v: bool = false

## Texture assigned via Inspector (with live editor preview)
@export var sprite: Texture:
	set(value):
		_sprite = value
		_update_sprite_preview(_sprite)
	get:
		return _sprite

## Reference to the Object's StaticBody (assign in Inspector or auto-find)
@export var object_body: StaticBody2D = null

## Reference to the Object's Sprite (assign in Inspector or auto-find)
@export var object_sprite: Sprite2D = null

## Reference to the Object's CollisionShape (assign in Inspector or auto-find)
@export var object_collisionshape: CollisionShape2D = null

## Backing field for 'sprite' to avoid recursion
var _sprite: Texture = null

@export var enable_region_and_prompt: bool = false:
	set(value):
		_enable_region_and_prompt = value
		if Engine.is_editor_hint():
			_apply_enable_region()
			_enable_region_and_prompt = false
			notify_property_list_changed()
	get:
		return _enable_region_and_prompt

var _enable_region_and_prompt: bool = false

func _ready() -> void:
	if object_sprite:
		object_sprite.flip_h = flip_state_h
		object_sprite.flip_v = flip_state_v
	# Try to auto-assign commonly-named children if the inspector fields are blank
	if not object_body:
		object_body = get_node_or_null("StaticBody2D")
	# collision shape is often a child of the StaticBody2D
	if not object_collisionshape and object_body:
		object_collisionshape = object_body.get_node_or_null("CollisionShape2D")
	if not object_sprite:
		object_sprite = get_node_or_null("Sprite2D")

	# ensures preview also applies in-game and in-editor
	if _sprite and object_sprite:
		_update_sprite_preview(_sprite)



func flip_sprite() -> void:
	if not object_sprite:
		push_warning("object_sprite not assigned")
		return

	if flip_h:
		flip_state_h = not flip_state_h
		object_sprite.flip_h = flip_state_h
	else:
		flip_state_v = not flip_state_v
		object_sprite.flip_v = flip_state_v

	print("Sprite flipped", "H" if flip_h else "V")


func _apply_enable_region() -> void:
	if not object_sprite:
		push_warning("object_sprite not assigned — cannot enable region.")
		return
	# Enable region on the Sprite2D
	object_sprite.region_enabled = true
	# Optionally initialize a reasonable region rect if blank
	if object_sprite.region_rect == Rect2():
		var tex := object_sprite.texture
		if tex:
			object_sprite.region_rect = Rect2(Vector2.ZERO, tex.get_size())
	# Provide quick instruction
	push_warning("Sprite region enabled. Select the Sprite node and adjust the Region in the Inspector (or use the Region editor).")


func _update_sprite_preview(new_sprite: Texture) -> void:
	if not object_sprite:
		# In the editor this warns; in runtime it won't crash
		push_warning("object_sprite is not assigned for %s" % name)
		return
	# Sprite2D uses 'texture' property
	object_sprite.texture = new_sprite
	# If running in the editor, mark the node dirty so inspector updates visually
	if Engine.is_editor_hint():
		notify_property_list_changed()
