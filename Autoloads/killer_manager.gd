# KillerManager.gd
extends Node

var queued_killer: Array = []

## Queue a killer for a scene (store its PackedScene and optional state)
func queue_killer_for_scene(packed_scene: PackedScene, killer_data: Dictionary) -> void:
	queued_killer.append({
		"scene": packed_scene,
		"data": killer_data  # e.g., state, patrol info, facing direction, etc.
	})

# Spawn queued killer[s] for the given scene_root
func spawn_enemies_for_scene(scene_root: Node) -> void:
	for enemy_data in queued_killer:
		if enemy_data["scene"] == scene_root.get_filename():  # match by scene file path
			## Instantiate a new Killer from the PackedScene
			var killer_scene: PackedScene = enemy_data["data"]["scene_packed"]
			var killer: Node2D = killer_scene.instantiate() as Node2D
			scene_root.add_child(killer)

			## Finds EntryPoint inside the scene_root
			var spawn_position: Vector2 = Vector2.ZERO
			for child in scene_root.get_children():
				if child.is_in_group("EntryPoint") and child is Node2D:
					spawn_position = child.global_position
					break

			killer.global_position = spawn_position

			# Restore other state if needed
			if "state" in enemy_data["data"]:
				for key in enemy_data["data"]["state"].keys():
					killer.set(key, enemy_data["data"]["state"][key])

	# Clear queue after spawning
	queued_killer.clear()
