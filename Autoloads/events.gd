## Events Autoload. - Global Observer, Exposed Methods to all nodes that will emit a Signal 
extends Node

signal player_hit_signal

func player_hit()->void:
	emit_signal("")
