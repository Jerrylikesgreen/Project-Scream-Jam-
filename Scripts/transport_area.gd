class_name TransportArea
extends Area2D

# The scene to change to (set in the inspector)
@export var transition_to_scene: PackedScene

var scene_path: NodePath

func _ready() -> void:
	# connect the signal in a Godot-4-friendly, explicit way
	connect("body_entered", Callable(self, "_on_body_entered"))
	scene_path = transition_to_scene.resource_path

func _on_body_entered(body: Node) -> void:
	print("TransportArea: body entered -> ", body)

	# If a killer walks in, queue its state for the next scene, then free it
	if body is Killerbody:
		# Defensive: make sure transition scene exists
		if not transition_to_scene:
			push_error("TransportArea: transition_to_scene is not set.")
			return

		KillerManager.killer_in_other_room = true
		body.queue_free()
		return

	# If the player enters, persist the player and change scene
	if body.is_in_group("Player"):
	
		# Move player out of the current scene so it isn't freed
		var player = body.get_parent()
		if player:
			await get_tree().process_frame
			player.get_parent().remove_child(player)
			KillerManager.killer_in_other_room = true

		get_tree().change_scene_to_file(scene_path)
