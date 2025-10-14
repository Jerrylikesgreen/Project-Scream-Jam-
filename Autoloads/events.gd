## Autoload Events
extends Node

# Signal other nodes can connect to: Events.connect("player_hit", target, "_on_player_hit")
signal player_hit_signal
signal player_message(new_message: String)
signal pin_entered_signal(v:bool)



var _msg_queue: Array = []                       # [{text, tag}]
var _msg_last_emit_time: float = -9999.0
var _msg_last_by_tag := {}                       # tag -> last time
var _msg_recent_text_until := {}                 # text -> expire time
var _msg_window_count := 0
var _msg_tick: Timer = null
var _msg_window_timer: Timer = null
var _last_emit_norm := ""
var _last_emit_time := 0.0
var _msg_default_cooldown := 30.0           # seconds; change as you like
var _msg_last_until: Dictionary = {}        # text -> show-again time (unix seconds)

const MSG_TEXT_COOLDOWN := {
	"I need to escape!!": 99999.0
}



func player_hit_event() -> void:
	emit_signal("player_hit_signal")
	
func _now_s() -> float:
	return Time.get_unix_time_from_system()


func pin_entered(v:bool) -> void:
	emit_signal("pin_entered_signal", v)


func display_player_message(new_message: String, cooldown: float = -1.0) -> void:
	# Deduplicate identical messages for a cooldown window
	var cd := (cooldown if cooldown >= 0.0 else _msg_default_cooldown)
	var n := _now_s()
	var allow_at := float(_msg_last_until.get(new_message, 0.0))
	if n < allow_at:
		# Suppress spam
		pass ##TODO 

	_msg_last_until[new_message] = n + cd
	emit_signal("player_message", new_message)
	print("[EVENTS:MSG] %s" % new_message)
