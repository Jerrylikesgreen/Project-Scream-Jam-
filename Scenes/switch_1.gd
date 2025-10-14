@tool 
class_name Switch1 extends InteractibleObject

const PIN_PAD = preload("uid://mdo0lponneh")

@onready var block: CollisionShape2D = $Block

var pop_up: Control
var _pop_up_shown:bool = false

func _ready() -> void:
	pop_up = PIN_PAD.instantiate()
	pop_up.set_visible(false)
	add_child(pop_up)
	Events.pin_entered_signal.connect(_on_pin_entered_signal)

func action() -> void:

	if not is_acting:
		is_acting = true
		interactible_object_progress_bar.visible = true
		if !active:
			print("Action started (frame-based increment)")


func action_complete() -> void:
	print("Action complete!")
	interactible_object_progress_bar.visible = false
	interactible_object_sprite_2d.set_frame(1)
	action_count = 0.0
	emit_signal("point_gain", points)
	block.set_disabled(true)
	

func action_incomplete() -> void:
	if !_pop_up_shown:
		
		pop_up.show()
		_pop_up_shown = true

	interactible_object_progress_bar.visible = false
	action_count = 0.0
	print(_pop_up_shown)



func _on_pin_entered_signal(v: bool) -> void:
	if v:
		active = true
	# always hide/clear the popup so it won't re-open immediately
	if pop_up:
		pop_up.set_visible(false)
	_pop_up_shown = false
