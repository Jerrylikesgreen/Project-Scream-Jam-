extends Node

# Signal other nodes can connect to: Events.connect("player_hit", target, "_on_player_hit")
signal player_hit_signal


func player_hit_event() -> void:
	emit_signal("player_hit_signal")
