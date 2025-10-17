## Autoload Events
extends Node
const GAME_OVER = preload("uid://bq1dinllmwo6p")
const ESCAPED_SCREEN = preload("res://Scenes/Menus/escape_screen.tscn");


# Signal other nodes can connect to: Events.connect("player_hit", target, "_on_player_hit")
signal player_hit_signal
signal player_escape_signal
signal player_message(new_message: String)
signal pin_entered_signal(v:bool)
signal play_sfx_signal(track: String, pos: Vector2 , overlap: bool , restart_same: bool )
signal room_changed_signal

var _msg_default_cooldown := 30.0           # seconds; change as you like
var _msg_last_until: Dictionary = {}        # text -> show-again time (unix seconds)
var game_start:bool = true

const MSG_TEXT_COOLDOWN := {
	"I need to escape!!": 99999.0
}

var negative_player_dialog: Array[String] = [
	"(¯―¯ ;)",
	"(；一_一)",
	"(T_T)",
	"(*_*)",
	"(>_<;) !!"
]

func room_changed()->void:
	emit_signal("room_changed_signal")
	print(self.name, " > called room_changed_signal ")

func player_hit_event() -> void:
	emit_signal("player_hit_signal")
	
func _now_s() -> float:
	return Time.get_unix_time_from_system()

func escape()->void:
	var escape_screen = ESCAPED_SCREEN.instantiate();
	get_tree().get_current_scene().add_child(escape_screen);
	return;

func game_over()->void:
	var game_over_screen = GAME_OVER.instantiate()
	var scene_root = get_tree().get_current_scene()
	scene_root.add_child(game_over_screen)

func game_restart() -> void:
	Globals.is_new_start = true

	if Globals.player != null and is_instance_valid(Globals.player):
		Globals.player.queue_free()
		Globals.player = null

	var initial_scene = preload("res://Scenes/main.tscn")
	get_tree().call_deferred("change_scene_to_packed", initial_scene)


func pin_entered(v:bool) -> void:
	emit_signal("pin_entered_signal", v)

func player_gains_points(points:int)->void:
	var points_gained = Globals.player_data.player_score + points
	Globals.player_data.player_score = points_gained


func sfx_play(track: String, pos: Vector2 , overlap: bool , restart_same: bool )->void:
	emit_signal("play_sfx_signal", track, pos, overlap, restart_same)


func display_player_message(new_message: String, cooldown: float = -1.0, force: bool = false) -> void:
	if not force:
		var cd := (cooldown if cooldown >= 0.0 else _msg_default_cooldown)
		var n := _now_s()
		var allow_at := float(_msg_last_until.get(new_message, 0.0))
		if n < allow_at:
			return
		_msg_last_until[new_message] = n + cd
	
	emit_signal("player_message", new_message)
	print("[EVENTS:MSG] %s" % new_message)
