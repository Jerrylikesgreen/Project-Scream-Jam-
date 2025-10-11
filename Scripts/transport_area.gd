class_name TransportArea extends Area2D


## This will hold refrence to the scene that the player or kliller will transition to when thay enter the Area. 
@export var transition_to_scene: PackedScene

func _ready():
	body_entered.connect(_on_body_entered)
	print(body_entered)

func _on_body_entered(body: Node) -> void:
	print("Killer Entered")
	if body is Killerbody:
		KillerManager.queue_killer_for_scene(transition_to_scene, body.get_state_dict())
		body.queue_free()
