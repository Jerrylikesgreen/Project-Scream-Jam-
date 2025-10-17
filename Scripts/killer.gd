class_name Killer extends Node2D

@onready var killer_body: Killerbody = %"Killer Body"




func stun()->void:
	killer_body.killer_state = killer_body.KillerState.IDLE
	Events.sfx_play("Ping", global_position, true, true)
	pass
