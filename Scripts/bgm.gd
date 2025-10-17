class_name BGM
extends AudioStreamPlayer

@export var fade_enabled  : bool  = true
@export var fade_in_time  : float = 1.0
@export var fade_out_time : float = 1.0



enum Track { NONE, ROOM, CHASE }
const TRACK_NONE := -1
var track:Track = Track.ROOM
@export var tracks: Array[AudioStream]
@export var fade_time     : float = 0.08 

var _current_track       : int = TRACK_NONE
var _tw_node: Tween = null

const MUTE_DB := -80.0

func _ready() -> void:
	print("[BGM] _ready called")
	Events.play_bgm_signal.connect(_on_play)
	
	# Start default track immediately
	if tracks.size() > Track.ROOM:
		print("[BGM] Starting default ROOM track")
		_on_play(Track.ROOM)
	var bus = get_bus()
	print("[BGM] Bus name:", bus)
	print("[BGM] Bus volume_db:", AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus)))
	print("[BGM] Bus mute:", AudioServer.is_bus_mute(AudioServer.get_bus_index(bus)))


func _on_play(v:int) -> void:
	print("[BGM] _on_play called with track:", v)
	if v < 0 or v >= tracks.size():
		push_error("[BGM] Invalid track index: %d" % v)
		return
	play_track(v)

func play_track(track_idx: int, custom_time: float = -1.0) -> void:
	print("[BGM] play_track called with:", track_idx)
	if track_idx == _current_track:
		print("[BGM] Track already playing, returning")
		return

	var use_custom: bool = custom_time >= 0.0
	var out_t: float = (custom_time if use_custom else fade_out_time)
	var in_t : float = (custom_time if use_custom else fade_in_time)

	_kill_tween_node()

	if playing:
		print("[BGM] Currently playing, fading out to track:", track_idx)
		_fade_out_then_switch(track_idx, out_t, in_t)
	else:
		print("[BGM] Not playing, switching immediately to track:", track_idx)
		_switch_stream(track_idx)
		_fade_in(in_t)

func _switch_stream(track_idx: int) -> void:
	print("[BGM] _switch_stream called with track:", track_idx)
	_current_track = track_idx
	if track_idx >= 0 and track_idx < tracks.size():
		var new_stream = tracks[track_idx]
		if new_stream == null:
			push_error("[BGM] Track %d is null!" % track_idx)
			return
		stream = new_stream
		print("[BGM] Stream set, calling play()")
		play()
	else:
		push_error("[BGM] Invalid track index in _switch_stream: %d" % track_idx)
	print("[BGM] Stream assigned:", stream, "playing:", playing)

func _fade_in(t: float) -> void:
	print("[BGM] _fade_in called, t =", t)
	if not fade_enabled or t <= 0.0:
		volume_db = 0.0
		if not playing:
			print("[BGM] fade disabled or t<=0, calling play()")
			play()
		return

	if not playing:
		print("[BGM] Not playing, calling play() before fade in")
		play()

	_kill_tween_node()
	_tw_node = get_tree().create_tween()
	_tw_node.tween_property(self, "volume_db", 0.0, t).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	print("[BGM] Fade in tween created for t =", t)

func _fade_out_then_switch(next_track: int, out_t: float, in_t: float) -> void:
	print("[BGM] _fade_out_then_switch called: next_track =", next_track)
	if not fade_enabled or out_t <= 0.0:
		print("[BGM] Fade out disabled, stopping and switching")
		stop()
		_switch_stream(next_track)
		_fade_in(in_t)
		return

	_kill_tween_node()
	_tw_node = get_tree().create_tween()
	_tw_node.tween_property(self, "volume_db", MUTE_DB, out_t).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tw_node.tween_callback(Callable(self, "_on_fade_out_finished").bind(next_track, in_t))
	print("[BGM] Fade out tween created for t =", out_t)

func _on_fade_out_finished(next_track: int, in_t: float) -> void:
	print("[BGM] _on_fade_out_finished called, switching to track:", next_track)
	stop()
	_switch_stream(next_track)
	_fade_in(in_t)

func _kill_tween_node() -> void:
	if is_instance_valid(_tw_node):
		print("[BGM] Killing existing tween")
		_tw_node.kill()
	_tw_node = null
