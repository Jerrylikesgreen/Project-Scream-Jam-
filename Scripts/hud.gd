class_name HUD extends CanvasLayer



@onready var switch: Switch1 

const PIN_PAD = preload("uid://mdo0lponneh")

@onready var block: CollisionShape2D = $Block

var pop_up: Control
var _pop_up_shown:bool = false
var active: bool = true

 
func _ready() -> void:
	var hud = get_tree().current_scene.get_node("HUD")
	if hud == null:
		push_warning("HUD node not found under current_scene. Check the path.")
		return

	pop_up = PIN_PAD.instantiate()
	pop_up.visible = false   
	hud.add_child(pop_up)   
	Events.pin_entered_signal.connect(_on_pin_entered_signal)
	#hud.action_incomplete_signal.connect(_on_action_incomplete_signal)
	#hud.action_complete_signal.connect(_on_action_complete_signal)

func _on_pin_entered_signal(v: bool) -> void:
	if v:
		active = true
	if pop_up:
		pop_up.set_visible(false)
	_pop_up_shown = false


func _on_pin_signal()->void:
	block.set_disabled(true)
	


func _on_action_complete_signal()->void:
	pass

func _on_action_incomplete_signal()->void:
	if !_pop_up_shown:
		
		pop_up.show()
		_pop_up_shown = true
