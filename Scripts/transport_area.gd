class_name TransportArea
extends Area2D



@export var transition_to_scene: PackedScene

@onready var scene_path: NodePath

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	

func _on_body_entered(body: Node) -> void:
	print("TransportArea: body entered -> ", body)
	if !transition_to_scene:
		return
	scene_path = transition_to_scene.resource_path
	if body is Killerbody:
		if not transition_to_scene:
			push_error("TransportArea: transition_to_scene is not set.")
			return

		KillerManager.killer_in_other_room = true

	if body.is_in_group("Player"):
	
		var player = body.get_parent()
		if player:
			await get_tree().process_frame
			player.get_parent().remove_child(player)
			KillerManager.killer_in_other_room = true


			print(self.name, ": sent room changed signal.")

		get_tree().change_scene_to_file(scene_path)
