class_name HUD extends CanvasLayer



@onready var switch: Switch1 

const PIN_PAD = preload("uid://mdo0lponneh")

@onready var block: CollisionShape2D = $Block

var pop_up: Control
var _pop_up_shown:bool = false
var active: bool = true
var switch_ref:StaticBody2D
 
func _ready() -> void:
	var switch_node_search = get_tree().get_nodes_in_group("Switch")
	for nodes in switch_node_search:
		if nodes._switch:
			switch_ref = nodes.get_child(0)
			switch_ref.action_incomplete_signal.connect(_on_action_incomplete_signal)
			switch_ref.action_complete_signal.connect(_on_action_complete_signal)

	pop_up = PIN_PAD.instantiate()
	pop_up.visible = false   
	add_child(pop_up)   
	Events.pin_entered_signal.connect(_on_pin_entered_signal)

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
	print("received action complete", _pop_up_shown)
	if !_pop_up_shown:
		_pop_up_shown = true
		pop_up.set_visible(true)
